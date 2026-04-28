# Maintenance Strategy

> Read this when something in the deploy chain is broken, or quarterly to make
> sure none of the time-bombs in this doc have gone off without you noticing.

This doc exists because of the **April 2026 outage** — a ~3-month silent regression
where every dev-tools-builder build "succeeded" but never actually published an
image, hiding behind compounding secondary failures (expired tokens, expired
HashiCorp PGP keys, terraform/terragrunt version drift, IAM role drift, broken
docker auth, lock-file format incompatibility). The chain went unnoticed because
no PRs had been merged in months — every problem stayed dormant until a real
deploy was attempted.

The lesson is the title of the doc: this stack is full of *things that will rot
silently if left alone*. The mitigations below exist to make rot loud.

---

## Architecture map

| Layer | What it is | Where it lives |
|---|---|---|
| **Cloud Build triggers** | Webhook receivers for PR + merge events | `environments/global/ci/terragrunt.hcl` (provisions) → GCP Cloud Build (regional, `us-central1`) |
| **Build images** | Container images that run the build steps | `assets/images/dev-tools-builder` → Artifact Registry: `us-central1-docker.pkg.dev/abby-ranson/docker/dev-tools-builder:{basic,packer,terraform}` |
| **`github-ops-builder`** | Python CLI for version bumps, tags, releases, auto-PRs | `assets/scripts/github-ops-cli` → Artifact Registry: `us-central1-docker.pkg.dev/abby-ranson/docker/github-ops-builder` |
| **The cascade** | label → bump → tag → release → auto-PR → terragrunt apply → firebase deploy | Every repo's `config/cloudbuild.yaml` |
| **Secrets** | `github_token`, `acme_challenge_token`, Firebase deploy creds | GCP Secret Manager (project: `abby-ranson`) |
| **Terraform state** | Module state per environment | GCS backend (per terragrunt config) |
| **App** | The actual portfolio site | Firebase Hosting → `abbyranson.com` |

When you push a labelled PR to a submodule (e.g. `portfolio-web`), the cascade is:

1. `<submodule>-merge-trigger` fires → runs `bump-version` → creates git tag + GitHub release.
2. `update-submodule` opens auto-PR in `ranson21/portfolio` updating the submodule pointer.
3. Auto-PR auto-merges → `portfolio-merge-trigger` fires.
4. `make deploy` → `terragrunt run-all apply --terragrunt-non-interactive` in `environments/stable/`.
5. The web deployer module pulls the new release from GitHub and runs `firebase deploy --only hosting`.

If the cascade stalls anywhere, the rest of the chain stays silent. There is no
notification on a failed step — you find out next time you look at the live site.

---

## Quarterly maintenance checklist

Run these every 3 months. Whichever quarter you're in.

### 1. Verify recent deploys actually shipped

```bash
# Most recent BUILD on the parent (last actual deploy attempt)
gcloud builds list --project=abby-ranson --region=us-central1 \
  --filter='substitutions.REPO_NAME=portfolio AND status=SUCCESS' \
  --limit=5 --format='table(createTime.date(),status,substitutions.COMMIT_SHA.scope(commits))'

# Last published dev-tools-builder image tag (should be recent if anything has shipped)
gcloud artifacts docker tags list \
  us-central1-docker.pkg.dev/abby-ranson/docker/dev-tools-builder \
  --filter='tag~^terraform-v' --format='table(tag,createTime.date())' --limit=5
```

If the last successful portfolio build was >90 days ago, force-trigger a no-op
deploy by running `gcloud builds triggers run portfolio-merge-trigger --branch=master`.
A no-op apply that succeeds proves the chain still works. A failure now is much
better than a failure when you actually need to ship.

### 2. Rotate `github_token`

GitHub classic PATs with `repo` scope MUST be rotated annually (max expiration 1 year).

```bash
# 1. Check how old the current "latest" version is
gcloud secrets versions list github_token --project=abby-ranson \
  --format='table(name,state,createTime.date())'

# 2. Generate new PAT at https://github.com/settings/tokens (logged in as ranson21)
#    Scopes: repo (covers all reads/writes on portfolio + portfolio-web + tf-* repos)
#    Set expiration: 1 year

# 3. Add as new secret version (token never lands in shell history)
read -rs -p "Paste new PAT: " TOKEN && echo \
  && echo -n "$TOKEN" | gcloud secrets versions add github_token \
       --data-file=- --project=abby-ranson \
  && unset TOKEN

# 4. Verify the new version authenticates as ranson21 (NOT ranorio)
TOKEN=$(gcloud secrets versions access latest --secret=github_token --project=abby-ranson) \
  && curl -s -H "Authorization: token $TOKEN" https://api.github.com/user \
       | python3 -c "import json,sys; d=json.load(sys.stdin); print('login:', d.get('login'))" \
  && unset TOKEN
# expected: login: ranson21

# 5. Disable the old version
gcloud secrets versions disable <OLD_VERSION_NUM> --secret=github_token --project=abby-ranson
```

> **Watch out:** in the April 2026 outage, the active SSH default key + GitHub
> session were both `ranorio`, so a "fresh" PAT generated by accident belonged
> to `ranorio`, which has read but not write access to `ranson21/*`. GitHub
> returns 404 (not 403) for unauthorized writes, so it looked like a different
> bug. Always verify `login: ranson21` after rotation.

### 3. Drift-check IAM bindings on `cloudbuild` SA

```bash
# What the SA actually has
gcloud projects get-iam-policy abby-ranson \
  --flatten='bindings[].members' \
  --format='value(bindings.role)' \
  --filter="bindings.members:967775365487@cloudbuild.gserviceaccount.com" | sort > /tmp/actual.txt

# What HCL declares
awk '/cloudbuild_roles = \[/,/^  \]/' environments/global/ci/terragrunt.hcl \
  | grep -oE '"roles/[^"]+"' | tr -d '"' | sort > /tmp/declared.txt

diff /tmp/actual.txt /tmp/declared.txt
```

Anything in actual-but-not-declared is drift — someone manually added a role.
Either add it to HCL or remove it from GCP. Don't leave it dangling — that's
how `firebase.admin` got dropped during the April apply (HCL didn't declare it,
terraform was about to remove it, would have broken the next deploy).

### 4. Cost audit

```bash
# Running compute instances (VPN was forgotten for years and cost ~$10/mo)
gcloud compute instances list --project=abby-ranson \
  --format='table(name,status,machineType.basename(),zone.basename())'

# Static external IPs (can cost $3/mo when reserved-but-unused)
gcloud compute addresses list --project=abby-ranson \
  --format='table(name,status,address,users[0])'

# Artifact Registry image storage (orphaned tags add up)
gcloud artifacts docker tags list \
  us-central1-docker.pkg.dev/abby-ranson/docker/dev-tools-builder \
  --format='value(tag)' | wc -l
```

Anything you don't recognize: investigate. Anything you don't need: destroy.

### 5. Renew TLS / ACME challenge tokens if applicable

If you're using DNS-01 cert renewal via the `_acme-challenge` TXT record,
verify the cert hasn't gone stale. Firebase Hosting auto-renews so this is
mostly a no-op, but custom certs need attention.

```bash
echo | openssl s_client -connect abbyranson.com:443 -servername abbyranson.com 2>/dev/null \
  | openssl x509 -noout -enddate
```

---

## Yearly maintenance checklist

Run these once a year. Pick a calendar reminder you'll actually see.

### 1. Bump terraform + terragrunt + alpine package versions

The April 2026 outage was driven by terraform 1.6.0 (HashiCorp PGP key rotated
in 2024 → expired keys broke provider signature checks). Same risk exists for
every pinned version.

Currently pinned in `assets/images/dev-tools-builder/bake/variables.pkr.hcl`:

| Var | What | Where it bites |
|---|---|---|
| `terraform_version` | Terraform CLI | Provider PGP key rotation (every ~2y) |
| `terragrunt_version` | Terragrunt CLI | Init flow changes per terraform major |
| `gcloud_version` | gcloud SDK | Docker credential helper, deprecated APIs |
| `packer_version` | Packer CLI | Plugin installation API |

Bump each to the latest stable. Then **before merging the bump PR**, regenerate
terraform lock files in the parent repo (see "Terraform lock-file regeneration"
below).

### 2. Regenerate terraform lock files on terraform major bumps

Lock files have version-specific hash formats. A terraform 1.6 → 1.10 bump will
*usually* not invalidate hashes, but a 1.5 → 1.10 bump *did*. When you bump
terraform, regenerate proactively:

```bash
set -a && source ~/workspace/portfolio/.env && set +a
cd ~/workspace/portfolio
for mod in $(find environments/stable -name terragrunt.hcl -not -path '*/.terragrunt-cache/*'); do
  d=$(dirname "$mod")
  echo "== $d =="
  rm -f "$d/.terraform.lock.hcl"
  rm -rf "$d/.terragrunt-cache"
  (cd "$d" && timeout 60 terragrunt init --terragrunt-non-interactive >/dev/null) || echo "  FAILED"
done
git add environments/stable/*/.terraform.lock.hcl environments/stable/*/*/.terraform.lock.hcl
git commit -m "chore: regenerate terraform lock files for terraform <NEW_VERSION>"
```

### 3. Audit the all-in-one builder removals + similar dead config

The all-in-one `dev-tools-builder:latest` image was orphaned for >18 months
before someone (this engagement) noticed and removed it. Periodically:

```bash
# Find image tags that are NEVER referenced in any cloudbuild.yaml
for tag in $(gcloud artifacts docker tags list \
    us-central1-docker.pkg.dev/abby-ranson/docker/dev-tools-builder \
    --format='value(tag)'); do
  if ! grep -rq ":$tag" --include='*.yaml' .; then
    echo "ORPHAN: dev-tools-builder:$tag"
  fi
done
```

---

## Common failure patterns + how to diagnose

### "Build succeeded, but nothing changed in production"

This is the silent-failure pattern. The dev-tools-builder pipeline used parallel
backgrounded `docker push`es with bare `wait`, which exits 0 regardless of child
exit codes. Every push could fail individually and the build would still SUCCESS.

**Symptom:** Recent build succeeded but `gcloud artifacts docker tags list ...`
shows no new tag, OR the live site is still on an old version.

**Diagnosis:**
```bash
# Fetch a build's logs and look for credential / push errors
gcloud builds log <BUILD_ID> --project=abby-ranson --region=us-central1 \
  | grep -iE 'error|denied|credential|push|fail'
```

**Fix:** Make `wait` propagate failures. Until that's done, scan logs after every
deploy.

### "Required plugins are not installed" (terraform init)

Lock file hashes are from an older terraform version that the current terraform
binary won't accept.

**Fix:** Delete the lock files in the affected modules and re-init:
```bash
find environments/stable -name '.terraform.lock.hcl' -not -path '*/.terragrunt-cache/*' -delete
cd environments/stable && terragrunt run-all init --terragrunt-non-interactive
```

Commit the regenerated locks.

### "openpgp: key expired" (provider download)

HashiCorp rotated their PGP signing key in 2024. Terraform 1.6 and earlier have
the old key bundled. Bump terraform to ≥ 1.7 (currently pinned 1.10.5).

### "client version 1.52 is too new" (docker logout/login/push)

Alpine's `apk add docker` ships docker 29.x by default. Cloud Build's host
docker daemon caps at API 1.41. Either:
- Set `DOCKER_API_VERSION=1.41` env var on the offending step
- Pin `apk add docker=20.10.~` in `install-docker.sh`

### "401 Unauthorized" on `releases/latest` GET *or* "404 Not Found" on POST `/releases`

`github_token` secret is expired (401) or belongs to the wrong account (404).
See the rotation procedure above. **Always verify `login: ranson21` after
rotating.**

### "Plan: 0 to add, 0 to change, N to destroy" on a CI module apply

You're about to remove IAM bindings or other resources that something in the
chain depends on. Look at the destroyed resources carefully — `firebase.admin`
hidden in there will silently break Firebase Hosting deploys.

**Fix:** add the load-bearing resources to HCL declarations *before* applying.

### "DNS records being destroyed" or "txt_records is not in configuration"

Almost always a stale terragrunt cache. Clear and replan:

```bash
find environments/<env> -name '.terragrunt-cache' -type d -prune -exec rm -rf {} +
```

---

## Tokens and secrets registry

| Secret name | Purpose | Used by | Rotates | How to rotate |
|---|---|---|---|---|
| `github_token` | PAT for git ops + release creation in GitHub | `cloudbuild.yaml` in every CI repo | **Annually** (PAT max lifetime) | See "Rotate github_token" above |
| `acme_challenge_token` | DNS-01 challenge token for Let's Encrypt cert validation | `environments/stable/dns/terragrunt.hcl` | When cert is renewed | Issued by ACME flow; update the secret manually if running cert-bot externally |
| Firebase deploy creds | Used by `tf-web-deployer` to run `firebase deploy --only hosting` | `assets/modules/tf-web-deployer/main.tf` | When Firebase service account keys rotate | Re-create service account key, update Secret Manager |

---

## Things to never do

- **Don't `apply` blindly when a plan shows destroys.** The "8 destroys" pattern
  in `tf-gcp-gh-pipeline` was *positional-index churn* (no real change), but
  applying when you don't understand what's destroyed is how `firebase.admin`
  gets dropped.
- **Don't trust local `terragrunt plan` output without clearing
  `.terragrunt-cache` first.** Stale caches show changes that aren't real.
- **Don't trust local `terragrunt plan` output if `GITHUB_TOKEN` /
  `ACME_CHALLENGE_TOKEN` aren't sourced.** Empty values cascade through to
  empty resource attributes that look like real diffs.
- **Don't squash-merge a terraform-version bump without regenerating lock
  files in the same PR.** You'll ship a deploy that fails on lock-file format
  the next time it runs.
- **Don't commit a manual submodule pointer bump in the parent repo.** That
  bypasses the cascade entirely and leaves both repos out of sync. Always go
  through the PR cascade.

---

## When this doc is wrong

The `cloudbuild.yaml`, terragrunt configs, and module sources are the source
of truth. This doc is a survival guide that ages — read it skeptically and
verify against current configs before acting.

If you change a load-bearing thing (rotate a token, bump a version, add a new
trigger), come back and update this doc *in the same PR*. Future-you will
thank you.

# Portfolio CI/CD Pipeline Status — 2026-04-28

## TL;DR

**Pipeline is materially broken — Cloud Build triggers do not exist in any GCP project.** The original audit assumed the chain was wired-but-idle; live `gcloud builds triggers list` against all five reachable projects (`abby-ranson`, `labralabs`, `ranor-rithm`, `ranor-skillflow`, `ranor-suite`) returns zero triggers. The most recent Cloud Build run in `abby-ranson` was **2024-06-01** — meaning even the January 2025 git tags (`v1.0.1` on portfolio-web, `v1.0.2` and `v2.0.0` on portfolio) **never actually deployed through Cloud Build**. They are git tags only.

The pipeline code (`config/cloudbuild.yaml`, `assets/scripts/github-ops-cli/`, `assets/modules/tf-gcp-gh-pipeline/`, terragrunt module wiring) is intact. The triggers were torn down at some point between mid-2024 and now and have not been re-provisioned.

The HCL syntax bug at `environments/global/ci/terragrunt.hcl:23` (missing comma) blocks `terragrunt apply` on the CI module and must be fixed first.

> Pipeline runs on **GCP Cloud Build**, not GitHub Actions. The only GHA workflow (`check-labels.yml`) just enforces semver labels on PRs.

## Live state (2026-04-28)

| Probe | Result |
|---|---|
| `gcloud config get-value project` | `abby-ranson` |
| `gcloud builds triggers list --project=abby-ranson` | **empty (0 triggers)** |
| `gcloud builds triggers list --project=labralabs` | empty (0 triggers) |
| `gcloud builds triggers list --project=ranor-*` | empty / Cloud Build API not enabled |
| Most recent `gcloud builds list --project=abby-ranson` | `5a7b0625` 2024-06-01 SUCCESS |
| Last release tag on `portfolio-web` | `v1.0.1` (2025-01-16, commit `15c188f`) |
| Last release tag on `portfolio` | `v2.0.0` (2025-01-16, commit `b410782`) |

**Implication:** the Jan 2025 tags exist as git refs but no Cloud Build run corresponds to them. The pipeline was already non-functional before any of the 2026 refactor work began.

## Step-by-step status

### Step 1 — Label-driven semver bump on portfolio-web
**Status: BROKEN — trigger does not exist**

Code is wired correctly:
- `assets/modules/tf-gcp-gh-pipeline/main.tf:115-148` declares the `merge_trigger`
- `apps/web/portfolio/config/cloudbuild.yaml` declares the build steps
- `assets/scripts/github-ops-cli/github_ops.py:75-129` implements the bump logic

But the GCP-side trigger that would invoke this pipeline does not exist. A push to `master` on `portfolio-web` will not fire anything.

### Step 2 — Auto-PR in parent portfolio repo
**Status: BROKEN — depends on step 1**

Code is wired (`github_ops.py:219-361`). Cannot run because step 1 cannot fire.

### Step 3 — Terragrunt deploy on parent merge
**Status: BROKEN — trigger does not exist**

Same as step 1: pipeline + deploy code is intact (`Makefile`, `assets/modules/tf-web-deployer/main.tf:51-88`, `environments/stable/web/deploy/terragrunt.hcl`), but no Cloud Build trigger exists on the `portfolio` repo to invoke it on merge.

## Recovery plan (in order)

### 1. Fix the HCL comma bug — DONE 2026-04-28

`environments/global/ci/terragrunt.hcl:23` previously read `"portfolio"` (no comma) followed by `"cloud-functions",`. Fixed in this same engagement; the file now parses cleanly.

### 2. Re-provision Cloud Build triggers

```bash
cd ~/workspace/portfolio/environments/global/ci
terragrunt plan      # confirm trigger creates + GitHub connection state
terragrunt apply     # provision them
```

**Likely friction:** `assets/modules/tf-gcp-gh-pipeline/main.tf:63` provisions `google_cloudbuildv2_connection` to GitHub. If the GitHub-App authorization expired or the connection record is missing, Terraform cannot re-establish it on its own — a one-time manual step in the GCP console (Cloud Build → Repositories → "Connect host") may be required. Watch the apply output for `failed_precondition` / `permission_denied` on the connection resource.

Verify after apply:
```bash
gcloud builds triggers list --project=abby-ranson --format="table(name,github.name,filename,disabled)"
# expected: 2 triggers per dual-trigger repo (PR + push), 1 trigger per push-only repo
```

### 3. Repository-level cleanup — DONE 2026-04-28

The two manual submodule-pointer commits on the parent (`646bb4a`, `7f2f92b`) have been replaced with a clean docs-only commit on `portfolio-refactor-slate-theme`. The submodule's `portfolio-refactor-slate-theme` branch has been pushed to `origin/portfolio-refactor-slate-theme` with all today's agent-made content.

### 4. Push portfolio-web PR with semver label

Once triggers are restored, open a PR from `portfolio-refactor-slate-theme` → `master` on `ranson21/portfolio-web` with a `semver:minor` label (theme refactor + content rewrite is a minor-grade change).

The merge will then:
1. Fire the new merge trigger → `cloudbuild.yaml` → `bump-version` → tag (e.g. `v1.1.0`) + GitHub release.
2. The `update-submodule` step opens an auto-PR on `ranson21/portfolio` updating `apps/web/portfolio` pointer + bumping the parent version.
3. Auto-PR auto-merges → fires the parent push trigger → `terragrunt apply` → Firebase deploy.

End state visible at `abbyranson.com`.

## Latent issues to fix when convenient

- **`tf-web-deployer/main.tf:67-76`** uses anonymous `git clone` for `portfolio-web` to read its release. Brittle if the repo becomes private or hits unauthenticated rate limits. Switch to `https://x-access-token:${var.github_token}@github.com/...` or use the GitHub release API directly.
- **GCP Secret Manager:** Verify `github_token`, `acme_challenge_token`, and any Firebase deploy credentials still exist and are accessible to the Cloud Build service account. The 2024 Firebase migration may have rotated these.
- **`tf-gcp-gh-pipeline/main.tf:51-60` `for_each` key churn.** The `google_project_iam_member.cloudbuild_permissions` resource keys its `for_each` on `"${role}-${idx}"` where `idx` is the position in a flattened list. Any insertion or reordering of `cloudbuild_roles` shifts every downstream index → terraform sees those bindings as needing destroy+create even though nothing about them changed. The 2026-04-28 apply showed 8 destroys + 8 creates that were pure bookkeeping for this reason.

  **Fix:** key on a stable identity rather than position. Either use the role string alone (one binding per role, but the module currently grants each role to 2 SAs so that loses information), or compose `role + member` (or a hash of the assignment). Example refactor:

  ```hcl
  resource "google_project_iam_member" "cloudbuild_permissions" {
    for_each = {
      for assignment in local.role_assignments :
      "${assignment.role}|${assignment.member}" => assignment
    }
    project = var.project
    role    = each.value.role
    member  = each.value.member
  }
  ```

  After the change, run `terragrunt apply` once with `terragrunt state mv` calls (or accept a one-time destroy+create churn) to migrate from old keys to new. After migration, future role list edits add/remove only the affected bindings and leave the rest untouched.

  **Why this matters:** every destroy+create on an IAM binding has a small window where the SA temporarily lacks that perm. With the current pattern, every role addition causes ~half the SA's bindings to flap. With the stable-key pattern, only the genuinely-affected bindings change.

## What is genuinely working

- Pipeline source code (`config/cloudbuild.yaml`, `github-ops-cli`, `tf-gcp-gh-pipeline`, `tf-web-deployer`, `Makefile`) — unchanged since the last successful run, no obvious regressions.
- Label-gate workflow (`.github/workflows/check-labels.yml`) — still in place across all repos.
- Terragrunt module composition for `environments/stable/web/{bucket,deploy}` — unchanged.
- Repository cleanup (manual commits removed, submodule pushed, HCL parse error fixed).

## Differences from the original audit (2026-04-28 morning)

The first audit pass concluded "pipeline is intact, just hasn't been merged." That conclusion was based on git history alone — `gh` CLI was unavailable so live Cloud Build state could not be queried. With direct `gcloud` access today the actual state is materially worse: triggers are absent, not idle. This document supersedes the morning version of the same findings.

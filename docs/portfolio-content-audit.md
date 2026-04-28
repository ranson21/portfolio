# Portfolio Content Audit — 2026-04-28

> Agent-ready issue list for the portfolio site at `apps/web/portfolio`.
> Each entry: file:line → category → severity → fix instruction.
> P0 = blocks correctness or credibility, P1 = noticeable degradation, P2 = polish.

## How to use this file

Work top-to-bottom. For each issue, the fix instruction is mechanical — apply it without re-investigating context unless the file/line has drifted from the snapshot at the audit date. After fixing, delete the issue from this file or move it to the "Resolved" section at the bottom.

---

## P0 — Correctness / credibility

### 1. GitHub URL points at the wrong account

- **File:** `apps/web/portfolio/src/screens/Home.jsx:197`
- **Category:** Content / Bug
- **Issue:** Hero IconButton links to `https://github.com/RansonTesting`. The canonical handle (used by `AppBar.jsx`, `README.md`, and the resume) is `ranson21`.
- **Fix:** Replace `https://github.com/RansonTesting` with `https://github.com/ranson21`.
- **Verify:** `grep -rn "RansonTesting" apps/web/portfolio/` returns 0 matches.

### 2. README.md describes a stack that does not exist

- **File:** `apps/web/portfolio/README.md`
- **Category:** Drift / Credibility
- **Issue:** README claims "Redux state management" and "Route management with React Router" as core features (lines 11, 13). The current code uses neither — App.jsx renders four screens with anchor links and `react-intersection-observer`. A reviewer comparing README against the codebase loses trust immediately.
- **Fix:** Rewrite README to describe the actual stack: React 18 + Vite 5 + MUI 5 + `react-final-form` + `react-intersection-observer`. Remove all Redux/Router references. Update the "Project Structure" section to match the real `src/` tree (containers, screens, content, styles, components, utils). Drop the Firebase walkthrough if it doesn't reflect actual deployment (verify against `firebase.json`).
- **Verify:** Reader following the README can build and run the site without surprises.

### 3. Public resume is the old purple/Calibri version

- **File:** `apps/web/portfolio/public/docs/resume.html`
- **Category:** Content / Drift
- **Issue:** Resume color (`#2C275D` purple), typography (Calibri), and skill-bar layout pre-date the slate refactor. ATS parsers also mangle the bar-chart skills section.
- **Fix:** **Replaced by Deliverable 2 of this engagement** — a one-page slate-themed `resume.html` plus an extended 2-page `resume-extended.html`. Once those land, regenerate the dated PDF and update `AppBar.jsx:105`.

### 4. Resume download button hard-codes a stale dated filename

- **File:** `apps/web/portfolio/src/components/AppBar.jsx:105`
- **Category:** Bug / Drift
- **Issue:** `href="docs/2026-03-28-resume.pdf"`. After every rewrite, the link must be updated by hand or the button 404s.
- **Fix:** Either (a) point at a stable `docs/resume.pdf` and have the build process write the dated file *and* a stable copy, or (b) update the link as part of the rewrite PR. Option (a) is preferred for long-term maintenance.

### 5. Phone number published on public resume

- **File:** `apps/web/portfolio/public/docs/resume.html:194`
- **Category:** Privacy
- **Issue:** `202-740-2370` is exposed on the public-facing resume.
- **Fix:** Remove from the canonical public `resume.html`. Maintain a separate submission-copy variant (`resume-extended.html`) that includes phone, used only for direct applications. **Resolved by Deliverable 2.**

---

## P1 — Visible UX / SEO degradation

### 6. Hero displays the user's name three times in the first viewport

- **Files:**
  - `apps/web/portfolio/src/components/AppBar.jsx:61` ("Abigail Ranson" + tagline)
  - `apps/web/portfolio/src/screens/Home.jsx:137-139` (uppercase eyebrow "ABIGAIL RANSON")
  - `apps/web/portfolio/src/screens/Home.jsx:231` (profile card title)
- **Category:** Content / UX
- **Issue:** Repetition undercuts the editorial tone the slate brief calls for.
- **Fix:** Drop the eyebrow at `Home.jsx:137-139`. Keep the AppBar label (it's the navigation context) and the profile card title (which serves a different purpose — the "card" identity). Replace the eyebrow with a single category line like `"Platform Engineer · Cloud Architect"` if anything is needed there at all.

### 7. About-section copy repeats "principal engineer + hands-on" four times in ~150 words

- **File:** `apps/web/portfolio/src/content/portfolioContent.js:29-34` (`aboutContent.intro` and `aboutContent.philosophy`)
- **Category:** Content / Copy
- **Issue:** The phrase "Principal-level / hands-on / strategy + execution" repeats verbatim in different orders. Reads as resume-padding rather than confident voice.
- **Fix:** Tighten to two paragraphs:
  - **Para 1 (intro):** Years + foundation. "Software engineer since 2016, with earlier sysadmin roots that still shape how I think about reliability and operations."
  - **Para 2 (specialization):** What you actually build. "I build the platform layer that engineering teams run on — internal developer platforms, delivery systems, and the policy + observability work that keeps multi-team production environments shippable."
  - Drop `outcomes` paragraph — it duplicates the `philosophy` paragraph. Replace with a single-line capability summary.

### 8. Projects section promises case studies but shows none

- **File:** `apps/web/portfolio/src/content/portfolioContent.js:55-83` (`projectContent.cards`)
- **Category:** Content / Trust
- **Issue:** The three cards describe *categories* of work ("Architecture and modernization", "Delivery systems", "Hands-on implementation"), not concrete projects. Visitors clicking "View Projects" arrive at a section that gives them no projects.
- **Fix:** Pivot to one of two options:
  - **Option A (recommended once project codename is trademark-cleared):** Replace cards with real entries — the in-progress composable cloud infrastructure platform (label as "Independent R&D — Composable Cloud Platform"; **do not use the project codename until trademarked**), 1–2 representative GitHub repos from `github.com/ranson21`, and one federal-program highlight described abstractly (no client name).
  - **Option B (interim):** Rename the section to `Capabilities` and rework the heading + button labels to match. Drop "View Projects" since there are none. Keep the existing copy as a capabilities matrix.
- **Verify:** No card promises a click-through that doesn't exist.
- **STATUS: SKIPPED — needs user decision on Option A vs B.**

### 9. Contact-section CTA copy is too narrow for the new positioning

- **File:** `apps/web/portfolio/src/content/portfolioContent.js:86-98` (`contactContent`)
- **Category:** Content
- **Issue:** Intro reads "Reach out if you need principal-level engineering support, clearer architecture, stronger delivery systems..." — written when the targeting was generic Principal Engineer. Doesn't surface platform/AI-infra positioning.
- **Fix:** Rewrite intro to: "Reach out for platform engineering work, internal developer platforms, AI-infrastructure design, or senior technical leadership on regulated multi-tenant systems." Update `preferredTopics` to match the new positioning.

### 10. Page title and meta description are generic

- **File:** `apps/web/portfolio/index.html:8-10, 26`
- **Category:** SEO / AI scrape
- **Issue:** Title is `"Abby Ranson Portfolio"`. Description is generic. Both miss the keyword surface that AI scrapers and Google use for ranking.
- **Fix:** Set `<title>Abigail Ranson — Platform Engineer & Cloud Architect</title>`. Set the meta description to 150–160 chars including the role keywords (Platform Engineering, Kubernetes, Terraform, AWS, AI infrastructure, Federal). Example: `"Abigail Ranson — Staff/Principal Platform Engineer building agent-ready cloud infrastructure. Kubernetes, Terraform, AWS, federal compliance. Hands-on technical leadership."`.

### 11. Missing Open Graph and Twitter card metadata

- **File:** `apps/web/portfolio/index.html` (head)
- **Category:** SEO
- **Issue:** No `og:*` or `twitter:*` tags. Links shared on LinkedIn, Slack, and X render with no preview image or title.
- **Fix:** Add the standard set:
  ```html
  <meta property="og:type" content="profile" />
  <meta property="og:title" content="Abigail Ranson — Platform Engineer & Cloud Architect" />
  <meta property="og:description" content="..." />
  <meta property="og:url" content="https://abbyranson.com/" />
  <meta property="og:image" content="https://abbyranson.com/img/og-card.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="..." />
  <meta name="twitter:description" content="..." />
  <meta name="twitter:image" content="https://abbyranson.com/img/og-card.png" />
  ```
  Generate a 1200×630 og card image — can be a simple slate-themed card with name + role + portfolio URL.

### 12. Missing JSON-LD Person schema

- **File:** `apps/web/portfolio/index.html` (just before `</body>`)
- **Category:** AI scrape / SEO
- **Issue:** No structured data. AI scrapers (LLM-powered recruiter tools, ChatGPT browse, Claude WebFetch, Perplexity) extract from JSON-LD preferentially over scraped HTML. Without it, Abby's identity and skills are extracted by best-effort heuristics from prose.
- **Fix:** Add a `<script type="application/ld+json">` block:
  ```json
  {
    "@context": "https://schema.org",
    "@type": "Person",
    "name": "Abigail Ranson",
    "alternateName": "Abby Ranson",
    "jobTitle": "Platform Engineer & Cloud Architect",
    "url": "https://abbyranson.com",
    "email": "abby@abbyranson.com",
    "sameAs": [
      "https://www.linkedin.com/in/abbyranson/",
      "https://github.com/ranson21"
    ],
    "knowsAbout": [
      "Platform Engineering","Cloud Architecture","Kubernetes","Terraform",
      "AWS","Azure","GCP","CI/CD","Internal Developer Platforms",
      "AI Infrastructure","Section 508","Federal Compliance","Go","Java",
      "TypeScript","React","Angular","Node.js","Observability","GitOps"
    ],
    "knowsLanguage": ["en"],
    "description": "Platform Engineer building the infrastructure that production AI systems run on."
  }
  ```
- **Verify:** Paste rendered HTML into [Google Rich Results Test](https://search.google.com/test/rich-results). No errors.

### 13. robots.txt does not address AI crawlers

- **File:** `apps/web/portfolio/public/robots.txt`
- **Category:** AI scrape
- **Issue:** Current file blocks API paths but doesn't enumerate AI crawlers. Default behavior is "allowed", but many companies now expect explicit allow lines and recruiter LLM tools check for them.
- **Fix:** Append explicit allow lines so the intent is visible:
  ```
  # Explicit allow for AI crawlers — portfolio is public
  User-agent: GPTBot
  Allow: /

  User-agent: ClaudeBot
  Allow: /

  User-agent: anthropic-ai
  Allow: /

  User-agent: PerplexityBot
  Allow: /

  User-agent: Google-Extended
  Allow: /

  User-agent: CCBot
  Allow: /
  ```
  Optionally explicitly disallow `/api/` paths for these bots if those routes still exist.

### 14. No sitemap.xml

- **File:** `apps/web/portfolio/public/` (missing)
- **Category:** SEO
- **Issue:** Single-page site, but a `sitemap.xml` listing the home URL and the resume URL aids Google + AI crawler discovery.
- **Fix:** Create `public/sitemap.xml` with two entries: `/` and `/docs/resume.html`. Reference it from `robots.txt` via a `Sitemap:` directive.

### 15. Missing canonical URL and author meta

- **File:** `apps/web/portfolio/index.html` (head)
- **Category:** SEO
- **Issue:** No `<link rel="canonical">`, no `<meta name="author">`. Easy fix that helps duplicate-content de-duplication and authorship attribution.
- **Fix:** Add `<link rel="canonical" href="https://abbyranson.com/" />` and `<meta name="author" content="Abigail Ranson" />`.

---

## P1 — Asset weight

### 16. Profile image is 2.1 MB

- **File:** `apps/web/portfolio/public/img/profile_pic.png` (2.1 MB)
- **Category:** Performance
- **Issue:** Loaded at full size in both Hero (`Home.jsx:229`, 72×72 avatar) and About (`About.jsx:53`, ~420×560). The 72×72 avatar fetches 2.1 MB of source.
- **Fix:** Generate two variants:
  - `profile_pic.webp` — 800×1066, ~150 KB, used in About hero
  - `profile_pic_avatar.webp` — 144×144 (2× retina), ~25 KB, used in Hero avatar
  Update both consumers. Use `<picture>` with PNG fallback for older browsers, or accept that browsers >= Safari 14 (~95% of traffic) handle WebP fine.

### 17. Logo is 908 KB

- **File:** `apps/web/portfolio/public/img/logo.png` (908 KB)
- **Category:** Performance
- **Issue:** AppBar logo is rendered small (probably <80px tall). 908 KB is absurd for a small bitmap mark.
- **Fix:** Replace with an SVG version under 5 KB. If SVG isn't available, compress to a 200×200 PNG under 30 KB.

### 18. Stale decorative assets remain in public/img

- **Files:**
  - `apps/web/portfolio/public/img/home_hero.svg`
  - `apps/web/portfolio/public/img/girl_laptop_outdoors.png`
  - `apps/web/portfolio/public/img/shiny_overlay.svg`
  - `apps/web/portfolio/public/img/simple_shiny.svg`
  - `apps/web/portfolio/public/img/under_construction.png`
  - `apps/web/portfolio/public/img/something-went-wrong.png`
  - `apps/web/portfolio/public/img/wave.svg`
  - `apps/web/portfolio/public/img/profile_pic_round.png` (1.1 MB) — duplicate of profile_pic
- **Category:** Asset / Drift
- **Issue:** None of these are referenced from current screens (verified via `grep` against `src/`). The slate theme brief explicitly retires "shiny SVG overlays" and "decorative section illustrations".
- **Fix:** For each asset, run `grep -rn "<filename>" apps/web/portfolio/src/ apps/web/portfolio/index.html`. If 0 matches, delete the file. Keep `something-went-wrong.png` only if `SomethingWentWrong.jsx` actually consumes it.

### 19. `contact_me.png` decoration conflicts with theme brief

- **File:** `apps/web/portfolio/src/screens/Contact.jsx:210` referencing `public/img/contact_me.png`
- **Category:** Asset / Theme alignment
- **Issue:** Theme brief says replace decorative illustrations with stronger type and surface composition.
- **Fix:** Either (a) replace with an editorial composition — a quiet panel with a "How I prefer to work" or "Response time" mini-FAQ — or (b) remove the image entirely and rely on the existing "Good reasons to reach out" panel.
- **STATUS: FLAGGED for user decision — image is actively rendered; left unchanged.**

---

## P2 — Cleanup / polish

### 20. Unused dependencies bloat install + bundle

- **File:** `apps/web/portfolio/package.json:13-33`
- **Category:** Drift
- **Issue:** Verified-unused (no imports under `src/`):
  - `@reduxjs/toolkit`
  - `react-redux`
  - `react-router-dom`
  - `@mui/x-data-grid`
  - `@mui/lab`
  - `clsx`
  - `sass` (only `RocketShip/style.scss` references SCSS, and RocketShip is dead code — see #22)
- **Possibly used (verify before removing):**
  - `fg-loadcss` — only consumed by `FontAwesomeIcon.jsx`, which is exported from `components/index.js` but verify whether anything actually renders it.
  - `react-input-mask` — consumed by `FormControls.jsx` Text component when `mask` prop is passed; current Contact form doesn't pass a mask, so this branch is dead.
  - `@fortawesome/free-brands-svg-icons` and `@fortawesome/react-fontawesome` — likely unused given the icons in current code come from `@mui/icons-material`.
- **Fix:** Run `npx depcheck` or `npx knip` to confirm. Remove confirmed-unused. Run `npm install && npm run build` to verify nothing broke.
- **Verify:** `npm run dev` and `npm run build` both succeed; bundle size shrinks measurably.

### 21. Unused dead-code components

- **Files:**
  - `apps/web/portfolio/src/components/RocketShip/index.jsx` + `style.scss`
  - `apps/web/portfolio/src/components/Astronaut/index.jsx` + `style.css`
  - `apps/web/portfolio/src/components/Hero/index.jsx` + `style.css`
- **Category:** Drift
- **Issue:** None are exported from `components/index.js` (current exports: AppBar, AppContainer, Copyright, EmptyContainer, ErrorBoundary, FontAwesomeIcon, Logo, SomethingWentWrong, ThemeWrapper). None are imported elsewhere. They're leftover from the pre-refactor decorative aesthetic.
- **Fix:** Delete the three component directories. After deletion, verify `npm run build` still succeeds and `grep -rn "RocketShip\|Astronaut\|<Hero" src/` returns 0 matches.

### 22. localStorage timing in Contact is fragile

- **File:** `apps/web/portfolio/src/screens/Contact.jsx:53-75`
- **Category:** Bug / Drift
- **Issue:** Stores a 15-minute "thank you" window in localStorage so reloads still show the success message. Across browsers/devices, this drifts; on shared devices it leaks intent. The audit doc already flagged this.
- **Fix:** Switch to `sessionStorage` (clears on tab close), or simply hold the state in component memory and accept that a refresh resets it. The "did the message send?" feedback is already shown synchronously after the POST.

### 23. Deprecated `mousewheel` event

- **File:** `apps/web/portfolio/src/App.jsx:84`
- **Category:** Drift / Compatibility
- **Issue:** `mousewheel` is non-standard and deprecated in Chrome (still works but throws a console warning). The handler is also defined inside `useEffect` without cleanup → memory leak on hot reload.
- **Fix:** Switch to the standard `wheel` event and add a cleanup return:
  ```jsx
  useEffect(() => {
    const onWheel = () => setNavClicked(false);
    window.addEventListener('wheel', onWheel, { passive: true });
    return () => window.removeEventListener('wheel', onWheel);
  }, []);
  ```

### 24. Old Google Analytics placeholder in index.html

- **File:** `apps/web/portfolio/index.html:54-62`
- **Category:** Drift
- **Issue:** Commented-out GA snippet with `UA-XXXXX-X` placeholder. UA was deprecated in 2023; this code is dead.
- **Fix:** Either remove the comment block entirely or replace with GA4 (`gtag.js` with an actual measurement ID) if analytics is desired. Recommend remove unless analytics is actively wanted.

### 25. About-section pronouns/collaboration card is high-tier real estate

- **File:** `apps/web/portfolio/src/screens/About.jsx:56-72`
- **Category:** UX / Editorial judgment
- **Issue:** "Collaboration: Remote-friendly | Pronouns: She/Her" is given a Paper card adjacent to the profile photo. Reasonable, but elevated above the actual specialization narrative. Some recruiters interpret this as the *primary* signal rather than a supporting one.
- **Fix (optional, judgment call — flag for user input):** Consider moving pronouns + remote-friendly to a smaller chip row beneath the bio paragraphs, freeing the primary card slot for a stronger signal (e.g., "Currently focused on: AI-infrastructure platform engineering").
- **STATUS: LEFT AS-IS — editorial judgment call for user.**

### 26. Email link from resume goes through `target="_blank"` on a `mailto:`

- **File:** `apps/web/portfolio/src/screens/Home.jsx:200`
- **Category:** Polish
- **Issue:** `target="_blank"` on a `mailto:` link triggers a no-op tab open in some browsers before the mail client launches. Harmless but ugly.
- **Fix:** Remove `target="_blank"` from the mailto IconButton.

### 27. Footer copy hard-codes "Hosted on Google Cloud" link to console

- **File:** `apps/web/portfolio/src/App.jsx:128-132`
- **Category:** Polish
- **Issue:** Link text says "Hosted on Google Cloud" pointing at `console.cloud.google.com`. Visitors clicking expecting more info hit the GCP console login.
- **Fix:** Either remove the link, point at a public GCP marketing page, or change the text to `"Hosted on Google Cloud — Firebase Hosting"` and leave it as a non-link badge.

---

## Resolved

### #1 — GitHub URL inconsistency
`Home.jsx:197` — replaced `https://github.com/RansonTesting` with `https://github.com/ranson21`. Also fixed stale reference in `config/build.sh`. `grep "RansonTesting"` returns 0 matches.

### #2 — README rewrite
`README.md` — rewrote to describe actual stack (React 18 + Vite 5 + MUI 5 + react-final-form + react-intersection-observer + Firebase Hosting). Removed all Redux, React Router, SASS, and webpack references. Updated project structure section.

### #3 — Public resume is the old purple/Calibri version
Resolved by prior agent work (Deliverable 2). Not re-done here; `public/docs/resume.html` and `public/docs/resume-extended.html` are owned by the resume agent.

### #4 — Resume download button hard-codes stale filename
Resolved by prior agent work. `AppBar.jsx:105` is owned by the AppBar agent.

### #5 — Phone number on public resume
Resolved by prior agent work (Deliverable 2). `public/docs/resume.html:194` owned by the resume agent.

### #6 — Hero name eyebrow redundancy
`Home.jsx:137-139` — removed the uppercase "ABIGAIL RANSON" eyebrow Typography block. Name now appears only in AppBar (nav context) and profile card (card identity).

### #7 — About section drift
`portfolioContent.js:29-34` — tightened `intro` and `philosophy` to two concise paragraphs per audit spec. Removed `outcomes` field from content and dropped the corresponding `<Grid item>` in `About.jsx:98`. Updated `capabilities` array to reflect platform/AI-infra positioning.

### #9 — Contact CTA copy
`portfolioContent.js:86-98` — rewrote `contactContent.intro` to surface platform engineering, internal developer platforms, AI-infrastructure, and regulated systems. Updated `preferredTopics` to match.

### #10 — Page title + meta description
`index.html` — title changed to `"Abigail Ranson — Platform Engineer & Cloud Architect"`. Meta description updated to 150-char keyword-rich string including Kubernetes, Terraform, AWS, federal compliance.

### #11 — Missing OG + Twitter card metadata
`index.html` — added full `og:type`, `og:title`, `og:description`, `og:url`, `og:image`, `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`. Image points to `https://abbyranson.com/img/og-card.png` (og-card asset generation is a separate pass — see note on #16/17).

### #12 — Missing JSON-LD Person schema
`index.html` — added `<script type="application/ld+json">` block before `</body>` with full Person schema including `knowsAbout`, `sameAs`, `email`, and `description`.

### #13 — Missing canonical + author meta
`index.html` — added `<link rel="canonical" href="https://abbyranson.com/" />` and `<meta name="author" content="Abigail Ranson" />`.

### #14 — No sitemap.xml
`public/sitemap.xml` created with two entries: `/` (priority 1.0) and `/docs/resume.html` (priority 0.8).

### #15 — robots.txt AI crawler allow lines
`public/robots.txt` — appended explicit `Allow: /` blocks for GPTBot, ClaudeBot, anthropic-ai, PerplexityBot, Google-Extended, CCBot. Added `Sitemap:` directive pointing to `https://abbyranson.com/sitemap.xml`.

### #16/#17 — Image weight (profile_pic.png 2.1 MB, logo.png 908 KB)
Asset generation not done here (out of scope for this pass). **Follow-up required:**
- `profile_pic.png` → generate `profile_pic.webp` at 800×1066 (~150 KB) for About hero, and `profile_pic_avatar.webp` at 144×144 (~25 KB) for Home avatar. Update `About.jsx:53` and `Home.jsx:229`.
- `logo.png` → replace with SVG under 5 KB, or compress to 200×200 PNG under 30 KB.
- Use `<picture>` with WebP + PNG fallback, or `srcset` for retina.
- OG card image (`img/og-card.png`) also needs to be generated: 1200×630, slate-themed with name + role + URL.

### #18 — Stale decorative assets
Confirmed 0 source references via `grep`. Deleted: `home_hero.svg`, `girl_laptop_outdoors.png`, `shiny_overlay.svg`, `simple_shiny.svg`, `under_construction.png`, `wave.svg`, `profile_pic_round.png`. Kept `something-went-wrong.png` — consumed by `SomethingWentWrong.jsx`.

### #20 — Unused dependencies
Removed from `package.json`: `@reduxjs/toolkit`, `react-redux`, `react-router-dom`, `@mui/x-data-grid`, `@mui/lab`, `clsx`, `sass`, `@fortawesome/free-brands-svg-icons`, `@fortawesome/react-fontawesome`. Ran `npm install && npm run build` — build passes. Kept `fg-loadcss` (FontAwesomeIcon component), `react-input-mask` (FormControls.jsx mask branch).

### #21 — Dead components (RocketShip, Astronaut, Hero)
Confirmed 0 external imports. Deleted `src/components/RocketShip/`, `src/components/Astronaut/`, `src/components/Hero/`. Build passes.

### #22 — localStorage timing in Contact
`Contact.jsx:53-75` — switched `localStorage` to `sessionStorage`. State clears on tab close, eliminating cross-device/shared-device leakage.

### #23 — Deprecated `mousewheel` event
`App.jsx:84` — replaced `mousewheel` with `wheel` event, added `{ passive: true }` option, added cleanup return to prevent memory leak on hot reload.

### #24 — Old GA placeholder
`index.html:54-62` — removed the commented-out UA-XXXXX-X Google Analytics block entirely.

### #26 — mailto target=_blank
`Home.jsx:200` — removed `target="_blank"` from the mailto IconButton.

### #27 — Footer "Hosted on Google Cloud" link
`App.jsx:128-132` — changed from a `<Link>` pointing at `console.cloud.google.com` to a plain `<Typography>` badge reading "Hosted on Google Cloud — Firebase Hosting". Removed now-unused `Link` import.

---

## Out of scope for this audit

- Backend (`/api/contact_me` endpoint, Firebase config) — this audit covers the front-end content surface only.
- Build/deploy pipeline (`environments/`, Terragrunt) — separate infra concern.
- The `gcp-ovpn-portal` sibling app — not part of the portfolio refactor.

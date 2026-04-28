# Portfolio UI Audit

## App Snapshot

App path:
- `apps/web/portfolio`

Stack:
- React 18
- Vite 5
- MUI 5
- Emotion
- React Final Form

Pattern:
- Single-page portfolio with anchor navigation and four sections:
  `Home`, `About`, `Projects`, `Contact`

## Findings

### 1. Theme is underpowered

Files:
- `apps/web/portfolio/src/styles/theme.js`
- `apps/web/portfolio/src/App.jsx`

Issues:
- Theme only defines `primary` and `secondary`.
- The app theme flips with `prefers-color-scheme`, but the brand intent is not actually dual-theme ready.
- Typography, spacing, surfaces, borders, and component overrides are not systematized.

Impact:
- Visual consistency depends on manual per-screen styling.

### 2. Section styling is embedded in app routing logic

Files:
- `apps/web/portfolio/src/App.jsx`
- `apps/web/portfolio/src/containers/Screen.jsx`

Issues:
- Section backgrounds are declared inline inside the `screens` array.
- `ScreenContainer` hardcodes `height: 100vh`, which creates brittle mobile layouts and constrains content growth.

Impact:
- Layout changes require editing multiple files and sections are forced into a rigid viewport model.

### 3. Screens mix content, layout, and decoration

Files:
- `apps/web/portfolio/src/screens/Home.jsx`
- `apps/web/portfolio/src/screens/About.jsx`
- `apps/web/portfolio/src/screens/Projects.jsx`
- `apps/web/portfolio/src/screens/Contact.jsx`

Issues:
- Copy is embedded directly in JSX.
- Layout is mostly inline `sx`.
- Decorative illustrations are treated as structural page elements.

Impact:
- Hard to redesign or reuse pieces without rewriting screens.

### 4. Navigation is functional but not cleanly abstracted

Files:
- `apps/web/portfolio/src/components/AppBar.jsx`

Issues:
- Desktop and mobile nav behaviors are duplicated.
- Brand styling is hardcoded in the app bar.
- The selected-state behavior is coupled to view tracking in `App.jsx`.

Impact:
- Navigation changes will be noisy and error-prone.

### 5. Form layer needs a cleanup pass

Files:
- `apps/web/portfolio/src/components/FormControls.jsx`
- `apps/web/portfolio/src/screens/Contact.jsx`

Issues:
- Generic form helpers include paths that appear unused or incomplete.
- `RadioButton` references `options` without defining or receiving it.
- Contact success timing is stored in local storage inside the screen component.

Impact:
- The contact flow works, but the abstractions are not trustworthy enough to reuse.

### 6. Package and docs likely contain drift

Files:
- `apps/web/portfolio/package.json`
- `apps/web/portfolio/README.md`

Issues:
- Suspicious dependencies: `"-"` and `"D"`.
- README mentions Redux and route management, which do not reflect the current app structure.

Impact:
- Signals outdated maintenance and makes future cleanup harder.

## Design Risks

- Current art direction depends on bright gradients and decorative illustrations that will clash with a slate/black system if left unchanged.
- Typography currently lacks a clear hierarchy or signature voice.
- The hero section is visually crowded because text, CTA, and decorative assets all compete at once.

## Technical Risks

- Full-height sections can break once copy grows or mobile spacing changes.
- Hardcoded asset references and background images make visual iteration slow.
- The scroll-selected nav state may become unreliable during layout changes.

## Priority Order

1. Theme tokens and dark surface system
2. Shared section shell and spacing rules
3. Navigation cleanup
4. Hero rewrite
5. Content extraction
6. Contact/form cleanup
7. Dependency and README cleanup

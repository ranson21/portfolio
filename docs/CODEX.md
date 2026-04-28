# Portfolio Refactor Working Guide

## Purpose

This file is the operating guide for refactoring `apps/web/portfolio`.
It exists to keep implementation decisions consistent while we modernize the site, reduce layout/theme drift, and move the visual system toward a slate/black aesthetic.

## Scope

Primary target:
- `apps/web/portfolio`

Out of scope unless explicitly needed:
- Terraform / Terragrunt infrastructure
- Other apps in this monorepo
- Deployment changes beyond what the portfolio build requires

## Current State Summary

The portfolio app is a Vite + React 18 + MUI 5 single-page site.
The current implementation works as a sectioned landing page, but styling, content, and layout logic are coupled inside each screen.
Theme usage is shallow, backgrounds are hardcoded per section, and several dependencies / utilities appear unused or outdated.

## Refactor Goals

1. Establish a durable design system with a slate/black look.
2. Separate content, layout, and visual tokens so updates do not require editing every screen.
3. Simplify the component tree and reduce one-off inline styling.
4. Improve responsive behavior and section consistency.
5. Keep the app deployable during the migration.

## Visual Direction

Design keywords:
- Slate
- Carbon
- Smoke
- Graphite
- Steel
- Soft glow accents

Target feel:
- Dark, restrained, high-contrast
- More editorial and technical
- Less gradient-heavy hero art
- Fewer novelty illustrations unless they support the brand

## Working Rules

1. Prefer incremental changes that keep `npm run build` viable.
2. Do not mix content copy updates with structural refactors unless the change is intentional and documented.
3. Centralize tokens before restyling multiple sections.
4. Prefer composition over more MUI one-off `sx` objects embedded in screens.
5. Remove dead code and dead dependencies when confirmed, but do it in explicit cleanup steps.
6. Keep assets that still serve the new design; retire decorative assets that conflict with the new direction.
7. Always test changes locally before considering the task complete. At minimum, run the relevant local validation for the touched area, such as `npm run build`, `npm run lint`, or other targeted checks.
8. Never `commit` or `push` without explicit user confirmation first.
9. Treat existing CI/CD pipelines as production-adjacent constraints. Avoid any action that could trigger them unless the user explicitly asks for it.

## Recommended Target Structure

Within `apps/web/portfolio/src`:

```text
src/
  app/
    AppShell.jsx
    sections.js
  components/
    layout/
    navigation/
    sections/
    ui/
  content/
    profile.js
    projects.js
    contact.js
  styles/
    tokens.js
    theme.js
    globals.css
  sections/
    HomeSection.jsx
    AboutSection.jsx
    ProjectsSection.jsx
    ContactSection.jsx
  utils/
```

This is a target, not a mandatory first patch.

## Implementation Order

1. Audit and remove obvious dead code paths.
2. Build the new theme tokens and global surface system.
3. Extract shared layout primitives for sections and navigation.
4. Move screen copy and project metadata into content modules.
5. Refactor one section at a time, starting with hero + app shell.
6. Replace or retire assets that do not fit the new visual system.
7. Run a final cleanup pass for imports, dependencies, and docs.

## Known Issues To Address

- Theme is mostly a thin palette wrapper and still toggles off user OS preference, which conflicts with a fixed dark brand direction.
- Section backgrounds are defined inline in `App.jsx`.
- Screens rely heavily on per-file inline styles and direct asset placement.
- `AppBar.jsx` hardcodes gradient branding and duplicated nav behavior.
- `package.json` includes suspicious dependencies like `"-"` and `"D"`.
- README content overstates parts of the app that are not reflected in the actual portfolio implementation.

## Definition Of Done

The refactor is in a good state when:
- the portfolio has a coherent slate/black theme,
- layout primitives are reusable,
- content lives outside presentation-heavy components,
- the build passes,
- docs reflect the real architecture,
- and the visual result feels intentional rather than reskinned.

## Companion Docs

- `docs/portfolio-ui-audit.md`
- `docs/portfolio-refactor-plan.md`
- `docs/portfolio-theme-brief.md`

# Portfolio Refactor Plan

## Objective

Refactor `apps/web/portfolio` into a cleaner, more maintainable single-page portfolio with a deliberate slate/black visual language.

## Guiding Principle

Do not start by repainting every component.
Start by creating the system that makes the repaint cheap and consistent.

## Phase 0: Baseline

Deliverables:
- Confirm current build behavior.
- Record current section structure and assets in use.
- Freeze the first pass scope to the portfolio app only.

Tasks:
- Run build and lint once the environment is ready.
- Remove false assumptions from docs.
- Note which existing assets are worth keeping.

## Phase 1: Foundation

Deliverables:
- A real theme system for dark surfaces and accents.
- Global tokens for color, spacing, radius, border, shadow, and typography.
- A consistent page background treatment.

Tasks:
- Replace the current thin `theme.js` with semantic tokens.
- Stop keying the visual identity off `prefers-color-scheme`.
- Define surface tiers such as `canvas`, `panel`, `elevated`, `border`, `text`, `muted`, `accent`.
- Add component overrides for `Button`, `AppBar`, `Link`, `TextField`, and `Container`.

Exit criteria:
- Shared colors and spacing come from the theme, not ad hoc `sx`.

## Phase 2: Layout Architecture

Deliverables:
- A reusable section shell.
- Unified vertical rhythm and responsive spacing.
- Cleaner app shell + navigation relationship.

Tasks:
- Replace `ScreenContainer` with a section layout primitive that supports `minHeight` instead of forcing `100vh`.
- Extract section metadata from `App.jsx`.
- Introduce a predictable content width system for narrow, standard, and wide sections.
- Reduce intersection observer coupling if it becomes fragile during refactor.

Exit criteria:
- Sections can be rearranged or restyled without changing layout logic in multiple places.

## Phase 3: Content Extraction

Deliverables:
- Copy and project metadata moved out of JSX-heavy screens.

Tasks:
- Move profile data, social links, section intros, and project links into content modules.
- Define a project card data model even if there are only a few public projects initially.
- Normalize CTA labels and destination links.

Exit criteria:
- Updating portfolio content does not require editing layout markup.

## Phase 4: Section Refactor

Deliverables:
- Refactored hero, about, projects, and contact sections aligned to the new design system.

Tasks:
- Rebuild hero first because it defines the tone of the site.
- Reduce illustration dependence and replace with stronger type, layout, and surface composition.
- Convert projects into cards or case-study previews rather than a single text block.
- Keep contact simple and trustworthy, with stronger spacing and feedback states.

Exit criteria:
- Each section uses shared primitives and matches the new visual direction.

## Phase 5: Cleanup

Deliverables:
- Leaner dependencies and more accurate docs.

Tasks:
- Remove unused dependencies and components.
- Review public assets for dead files.
- Update app README to match reality.
- Re-check resume/download paths and contact endpoint assumptions.

Exit criteria:
- The portfolio app is easier to understand than it was before the refactor started.

## Recommended Sequence Of Actual Work

1. Theme tokens and app shell
2. Navigation cleanup
3. Hero rewrite
4. Shared section shell
5. About section
6. Projects section and content model
7. Contact section and form cleanup
8. Dependency and asset cleanup
9. Final docs pass

## Suggested First Refactor PR Shape

If we keep changes reviewable, the first implementation batch should include:
- theme/token rewrite
- app shell cleanup
- section container replacement
- no deep content rewrite yet

That creates a stable base for the more visible redesign work.

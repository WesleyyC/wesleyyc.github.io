# Personal Site Revamp — Implementation Plan

**Design specification:** `docs/superpowers/specs/2026-08-23-personal-site-charlie-deets-revamp-design.md`  
**Branch:** `codex/personal-site-revamp`

## Implementation rules

- Do not overwrite the user's existing `resume.html` changes.
- Add tests before the implementation they describe and confirm each test fails for the expected reason.
- Use Jekyll-compatible HTML, Liquid, CSS, and vanilla JavaScript only.
- Preserve `CNAME`, analytics, structured data, favicon, and safe external-link behavior.
- Treat Charlie Deets's live pages as the visual and interaction reference, not as a source-code dependency.
- Record provenance for every downloaded or generated raster.

## Task 1 — Baseline and content extraction

1. Run the existing Jekyll build and record any baseline failures.
2. Extract professional entries, education, publications, and links from `resume.html` without modifying it.
3. Verify camera model facts against primary sources.
4. Select and download a representative set of authorized Instagram photographs.

## Task 2 — Contract tests

1. Add a dependency-free Ruby test suite that builds the site into a temporary directory.
2. Assert required routes exist.
3. Assert the global menu contains exactly Home, Work, Publications, and Photo.
4. Assert only Photo pages contain the Feed/Cameras segmented navigation.
5. Assert the supplied homepage copy and portrait are present.
6. Assert Work includes all four roles and both schools.
7. Assert Publications contains all source entries and safe external links.
8. Assert photo and camera images have dimensions, alt text, and local URLs.
9. Assert JavaScript exposes the menu state and keyboard dismissal behavior.

## Task 3 — Shared editorial shell

1. Create a shared Jekyll layout with the durable Impeccable direction contract as the first body child.
2. Create reusable head, global menu, and Photo navigation includes.
3. Add the editorial stylesheet with shared tokens, system themes, responsive breakpoints, focus styles, and reduced-motion handling.
4. Add a small JavaScript module for the floating menu, segmented thumb, feed shuffle, lazy-image reveal, and mobile scroll behavior.

## Task 4 — Home, Work, and Publications

1. Copy and optimize the supplied portrait into the repository.
2. Replace the landing page with the approved Home composition and copy.
3. Create structured work and education data, then render the Work page.
4. Create publication data from the résumé and render a year-grouped Publications page.
5. Keep `/resume` accessible through a quiet Work-page link.

## Task 5 — Photo Feed

1. Curate a varied set of strong Instagram photographs across subject, orientation, and time.
2. Store optimized local derivatives and an asset-provenance record.
3. Render the reference-style full-width feed with stable per-view shuffle and lazy reveal.
4. Verify no runtime request to Instagram is required.

## Task 6 — Cameras

1. Generate a consistent three-image studio series for the Contax T3, Leica M10 with Summilux-M 35mm, and Ricoh GR IV.
2. Store generation prompts/provenance and optimized derivatives.
3. Build the three-card Cameras grid.
4. Build one detail page per camera with verified specifications and concise first-person copy.
5. Include example photographs only when attribution is known.

## Task 7 — Validation and finish

1. Run the test suite and Jekyll production build.
2. Serve locally and capture desktop and mobile screenshots for Home, Work, Publications, Feed, Cameras, and one camera detail page.
3. Test the floating menu with keyboard, Escape, outside click, focus return, and active states.
4. Test light, dark, reduced-motion, and mobile layouts.
5. Run the Impeccable detector once over changed targets and fix mechanical findings.
6. Run the prescribed finish review, apply its disposition, and recapture if required.
7. Record the built system in `DESIGN.md` and ensure every raster has provenance.
8. Run final verification, inspect the diff for accidental changes, and report remaining limitations honestly.

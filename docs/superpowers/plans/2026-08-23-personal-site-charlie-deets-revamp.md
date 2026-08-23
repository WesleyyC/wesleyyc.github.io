# Personal Site Revamp — Implementation Plan

**Design specification:** `docs/superpowers/specs/2026-08-23-personal-site-charlie-deets-revamp-design.md`  
**Branch:** `codex/personal-site-revamp`

## Implementation rules

- Preserve and build on the user's existing `resume.html` content changes.
- Add tests before the implementation they describe and confirm each test fails for the expected reason.
- Use Jekyll-compatible HTML, Liquid, CSS, and vanilla JavaScript only.
- Preserve `CNAME`, analytics, structured data, favicon, and safe external-link behavior.
- Treat Charlie Deets's live pages as the visual and interaction reference, not as a source-code dependency.
- Record provenance for every downloaded or generated raster.

## Task 1 — Baseline and content extraction

1. Run the existing Jekyll build and record any baseline failures.
2. Extract professional entries, education, publications, and links from `resume.html` without modifying it.
3. Select and download a representative set of authorized Instagram photographs.

## Task 2 — Contract tests

1. Add a dependency-free Ruby test suite that builds the site into a temporary directory.
2. Assert required routes exist.
3. Assert the global menu contains exactly Home, Work, Publications, and Photo.
4. Assert no page renders a top navigation bar.
5. Assert the supplied homepage copy and portrait are present.
6. Assert Work includes all four roles and both schools.
7. Assert Publications contains all source entries and safe external links.
8. Assert photo images have dimensions, alt text, and local URLs.
9. Assert JavaScript exposes the menu state and keyboard dismissal behavior.

## Task 3 — Shared editorial shell

1. Create a shared Jekyll layout with the durable Impeccable direction contract as the first body child.
2. Create reusable head and global menu includes.
3. Add the editorial stylesheet with shared tokens, system themes, responsive breakpoints, focus styles, and reduced-motion handling.
4. Add a small JavaScript module for the floating menu, feed shuffle, lazy-image reveal, and mobile scroll behavior.

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

## Task 6 — Validation and finish

1. Run the test suite and Jekyll production build.
2. Serve locally and capture desktop and mobile screenshots for Home, Work, Publications, and Photo.
3. Test the floating menu with keyboard, Escape, outside click, focus return, and active states.
4. Test light, dark, reduced-motion, and mobile layouts.
5. Run the Impeccable detector once over changed targets and fix mechanical findings.
6. Run the prescribed finish review, apply its disposition, and recapture if required.
7. Record the built system in `DESIGN.md` and ensure every raster has provenance.
8. Run final verification, inspect the diff for accidental changes, and report remaining limitations honestly.

## Approved Revision Tasks — August 23, 2026

1. Add failing regression coverage for the renamed Home heading, Resume link, compact typography, links-only menu, 24-image pool with a 12-image random subset, sentence-case publication titles, the new arXiv paper, and the résumé's shared editorial shell.
2. Adjust Home composition and rewrite the menu state model so outside click and Escape dismiss a links-only panel.
3. Download and optimize 12 additional authorized Instagram photographs, extend provenance, and select 12 unique items per page view.
4. Normalize Publications title casing and add `Foundation models for discovery and exploration in chemical space` to both Publications and résumé.
5. Rebuild the résumé presentation without losing the user's in-progress copy changes; verify screen light/dark themes and Letter print output.
6. Repeat desktop, mobile, keyboard, randomization, dark-theme, print, detector, independent review, and fresh-build validation.

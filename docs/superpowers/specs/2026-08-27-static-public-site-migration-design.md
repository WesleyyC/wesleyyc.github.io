# Static Public Site Migration — Design Specification

**Date:** August 27, 2026

**Status:** Awaiting user review

**Scope:** Replace the Jekyll/Liquid build with directly deployable static HTML while preserving the approved portfolio and résumé experience.

## Purpose

Make DrQ.ai easier to understand, edit, test, and deploy by replacing the current Jekyll structure with a small plain-HTML site. The migration must preserve the live design and behavior while improving analytics reliability, search-engine discovery, agent discovery, structured metadata, and legacy URL hygiene.

The site is small enough that a static site generator adds more conceptual overhead than value. A small amount of repeated document metadata and navigation markup is acceptable in exchange for removing Ruby, Liquid, layouts, includes, and generator-specific deployment behavior.

## Goals

- Serve plain HTML, CSS, JavaScript, images, and text files from one explicit public directory.
- Preserve the current Home, Work, Papers, and standalone résumé experiences.
- Keep the résumé always white, free of portfolio navigation, and opened from the portfolio in a new tab.
- Preserve the Charlie Deets-inspired floating menu behavior on portfolio pages.
- Improve GA4 page-view reliability without adding a tag manager or framework.
- Add complete canonical, social, and structured metadata.
- Add conventional search-crawler and agent-discovery files.
- Ensure the retired PDF résumé URL is absent from links, metadata, and the sitemap.
- Keep deployment automatic on pushes to the default branch.

## Non-Goals

- Introducing Astro, Eleventy, Hugo, React, or another static site generator.
- Introducing a CMS or data API.
- Redesigning the approved visual system or rewriting factual page copy.
- Adding a client-side router or JavaScript rendering.
- Tracking visits to the standalone résumé.
- Restoring the retired PDF résumé at `/rsc/resume.pdf`.
- Treating `llms.txt` as a search-ranking mechanism.

## Architecture

### Public source tree

The deployable website lives under `public/`:

```text
public/
  index.html
  work/index.html
  papers/index.html
  publications/index.html
  resume/index.html
  404.html
  css/site.css
  js/site.js
  img/...
  favicon.ico
  CNAME
  robots.txt
  sitemap.xml
  llms.txt
```

`public/publications/index.html` is a minimal compatibility page that immediately redirects visitors and search engines to `/papers/` and declares `/papers/` as canonical.

The portfolio pages repeat their small `<head>` and menu fragments directly. The résumé remains a single self-contained HTML document with inline CSS. Repetition is limited to three portfolio pages and is guarded by contract tests.

### Removed build system

After route parity is proven, remove the Jekyll-only surface:

- `_config.yml`
- `_layouts/`
- `_includes/`
- `Gemfile` and `Gemfile.lock`
- Jekyll front matter and Liquid expressions
- the unused `assets/css/style.scss` compatibility file

Existing project documentation, tests, and source assets outside `public/` remain in the repository but are not deployed.

### Deployment

Use a GitHub Pages Actions workflow that:

1. Checks out the default branch.
2. Configures GitHub Pages.
3. Uploads `public/` unchanged with `actions/upload-pages-artifact`.
4. Deploys it with `actions/deploy-pages`.

This is packaging and deployment, not a compilation step. GitHub Pages must be configured to use **GitHub Actions** as its publishing source. The artifact boundary prevents repository documentation, tests, and local output files from becoming public web routes.

## Route and Experience Contracts

### Portfolio routes

- `/` — Home
- `/work/` — Work and Education
- `/papers/` — Papers archive

These routes share the current portfolio stylesheet, menu script, favicon, analytics, social metadata, and responsive behavior. Their content remains server-readable without JavaScript.

### Résumé

- `/resume` and `/resume/` resolve to the same standalone résumé document.
- Portfolio résumé links use `target="_blank"` and `rel="noopener noreferrer"`.
- The résumé is always white on screen and in print.
- It contains no floating menu, site credit, portfolio stylesheet, portfolio script, or GA4 tag.
- It gains a canonical URL, descriptive title, Open Graph/Twitter metadata, and structured data without changing the visible document.

### Retired PDF URL

`/rsc/resume.pdf` remains absent and returns the GitHub Pages not-found response. It is excluded from all internal links, `sitemap.xml`, structured data, `llms.txt`, and social metadata.

Because a static GitHub Pages artifact cannot emit an HTTP `410 Gone` response, accelerated removal of the already indexed URL is an operational Search Console task. The codebase can guarantee only that the URL is unlinked, uncited, and unavailable.

## Analytics

GA4 measurement ID `G-Y2HPVMHTRR` remains on Home, Work, and Papers.

The portfolio documents use Google's normal asynchronous `gtag.js` installation in `<head>` rather than waiting for `window.load` and a subsequent idle callback. This favors complete measurement of short visits while retaining asynchronous loading. No analytics code is included on the résumé or compatibility redirect page.

Automated tests verify that:

- the three portfolio pages contain the expected measurement ID exactly once;
- the résumé and redirect page do not contain it;
- no retired analytics loaders or duplicate tag initializers remain.

Live validation confirms tag presence and lack of console errors. Actual event receipt is verified separately in GA4 Realtime or DebugView because repository and page inspection cannot prove property ingestion.

## SEO and Social Metadata

Every indexable page includes:

- a unique, descriptive `<title>`;
- a concise meta description;
- one self-referential canonical URL;
- Open Graph title, description, URL, type, and image;
- Twitter card, title, description, and image;
- favicon and theme metadata;
- semantic heading structure and visible factual content matching its metadata.

Preserve the current portrait as the social-preview image during this migration. A dedicated wide social card is a separate visual-design task and is not required for launch.

## Structured Data

All structured data uses one stable identity:

```text
https://drq.ai/#wesley
```

- Home: `ProfilePage` with `mainEntity` set to the canonical `Person`.
- Work: `WebPage` whose `about` references that Person.
- Papers: `CollectionPage` with an `ItemList` of visible paper titles and canonical paper URLs.
- Résumé: `ProfilePage` or `WebPage` about the same Person, with no invisible claims.

Organization affiliations, job title, profile links, and paper data must stay consistent with visible page content.

## Search and Agent Discovery

### `robots.txt`

The crawler policy:

- allows normal web search crawling;
- allows `OAI-SearchBot`, `ChatGPT-User`, `Claude-SearchBot`, and `Claude-User` for search and user-requested retrieval;
- disallows training-oriented `GPTBot` and `ClaudeBot` by default;
- advertises `https://drq.ai/sitemap.xml`.

This separates discoverability from permission to collect pages for model training.

### `sitemap.xml`

The hand-maintained sitemap contains only canonical public routes:

- `https://drq.ai/`
- `https://drq.ai/work/`
- `https://drq.ai/papers/`
- `https://drq.ai/resume`

It excludes the redirect route and retired PDF.

### `llms.txt`

The concise agent-facing file includes:

- Wesley's name and short professional identity;
- canonical links to Home, Work, Papers, and Résumé;
- key areas of work: olfaction, machine learning, scientific infrastructure, cellular imaging, genomics, and protein structure;
- canonical LinkedIn, Scholar, GitHub, and Osmo links;
- a note that visible HTML pages are authoritative.

It contains no private information or claims absent from the public site.

## Accessibility, Performance, and Responsive Behavior

The migration preserves the current contracts:

- semantic landmarks and heading hierarchy;
- keyboard-operable menu, Escape dismissal, outside-click dismissal, and focus return;
- visible `focus-visible` treatment;
- minimum 44px touch targets;
- reduced-motion behavior;
- responsive portrait sources with explicit dimensions;
- safe-area-aware mobile menu margins and scroll-direction visibility;
- the homepage credit in document flow rather than overlaid content;
- the résumé's print margins and page-break strategy.

Removing Jekyll must not alter rendered pixels, layout geometry, URLs, or interaction timing except for the intentionally earlier analytics request.

## Testing and Acceptance

Implementation is accepted only after:

1. Contract tests read `public/` and verify all routes, canonical URLs, metadata, analytics inclusion/exclusion, crawler files, sitemap entries, redirect behavior, and retired-PDF absence.
2. Menu behavior tests pass unchanged against `public/js/site.js`.
3. A static-site validation script runs without Ruby or Bundler.
4. A local static server returns `200` for canonical routes and `404` for `/rsc/resume.pdf`.
5. Desktop and mobile browser QA covers Home, Work, Papers, and Résumé at 1440×900, 390×844, 320×568, and 844×390.
6. Keyboard and reduced-motion checks pass.
7. Print preview confirms consistent résumé margins and intended page breaks.
8. The deploy artifact contains only approved public files and remains below the current 500 KB site-size contract unless a reviewed social image changes that budget.
9. GitHub Pages deploys successfully from Actions and the live canonical routes, metadata, analytics tag, crawler files, and retired-PDF 404 are verified.

## Operational Follow-Up

After deployment:

1. Submit `https://drq.ai/sitemap.xml` in Google Search Console.
2. Request indexing for `/`, `/work/`, `/papers/`, and `/resume`.
3. Request temporary removal of `/rsc/resume.pdf`, then allow its persistent 404 to remove it from the index permanently.
4. Confirm page views in GA4 Realtime or DebugView.
5. Recheck Google results after recrawling; the code change cannot guarantee immediate index updates.

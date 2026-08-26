# CLAUDE.md

This file gives code agents a concise map of the current DrQ.ai portfolio.

## Project

DrQ.ai is Wesley Wei Qian's Jekyll portfolio, hosted on GitHub Pages with the
custom domain in `CNAME`. The visual system is a quiet editorial archive:
native system type, a monochrome portrait, restrained prose, and one shared
floating navigation control.

Primary routes:

- `/` — portrait, introduction, and LinkedIn / Scholar / Resume / Email links
- `/work/` — work and education summary
- `/papers/` — complete paper list
- `/publications/` — legacy redirect to `/papers/`
- `/resume` — standalone, always-white HTML resume with three-page print styling

Photo is retired. Do not reintroduce a Photo route, feed, navigation item, or
image archive without an explicit product decision.

## Commands

```bash
bundle install
bundle exec jekyll serve
bundle exec jekyll build
./script/test-site
```

`./script/test-site` is the canonical verification command. It builds into a
fresh temporary directory before running the site contracts.

## Architecture

- `_config.yml` — metadata, redirect plugin, and production exclusions
- `_layouts/default.html` — shared shell for Home, Work, and Papers
- `_includes/head.html` — metadata, versioned site CSS, SVG favicon, ICO fallback
- `_includes/global-menu.html` — Home / Work / Papers floating navigation
- `_includes/js.html` — structured data, menu JavaScript, idle-scheduled analytics
- `index.html` — homepage copy and hard-coded social/contact links
- `work.html` — work and education records
- `publications.html` — canonical Papers content and legacy redirect metadata
- `resume.html` — layout-free resume with inline screen/mobile/print CSS and no shared portfolio CSS/JavaScript
- `css/site.css` — shared light/dark responsive design system
- `js/site.js` — menu measurement, motion, focus, and dismissal behavior
- `assets/css/style.scss` — intentionally empty override for GitHub Pages' unused
  Primer stylesheet
- `img/profile/PROVENANCE.md` — source record for the portrait; excluded from the
  production build
- `test/site_contract_test.rb` — routes, content, accessibility, performance,
  favicon, analytics, and print contracts

## Content and Design Rules

- Homepage social/contact links live directly in `index.html`; they are not
  generated from `_config.yml`.
- Primary navigation is exactly Home, Work, and Papers.
- The Home Resume link opens `/resume` in a new tab. The HTML resume is the
  detailed source of truth and printable artifact; keep it always white and
  free of the portfolio menu, shared CSS/JavaScript, analytics, and dark mode.
- Keep external links on new tabs with `rel="noopener noreferrer"` where the
  surrounding page follows that convention.
- Preserve the shared 680px editorial measure, paired light/dark colors,
  visible keyboard focus, 44px touch targets, and reduced-motion support.
- The Charlie Deets credit remains in homepage document flow so it cannot
  overlap content on short mobile viewports.
- The rounded-square favicon uses a transparent canvas in both SVG and ICO.
- Product and visual decisions live in `PRODUCT.md` and `DESIGN.md`.

## Performance and Deployment

- The production build must remain below 500,000 bytes.
- Do not ship Gemfiles, design records, tests, provenance notes, retired media,
  an empty feed, or the default Primer theme CSS.
- The portrait uses 360px and 720px WebP sources with the original JPG as its
  fallback and Open Graph image.
- Google Analytics is created only on the three portfolio routes by the shared
  idle-scheduled loader in `_includes/js.html`; the standalone résumé has no
  analytics or JavaScript.
- GitHub Pages deploys from `master`; after pushing, verify the deployed commit,
  `/favicon.ico`, the versioned `/css/site.css`, all primary routes, and mobile
  geometry.

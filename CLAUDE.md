# CLAUDE.md

This file gives code agents a concise map of the current DrQ.ai portfolio.

## Project

DrQ.ai is Wesley Wei Qian's plain-static portfolio, hosted on GitHub Pages with the custom domain shipped from `public/CNAME`. The visual system is a quiet editorial archive: native system type, a monochrome portrait, restrained prose, and one shared floating navigation control.

Primary routes:

- `/` — portrait, introduction, and LinkedIn / Scholar / Resume / Email links
- `/work/` — work and education summary
- `/papers/` — complete paper list
- `/publications/` — compatibility redirect to `/papers/`
- `/resume` — standalone, always-white HTML résumé with three-page print styling

Photo is retired. Do not reintroduce a Photo route, feed, navigation item, or image archive without an explicit product decision.

## Commands

```bash
./script/test-site
python3 -m http.server 4000 --directory public
```

`./script/test-site` is the canonical verification command. It reads the exact static artifact in `public/`; no Ruby gems, Jekyll build, Node package installation, or generator is required.

## Architecture

- `public/index.html` — Home, complete metadata, ProfilePage schema, and GA4
- `public/work/index.html` — work and education, WebPage schema, and GA4
- `public/papers/index.html` — paper archive, CollectionPage/ItemList schema, and GA4
- `public/publications/index.html` — noindex compatibility redirect to Papers
- `public/resume/index.html` — self-contained résumé with inline screen/mobile/print CSS and no portfolio JavaScript or analytics
- `public/css/site.css` — shared light/dark responsive design system
- `public/js/site.js` — menu measurement, motion, focus, and dismissal behavior
- `public/robots.txt`, `public/sitemap.xml`, `public/llms.txt` — search and agent-discovery contracts
- `.github/workflows/deploy-pages.yml` — uploads `public/` unchanged to GitHub Pages
- `img/profile/PROVENANCE.md` — repository-only source record for the portrait
- `test/static_public_contract_test.rb` — routes, metadata, analytics, crawler policy, structured data, deployment, and size contracts
- `test/menu_scroll_behavior_test.js` — menu interaction contract

## Content and Design Rules

- Primary navigation is exactly Home, Work, and Papers.
- The Home Resume link opens `/resume` in a new tab. Keep the résumé always white and free of portfolio navigation, shared CSS/JavaScript, analytics, and dark mode.
- Keep external links on new tabs with `rel="noopener noreferrer"` where the surrounding page follows that convention.
- Preserve the shared 680px editorial measure, paired light/dark colors, visible keyboard focus, 44px touch targets, and reduced-motion support.
- The Charlie Deets credit remains in homepage document flow so it cannot overlap content on short mobile viewports.
- The rounded-square favicon uses a transparent canvas in both SVG and ICO.
- Product and visual decisions live in `PRODUCT.md` and `DESIGN.md`.
- Update repeated portfolio head or menu markup on all three portfolio pages and extend the contracts when their behavior changes.

## Analytics, Discovery, and Deployment

- GA4 measurement ID `G-Y2HPVMHTRR` appears only on Home, Work, and Papers through Google's asynchronous head snippet.
- The résumé and compatibility redirect remain untracked.
- Canonical URLs, social metadata, and JSON-LD must agree with visible page content.
- `sitemap.xml` contains only canonical routes. `/rsc/resume.pdf` stays absent and uncited.
- Search/retrieval crawlers are allowed; GPTBot and ClaudeBot training crawlers are disallowed by the current policy.
- The deploy artifact must remain below 500,000 bytes and contain only `public/`.
- GitHub Pages deploys through the Actions workflow on `master`. After pushing, verify the deployed commit, canonical routes, `/favicon.ico`, `/robots.txt`, `/sitemap.xml`, `/llms.txt`, GA tag presence, and the retired PDF's 404 response.

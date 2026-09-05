# DrQ.ai

Wesley Wei Qian’s personal website: [drq.ai](https://drq.ai/). GitHub Pages serves the plain HTML, CSS, and JavaScript in `public/` directly. There is no build step or runtime package installation.

## Local development

From the repository root, serve the site with Python 3:

```sh
python3 -m http.server 8765 --directory public --bind 127.0.0.1
```

Open [localhost:8765](http://127.0.0.1:8765/); stop with Ctrl+C. Internal links stay on the preview host and resolve on `https://drq.ai` when published. Canonical and structured-data URLs retain the production domain. The deployment checks reject localhost and loopback URLs in published text assets and verify that `public/CNAME` is `drq.ai`. To inspect the custom error page locally, open `/404.html` directly; Python uses its own response for missing paths.

CI uses Ruby 3.3 and Node.js 22. Install the two Ruby test dependencies, then run:

```sh
gem install minitest rexml --no-document
script/test-site
git diff --check
```

The runner prefers Homebrew Ruby at `/opt/homebrew/opt/ruby/bin/ruby` when present. In that case, install its gems with `/opt/homebrew/opt/ruby/bin/gem install minitest rexml --no-document`. Otherwise it uses Ruby from `PATH`. JavaScript tests use Node’s built-in modules.

## Source map

| File | Responsibility |
|---|---|
| `public/index.html` | Introduction, portrait, contextual links, and Studio dialog |
| `public/experience/index.html` | Concise work and education summaries |
| `public/papers/index.html` | Publication list and matching JSON-LD |
| `public/resume/index.html` | Detailed professional record and standalone screen/print styles |
| `public/css/site.css` | Shared portfolio layout, themes, and components |
| `public/js/site.js` | Progressively enhanced floating navigation |
| `public/js/studio-video.js` | On-demand film activation and cleanup |
| `public/robots.txt`, `public/sitemap.xml`, `public/llms.txt` | Search and agent discovery |
| `PRODUCT.md`, `DESIGN.md` | Product intent and design decisions |
| `docs/media-sources.md` | Studio film provenance |

## Content and asset updates

- Update detailed roles in the resume, then the shorter Experience and Home accounts as relevant. Keep visible copy and person metadata consistent; preserve the personal voice and use verified facts.
- A paper appears in the resume, visible Papers list, and Papers JSON-LD. Keep its title, URL, year, and fragment ID consistent. Preserve existing IDs for shared links. When adding a paper, update the inventory and counts in `test/static_public_contract_test.rb`.
- Primary navigation is repeated in Home, Experience, and Papers; update them together. The resume remains a standalone white document with no portfolio scripts or analytics.
- Bump a changed CSS or JavaScript asset’s `?v=` key on every page that loads it and update the cache-key test. The custom 404 page loads shared CSS too.
- Use root-relative internal links and absolute canonical URLs. Keep retired routes and the old PDF out of `public/`.

The core public artifact stays below 500,000 bytes. The approved Studio film is the only exception; the total stays below 2,000,000 bytes. The film loads only after activation. Keep screenshots, review reports, and temporary files in ignored `output/`, outside `public/`.

## Verification and publishing

`script/test-site` checks static contracts, content consistency, budgets, both scripts’ syntax, and menu/film behavior. Its browser API doubles verify application wiring, not rendered CSS, native dialog behavior, or print pagination.

Check affected pages in a real browser at 320px and 390px portrait, 844×390 landscape, and desktop; include dark mode and reduced motion when affected. Check Tab, Shift+Tab, Enter, and Escape. After scrolling hides the mobile menu, Tab must restore it, and the menu must remain visible near the page end. Navigation also works without JavaScript.

For film changes, check actual playback, deferred loading, Close/Escape cleanup, focus return, modified clicks, and native video controls. For resume content or print-style changes, inspect **all three Letter pages** in Chrome print preview with no browser margins or headers/footers. Verify entries are not clipped or split, and page 3 begins with “Evaluating attribution for graph neural networks.” Save a PDF through the browser’s Print command when needed.

`.github/workflows/deploy-pages.yml` validates pull requests and `main`, then deploys `public/` from `main` only after validation succeeds. Local edits do not publish the site. After a release, verify the affected live pages and versioned assets as well as the workflow result.

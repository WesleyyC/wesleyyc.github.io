# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

People discovering Wesley through search, LinkedIn, a shared link, or an AI agent who want to understand his work, verify his publications, and find a readable professional record.

## Product Purpose

Present Dr. Wesley Wei Qian as a technically ambitious, playful builder: creating olfactory intelligence, leading engineering and research, and publishing scientific work. Success means a visitor can quickly understand what Wesley does, explore credible detail, and remember the person behind the credentials.

## Positioning

The site connects an unusual professional focus—giving computers a sense of smell—with a concise record across AI, product engineering, science, data operations, and publications.

## Operating Context

The site is a public personal portfolio reached through `drq.ai`. Visitors may arrive from LinkedIn, Google Scholar, a shared résumé, or a publication. The HTML résumé at `/resume/` remains the printable source of detailed professional history.

## Capabilities and Constraints

- Plain static HTML hosted through a direct GitHub Pages artifact deployment; no site generator or runtime build is required.
- The core site stays below 500 KB. The user-approved Osmo Studio film is a separate on-demand asset; the total deploy artifact stays below 2 MB. Repository-only files, retired media, and obsolete routes remain excluded.
- Primary navigation contains Home, Experience, and Papers; Experience lives at `/experience/`, Papers lives at `/papers/`, and the retired `/work/` and `/publications/` routes are intentionally absent.
- Home introduces the person, with quiet contextual links into Experience and Papers. The phrase “turning scent prompting into a product” opens the 27-second Osmo Studio film only on request. Writing and expanded case studies are deferred.
- Semantic HTML is authoritative for people, search engines, and agents. Canonical URLs, the sitemap, `llms.txt`, and structured data describe the same four public pages.
- Pull requests and main-branch changes run `script/test-site`; Pages deployment depends on validation.
- `public/resume/index.html` is the detailed, printable professional record. It opens from Home or Experience in a new tab and remains a standalone, always-white document without portfolio navigation, analytics, or shared portfolio CSS/JavaScript.
- The custom domain, analytics, structured data, and relevant metadata must continue to work.

## Brand Commitments

- Public name: Wesley Wei Qian; professional title may use Dr. Wesley Wei Qian where context calls for it.
- Voice: playful, curious, technically precise, and not overly serious.
- Approved homepage statement: “I lead engineering and research at Osmo, where my team works across AI, product engineering, science, and data operation. Together, we’re turning scent prompting into a product that helps brands scale their fragrance businesses.”
- The visual and interaction reference is Charlie Deets's personal site, especially its restrained editorial layout and floating bottom menu.
- Homepage portrait: the supplied black-and-white photograph.

## Evidence on Hand

- Professional chronology, education, publication metadata, and publication links in `public/resume/index.html`.
- Current professional copy and role descriptions from Wesley's LinkedIn profile.
- Fifteen publication entries, including “Foundation models for discovery and exploration in chemical space.”
- Supplied homepage portrait at the local attachment path recorded in the approved design specification.
- No testimonials, customer logos, performance benchmarks, or commercial claims are available and none should be fabricated.

## Product Principles

1. Lead with the person, then make evidence easy to reach.
2. Let technical specificity and playfulness coexist.
3. Use quiet presentation so the work and portrait carry the page.
4. Keep factual detail traceable to the résumé, LinkedIn, publications, or verified product sources.
5. Prefer durable local content and small, understandable web technology.

## Accessibility & Inclusion

All routes must be keyboard-operable, responsive, usable with reduced motion, and structured with semantic navigation and headings. Portfolio routes must remain readable in light and dark system themes; the standalone résumé deliberately remains white in every system theme. Interactive targets must remain comfortable on touch screens and expose correct accessible state.

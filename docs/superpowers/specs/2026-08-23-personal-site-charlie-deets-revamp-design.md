# Personal Site Revamp — Approved Design Specification

**Date:** August 23, 2026  
**Branch:** `codex/personal-site-revamp`  
**Status:** Approved direction; awaiting specification review before implementation

## Purpose

Revamp Dr. Wesley Wei Qian's personal site into a quiet, playful editorial portfolio closely matching the visual system and interaction model of [charliedeets.com](https://charliedeets.com/), while using Wesley's original biography, résumé, publications, photographs, and camera imagery.

The reference governs layout, typography, spacing, navigation behavior, responsive behavior, light/dark presentation, and motion. Charlie Deets's prose, photographs, and source code are not project assets and will not be copied.

## Goals

- Make the site feel personal, simple, and confident rather than like a conventional technical résumé.
- Use the same bottom-left floating menu pattern as the reference across the site.
- Present professional history and education in a concise editorial format.
- Create a year-organized publication archive from the existing résumé content.
- Turn selected Instagram photographs into a locally hosted, immersive photo feed.
- Present Wesley's three cameras with consistent studio-style rendered imagery.
- Preserve the existing self-contained résumé at `/resume` without rewriting or restyling it as part of this project.
- Maintain responsive, accessible, fast, GitHub Pages-compatible output.

## Information Architecture

The global menu contains exactly four items:

1. Home — `/`
2. Work — `/work/`
3. Publications — `/publications/`
4. Photo — `/photo/`

Photo is the only section with a fixed top segmented navigation:

1. Feed — `/photo/`
2. Cameras — `/photo/cameras/`

Each camera card may open a dedicated detail page:

- `/photo/cameras/contax-t3/`
- `/photo/cameras/leica-m10/`
- `/photo/cameras/ricoh-gr-iv/`

Writing, Timeline, Albums, and Recipes are explicitly out of scope. Writing can be added later without changing the global navigation system.

## Reference Study and Visual System

### Global page foundation

- System UI font stack matching the reference.
- Light theme: warm off-white `#fafafa` background, near-black headings, charcoal body text, muted gray supporting text.
- Dark theme follows `prefers-color-scheme: dark` with a `#171717` background, light gray headings, and subdued body copy.
- Links are understated and primarily indicated through color or a subtle underline interaction.
- Motion respects `prefers-reduced-motion`.

### Global floating menu

- Fixed at 32px from the left and bottom on desktop.
- Collapsed size: approximately 82 × 48px, pill radius, translucent white surface, 20px backdrop blur, fine highlight border, and soft shadow.
- Collapsed label: `Menu`; expanded label: `Close`.
- Expanded width: approximately 149px; height is calculated for four links plus the trigger.
- Expansion uses spring-like width and height transitions with lightly staggered link entrances.
- Active page uses `aria-current="page"` and stronger text contrast.
- The button exposes `aria-expanded` and an accessible `aria-label`.
- Escape and outside click close the panel, returning focus to the trigger.
- At 720px and below, the menu moves to bottom-center, 20px above the viewport edge; the expanded state sits 12px above the edge.
- On long mobile photo pages, the control may hide while scrolling down and return while scrolling up, provided this behavior is reliable and does not harm keyboard access.

### Editorial content pages

- Work and Publications use a centered 680px reading column.
- Desktop content begins around 120px from the top and retains generous bottom clearance for the floating menu.
- Primary section headings are roughly 31–32px with tight line height and strong weight.
- Entry text is roughly 19px with a 32px line height on desktop and 19px/30px on mobile.
- Mobile pages use 24px side margins and approximately 48px top spacing.

## Page Specifications

### Home

Desktop uses the same visual proportions as the reference:

- Maximum content width: approximately 850px.
- Two-column flex layout.
- Portrait: 300 × 300px, `object-fit: cover`, 24px corner radius.
- Text column: approximately 486px.
- Column gap: 64px at normal desktop widths and up to 92px on wide displays.
- Heading: approximately 36px/42px, bold.
- Body: approximately 21px/34px, muted gray.
- Paragraph spacing: approximately 28px.

Below 880px, the layout becomes a vertical stack with a 32px gap. The portrait becomes 40% of the container with a minimum width of 180px. At phone widths, it is 180 × 180px with a 16px radius.

The supplied black-and-white portrait is the homepage image:

`/var/folders/6m/7_b9jr8j5tj4236ycctp47cw0000gn/T/codex-clipboard-339bd0ff-c90f-4616-8ff7-095cc42cb175.jpg`

Approved homepage copy:

> Hi, I'm Wesley.
>
> I build machines that can smell—and the systems that turn that strange ability into useful things.
>
> I lead engineering and research at Osmo, where my team works across AI, product engineering, science, and data operation.
>
> Previously, I worked on olfaction and genomics at Google, protein structure at DeepMind, and machine learning at Uber.

LinkedIn and Google Scholar appear as quiet inline text links. An email link may be included alongside them if it does not make the line visually crowded.

### Work

Work follows the structure and density of the reference Work page. It is not a full résumé reproduction.

Sections:

1. Work
   - Osmo — September 2022 to present
   - Google — May 2018 to September 2022
   - DeepMind — 2021
   - Uber — 2016 and 2017
2. Education
   - University of Illinois Urbana-Champaign — PhD, Computer Science, 2017–2022
   - Brandeis University — BS, Computer Science and Neuroscience, 2013–2017

Each entry contains the organization, date range, and a compact one- or two-line description distilled from the existing résumé and LinkedIn profile. The copy should preserve Wesley's playful tone while remaining factual and technically precise.

A subtle `Full résumé` link points to `/resume` near the end of the page. The existing `resume.html` is treated as user-owned in-progress work and must not be overwritten by this revamp.

### Publications

Publications adapts the reference Writing archive without its category filter.

- One centered 680px column.
- Publications grouped by year from newest to oldest.
- Each paper title is the primary linked line.
- Venue and authorship appear as muted supporting information where useful.
- Existing paper URLs and publication facts come from `resume.html`.
- All fourteen existing publication entries are retained unless a source is clearly incomplete or duplicated.
- External links open safely in a new tab.

### Photo Feed

- Fixed top segmented navigation, centered 32px from the top on desktop and 16px on mobile.
- Track height: approximately 46px with 4px padding, translucent surface, 20px backdrop blur, white highlight border, and soft shadow.
- Active segment uses a white sliding thumb with subtle shadow; labels are approximately 15px.
- With only `Feed` and `Cameras`, the control uses content-fit widths rather than retaining the four-item reference width.
- Main feed begins approximately 110px from the top.
- Maximum image width: 1200px.
- Desktop images use 16px corner radii and approximately 40px vertical spacing.
- At 720px and below, feed spacing becomes 16px and the page uses 16px outer margins.
- Images lazy-load and fade in. Each image includes useful alt text when the subject can be identified; decorative ambiguity is described minimally rather than invented.

The feed uses a curated local set of Wesley's strongest photographs from the supplied Instagram account. The files are hosted locally rather than fetched from Instagram at runtime. Their display order is shuffled on each fresh visit while remaining stable for the duration of that page view.

No EXIF panel is shown unless reliable metadata is available. Camera attribution must not be inferred solely from visual style.

### Cameras

The camera index uses the reference Cameras presentation:

- 1200px maximum grid width.
- Three columns on desktop with a 20px gap.
- Two columns at 960px and below.
- One column at 720px and below with a 16px gap.
- Cards use a white or dark-gray surface, 16px corner radius, light shadow, and a 2px upward hover translation.
- Product image area uses a 3:2 aspect ratio.
- Camera name is approximately 20px with compact muted badges beneath.

Cameras:

1. Contax T3
2. Leica M10 with Summilux-M 35mm lens, confirmed from Wesley's Instagram post
3. Ricoh GR IV

Camera art is generated as a consistent studio series: accurate product silhouette and controls, soft neutral surface, diffuse side light, restrained shadows, no hands, no decorative props, and enough negative space to crop consistently to 3:2. Generated images must not contain invented brand text or malformed engravings; visible labels are removed or corrected if generation cannot render them reliably.

Each camera detail page follows the reference pattern: a large hero render, a 680px details column, concise specifications, a short first-person note, and a grid of example photographs when camera attribution is known. Product specifications are verified against current official manufacturer or authoritative archival sources before publication.

## Content and Asset Sources

- Homepage biography and professional history: Wesley's LinkedIn profile and existing résumé.
- Publication metadata and URLs: `resume.html`.
- Homepage portrait: supplied local JPEG.
- Photo feed: selected images from `@the.stoddard.temple`, downloaded with user authorization and stored in the repository in web-optimized formats.
- Camera ownership and Leica lens: user-provided details plus the Instagram caption identifying `#m10 #summilux35`.
- Camera product facts: verified separately before implementation.

Downloaded social images are treated as content assets only. Instagram captions or page UI are not reproduced unless specifically selected and relevant.

## Technical Architecture

- Remain compatible with Jekyll and GitHub Pages.
- Introduce a shared editorial layout for Home, Work, Publications, and Photo while keeping `resume.html` self-contained.
- Use reusable includes for the global menu and Photo segmented navigation.
- Use a small vanilla JavaScript module for menu state, Escape/outside-click handling, photo segment thumb positioning, and feed shuffling.
- Centralize visual tokens and responsive rules in a new site stylesheet.
- Prefer Jekyll data files for work history, publications, photographs, and cameras when doing so makes content safer to update.
- Retain `CNAME`, analytics, structured data, favicon, and relevant social metadata.
- Remove obsolete landing-page dependencies such as particles.js and Font Awesome only after confirming they are unused by all redesigned routes.

## Accessibility and Performance

- Semantic `main`, `nav`, `section`, and heading structure.
- Keyboard-operable menu and segmented navigation.
- Visible `focus-visible` treatment with sufficient contrast.
- `aria-current="page"` for active global and Photo links.
- `aria-expanded` and descriptive label on the Menu trigger.
- Escape and outside-click dismissal.
- Minimum 44px touch targets.
- Responsive image dimensions to reduce layout shift.
- Web-optimized JPEG/WebP or AVIF assets with sensible source sizes.
- Lazy loading below the first viewport.
- Reduced-motion mode removes spring and fade movement without hiding content.

## Validation

Implementation is accepted only after:

1. Automated checks confirm all required routes, menu labels, active states, image alt attributes, and external-link safety.
2. `bundle exec jekyll build` succeeds.
3. Desktop visual QA at 1280 × 720 confirms the reference proportions.
4. Mobile visual QA around 390 × 844 confirms stacking, menu centering, Photo navigation, and one-column camera cards.
5. Keyboard QA confirms tab order, Menu open/close, Escape dismissal, outside-click dismissal, and visible focus.
6. Light and dark theme screenshots are reviewed.
7. Existing `/resume` content and custom-domain configuration remain intact.

## Explicit Non-Goals

- Copying Charlie Deets's text, photographs, recipes, or personal content.
- Adding Writing in this pass.
- Live Instagram embedding or runtime dependency on Instagram.
- Rewriting the résumé.
- Adding a CMS, frontend framework, or build system beyond the current Jekyll setup.
- Publishing or deploying before local verification and user review.

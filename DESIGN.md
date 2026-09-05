---
name: "DrQ.ai Personal Portfolio"
description: "A quiet editorial portfolio for engineering, research, and scientific work."
colors:
  background-light: "#fafafa"
  heading-light: "#111111"
  text-light: "#2e2e2e"
  muted-light: "#6e6e6e"
  hairline-light: "rgba(17, 17, 17, 0.1)"
  menu-surface-light: "rgba(255, 255, 255, 0.88)"
  menu-open-surface-light: "rgba(244, 244, 244, 0.94)"
  menu-link-light: "#555555"
  menu-link-hover-light: "#333333"
  menu-link-active-light: "#111111"
  menu-border-light: "rgba(255, 255, 255, 0.75)"
  background-dark: "#171717"
  heading-dark: "#dfdfdf"
  text-dark: "#a1a1a1"
  muted-dark: "#a3a3a3"
  hairline-dark: "rgba(255, 255, 255, 0.1)"
  menu-surface-dark: "rgba(38, 38, 38, 0.88)"
  menu-open-surface-dark: "rgba(38, 38, 38, 0.92)"
  menu-link-dark: "#aaaaaa"
  menu-link-hover-dark: "#d0d0d0"
  menu-link-active-dark: "#dfdfdf"
  menu-border-dark: "rgba(255, 255, 255, 0.1)"
typography:
  display:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "30px"
    fontWeight: 700
    lineHeight: "36px"
    letterSpacing: "-0.025em"
  headline:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "31.5px"
    fontWeight: 700
    lineHeight: "37.8px"
    letterSpacing: "-0.025em"
  body-large:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "18px"
    fontWeight: 400
    lineHeight: "29px"
  body:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "19px"
    fontWeight: 400
    lineHeight: "32px"
  label:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: "28px"
  meta:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: "26px"
  credit:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "12px"
    fontWeight: 400
    lineHeight: "18px"
  home-display-mobile:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "28px"
    fontWeight: 700
    lineHeight: "34px"
  resume-display-mobile:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "34px"
    fontWeight: 700
    lineHeight: "34px"
  resume-body-mobile:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: "1.55"
  resume-meta-mobile:
    fontFamily: "-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: "1.4"
rounded:
  focus-tight: "2px"
  image: "16px"
  menu-focus: "20px"
  portrait: "24px"
  menu-collapsed: "25px"
  menu-open: "26px"
  pill: "999px"
spacing:
  mobile-inset: "12px"
  page-gutter: "24px"
  paragraph: "28px"
  menu-desktop-inset: "32px"
  section: "48px"
  home-gap: "64px"
  home-gap-wide: "72px"
  editorial-top: "120px"
components:
  home-portrait:
    backgroundColor: "{colors.background-light}"
    rounded: "{rounded.portrait}"
    width: "300px"
    height: "300px"
  menu-collapsed-light:
    backgroundColor: "{colors.menu-surface-light}"
    textColor: "{colors.menu-link-hover-light}"
    typography: "{typography.label}"
    rounded: "{rounded.menu-collapsed}"
    width: "82px"
    height: "48px"
  menu-open-light:
    backgroundColor: "{colors.menu-open-surface-light}"
    textColor: "{colors.menu-link-light}"
    typography: "{typography.label}"
    rounded: "{rounded.menu-open}"
    width: "149px"
    height: "240px"
  menu-collapsed-dark:
    backgroundColor: "{colors.menu-surface-dark}"
    textColor: "{colors.menu-link-hover-dark}"
    typography: "{typography.label}"
    rounded: "{rounded.menu-collapsed}"
    width: "82px"
    height: "48px"
  menu-open-dark:
    backgroundColor: "{colors.menu-open-surface-dark}"
    textColor: "{colors.menu-link-dark}"
    typography: "{typography.label}"
    rounded: "{rounded.menu-open}"
    width: "149px"
    height: "240px"
---

# Design System: DrQ.ai Personal Archive

## Overview

**Creative North Star: "The Quiet Personal Archive"**

DrQ.ai is an experience-first editorial portfolio, not a résumé-first landing page. The thesis is that Wesley's technical practice can feel personal without losing rigor. The own-world is built from warm off-white and near-black system surfaces, restrained typography, one honest portrait, and translucent navigation with asymmetric spring motion.

The story is sequential but unforced: meet Wesley on Home, understand the work, and verify it through Papers (`/papers/`). Those three routes form primary navigation; the retired `/publications/` route is intentionally absent. The `/resume/` route deliberately steps outside that shell as a standalone, always-white professional document opened from Home or Experience in a new tab.

The first viewport is the system's clearest expression: a 300px monochrome portrait beside a 456px editorial introduction, with the Menu at bottom-left and a small linked Charlie Deets credit in the bottom-right footer row. On compact Home viewports, the Menu centers at the bottom while the credit becomes a left-aligned footnote directly after the introduction, with its own navigation clearance. This direction is the user-pinned Charlie Deets editorial form recorded by seed `f7a69c56`; the durable contract lives in the opening comment of each portfolio HTML document under `public/`.

**Key Characteristics:**

- Quiet, personal, and confident rather than conventionally corporate.
- Achromatic interface chrome; the monochrome portrait supplies the visual anchor.
- Generous negative space, narrow reading measures, and no decorative card grid.
- One shared, bottom-left navigation object across the three portfolio routes; the résumé has no portfolio chrome.
- Native system typography and small, understandable static-HTML/CSS/vanilla-JavaScript primitives.

**Reference baseline.** The canonical runner covers every shipped route, the responsive portrait, navigation, analytics placement, the standalone résumé boundary, content records, résumé print contracts, and a sub-500 KB core budget plus one optional film within a 3 MB total artifact budget. The only static content image is Wesley's supplied portrait plus its responsive derivatives under `public/img/profile/`; repository-only records and retired artifacts never ship.

## Colors

The palette is deliberately achromatic. `public/css/site.css` defines semantic CSS properties on `:root` and overrides the same roles under `@media (prefers-color-scheme: dark)`; components must consume these semantic roles rather than branch on raw color values.

### Primary

- **Editorial Ink:** `colors.heading-light` / `colors.heading-dark` is reserved for headings, active navigation, focus outlines, selection, and high-emphasis links.

### Neutral

- **Warm Paper:** `colors.background-light` is the original soft white canvas; `colors.background-dark` is its dark-system counterpart.
- **Quiet Body:** `colors.text-light` / `colors.text-dark` supports default prose.
- **Supporting Gray:** `colors.muted-light` / `colors.muted-dark` carries biography copy, dates, degrees, and publication metadata.
- **Frosted Menu:** the menu surface and open-surface tokens are intentionally translucent so imagery remains perceptible without compromising legibility.
- **Hairline:** the light and dark hairlines are low-contrast structural marks, never text colors.

The text pairs are contrast-safe against their intended page canvases: headings are 18.09:1 light and 13.45:1 dark; body text is 13.01:1 light and 6.94:1 dark; muted text is 4.89:1 light and 7.11:1 dark. Default menu labels remain comfortably above the 4.5:1 body-text threshold in both themes. Preserve or improve these ratios when changing tokens.

**The Portrait Holds Focus Rule.** Do not introduce a brand accent merely to make the interface feel more designed. The neutral frame lets the portrait and writing hold the page.

**The Paired Theme Rule.** Any semantic color change to the portfolio shell must ship as a light/dark pair in `public/css/site.css` and be checked on Home and the reading pages. The résumé is the intentional exception: its inline palette is fixed for white paper in both screen and print contexts.

## Typography

**Display Font:** native system UI (`-apple-system` through Arial fallbacks)
**Body Font:** native system UI
**Label Font:** native system UI

The single family keeps the interface immediate and device-native. Hierarchy comes from size, weight, line height, and spacing—not from decorative typefaces or excessive casing.

### Hierarchy

- **Display:** `typography.display` is used by `.home-intro__copy h1` for the greeting.
- **Headline:** `typography.headline` is used by `.editorial-main h1` and section headings; publication year headings intentionally step down to the body size at 600 weight.
- **Large body:** `typography.body-large` is the desktop Home introduction, with a fixed 456px copy column.
- **Reading body:** `typography.body` is the 680px Experience/Papers column and the base mobile Home copy.
- **Label:** `typography.label` is the floating menu's compact, calm control language.
- **Metadata:** `typography.meta` is for venues and other supporting publication information.

At 720px and below, Home uses 17px/28px with a 28px/34px name, while editorial prose uses 19px/30px and primary editorial headings use 32px/40px. The standalone résumé uses 16px/1.55 body text and a 14px/1.4 supporting-metadata step on compact screens. Links, including publication titles, use a quiet one-pixel underline with a 0.16em offset; hover increases its contrast.

**The One Family Rule.** Do not add a display face to manufacture personality. The voice comes from the writing, proportions, images, and motion.

## Layout

The portfolio uses two deliberate spatial modes, both defined in `public/css/site.css`:

1. **Home (`.home-main`, `.home-intro`):** a vertically centered first viewport with an 820px maximum row, 300px portrait, 456px copy column, and 64px gap. At 1360px and wider the row becomes 828px with a 72px gap. At 880px and below, the composition stacks, aligns to the top, and gives the portrait `max(180px, 40%)` with a square aspect ratio. For short landscape viewports 600–880px wide and at most 500px high, a 144px portrait sits beside the introduction so the name stays in the first viewport.
2. **Reading pages (`.editorial-main`):** a centered 680px measure, 120px top margin, 48px minimum side total, and generous bottom clearance for the floating menu. At 720px and below, the page uses 24px side gutters, 48px top spacing, and a shorter bottom tail.
3. **Standalone résumé (`.resume-document`):** an 8.5-inch white document centered directly on a white viewport with no outer gap, frame, shadow, menu, or shared shell. Inline CSS owns its screen, mobile, and three-page Letter print behavior.
The supported minimum viewport width is 320px. Breakpoints are behavioral, not device labels: 1360px widens the Home composition, 880px stacks Home, and 720px applies compact typography, editorial spacing, and menu insets.

**The One Reading Measure Rule.** New prose-heavy routes should start from `.editorial-main`; do not widen text to fill the viewport.

**The Bottom Clearance Rule.** Long pages must preserve enough trailing space that the fixed menu never covers the final content.

## Elevation & Depth

The system is flat everywhere except the floating menu. Page sections do not become cards and images receive no generic shadow. Depth comes from negative space, image scale, the menu's translucent material, and its stateful elevation.

- **Collapsed menu:** `--shadow-menu` combines a broad 36px ambient shadow with a one-pixel contact shadow.
- **Open menu:** `--shadow-menu-open` grows to a 60px ambient shadow plus an 8px contact layer.
- **Material:** `.floating-menu` uses `backdrop-filter: blur(20px) saturate(140%)` with a fine highlight border. Dark mode replaces the highlight with `colors.menu-border-dark`.

**The One Floating Surface Rule.** The menu is the only persistent elevated UI surface; the film uses a temporary native modal while open. Do not apply its blur or shadow language to content containers.

## Shapes

Shapes are soft but sparse. The desktop portrait uses `rounded.portrait` and reduces to `rounded.image` once stacked. The menu morphs from `rounded.menu-collapsed` to `rounded.menu-open`; the skip link uses the fully pill-shaped token. Content itself stays unboxed.

The favicon reduces that shape language to one mark: an 18px Editorial Ink square with a 5px corner radius, centered on a transparent 32px canvas. It has no letterform, border, or decorative detail.

**The Honest Image Rule.** Round the frame, not the subject. Keep `object-fit: cover` only for the square portrait and preserve its supplied composition.

## Components

### Global floating menu

The repeated `.floating-menu` markup in the three portfolio pages and `public/js/site.js` jointly define the primary navigation contract. Contract tests keep the repeated labels, routes, and current-page state synchronized.

- **Content:** exactly Home, Experience, and Papers, in that order. The current link uses `.active` plus `aria-current="page"`.
- **Placement:** 32px from the desktop left/bottom edges. At 720px and below the entire control centers horizontally, sits 20px above the bottom safe area when collapsed, and lowers to a 12px safe-area floor when open. The inner column and its labels center with the surface; wider landscape and desktop layouts remain left-aligned.
- **Size:** 82 × 48px collapsed on desktop and 149 × 240px open for the current three-route structure. On mobile, the collapsed surface measures the actual Menu label and adds 46px of breathing room, matching the reference control instead of assuming a fixed label width. The open height is measured from the real inner content so future route changes do not clip.
- **Structure:** Home stands alone above a hairline; Experience and Papers form the second group; a second hairline separates navigation from the bottom control.
- **State:** the same trigger reads Menu when collapsed and Close at the bottom of the open panel. `aria-expanded`, `aria-label`, and `inert` keep the accessibility tree synchronized with the visual state while the trigger remains keyboard-accessible in both states.
- **Progressive enhancement:** HTML starts with visible navigation links and a hidden trigger. JavaScript adds `.is-enhanced` and initializes the disclosure. Without JavaScript, ordinary links remain in document flow.
- **Dismissal:** pointer activation opens without moving focus into the menu; keyboard activation focuses the active or first link. Outside click, focus leaving the control, and Escape close it; Escape returns focus to the trigger.

Width and height use separate authored spring curves. Opening targets roughly 590ms horizontally and 428ms vertically; closing targets 655ms and 475ms with a softer overshoot. Each interaction varies those durations by ±15%, keeping the control tactile without changing its geometry. The inner column moves 4px horizontally and 8px vertically, while navigation and dividers reveal bottom-to-top on opening and disappear top-to-bottom on closing.

On mobile, the closed menu remains visible for the first 80px of the page and within 48px of the page ending. Elsewhere it fades during downward travel and returns after 60px of continuous upward travel. Tab restores the control before focus advances, including when previous pointer scrolling made it inert. Opening or keyboard focus inside the menu pins it; the hidden state is inert as well as pointer-inactive. Desktop keeps the menu persistently visible. Mobile material, shadows, label measurement, spring stops, centering, and reveal order deliberately track Charlie Deets's current menu in detail; the site's own reduced-motion and focus treatment remain authoritative.

**The Tiny Layout Exception.** `.floating-menu` intentionally animates `width` and `height`, despite the detector's general preference for transform/opacity motion. This is a reviewed exception limited to the fixed bottom-corner control; `contain: layout paint` prevents page reflow and the measured height keeps the animation bounded. Do not generalize it to panels, cards, page sections, or other large surfaces.

### Home introduction

`public/index.html` and `.home-intro` pair one supplied monochrome portrait with concise, playful professional copy. The heading is simply “Wesley Wei Qian” and owns the strongest contrast; body copy stays muted; LinkedIn, Scholar, Resume, and Email form a quiet inline row that may wrap on small screens. Two contextual links in the existing introduction lead to Experience and Papers. Utility links have a 44px minimum height. Resume opens the standalone `/resume/` document in a new tab. A 12px credit links Charlie Deets. It stays at bottom-right on wider screens; at 720px and below it aligns with the introduction gutter immediately after the content and reserves enough trailing space for the centered floating Menu and device safe area.

### Osmo Studio film

Home links the phrase “turning scent prompting into a product” within the Osmo paragraph, explaining how the work helps brands scale their fragrance businesses. The link uses the surrounding prose’s typography and wraps naturally; its title identifies the 27-second Osmo Studio video. The native modal shows only the film, native playback controls, and a small overlaid close icon with a 44px target. It has no visible title, credit, duration, or description. An accessible dialog name and visually hidden film description remain available to assistive technology. The video fills the dialog, sized to fit both viewport dimensions with 16px clearance; native fullscreen remains available.

`public/js/studio-video.js` is loaded on Home only. The film has no `src` until activation, starts from the user’s click, and is paused and unloaded when the dialog closes. Native dialog behavior contains focus and handles Escape; closing returns focus to the linked product phrase. Modified clicks and no-JavaScript visits retain the direct MP4 link. Playback errors use the browser’s native video interface.

The approved unmodified 2.55 MB MP4 lives in `public/media/`; its provenance is recorded in `docs/media-sources.md`. This is an explicit exception to the old all-assets 500 KB cap: the core site still stays below 500 KB, and the total artifact is capped at 3 MB. Do not preload the film or turn it into a background animation.

### Editorial entries

`public/experience/index.html` uses `.work-entry` and `.education-entry`; `public/papers/index.html` uses `.publication-year`, `.publication`, and `.publication-meta`. Both reading pages begin directly with their page title, without a repeated name byline. Experience ends with a contextual “Full resume” link that opens the standalone record in a new tab. Entries rely on whitespace and type, not dividers or cards. External links open in a new tab with `noopener noreferrer`. Work entries, resume roles, and papers have stable fragment IDs for direct citations. Keep each paper’s fragment consistent between Papers, Resume, and its structured-data identity.

### Standalone résumé

`public/resume/index.html` is a complete document with inline CSS and no shared layout, menu, stylesheet, JavaScript, analytics, or dark theme. Screen and mobile presentations use a continuous white canvas. Screen typography uses 16px body text, 18px company/school names, 22px section headings, and 14px supporting metadata. Screen-only section links and a Print hint help readers navigate. Print retains its original 9.5pt body scale, 11.5pt company/school names, spacing, and explicit breaks. Print remains a deliberately controlled three-page Letter layout whose third page begins with “Evaluating attribution for graph neural networks.” The separation is intentional: the résumé should feel like a focused professional artifact, not another portfolio page.

### Accessibility primitives

Each portfolio HTML document places `.skip-link` before main content. Global `:focus-visible` uses a 2px high-contrast outline with a 4px offset; menu links place their rings inward, while the trigger draws its ring on the outer shell so it remains visible when collapsed. Interactive menu rows meet the 44px touch-target floor. `@media (prefers-reduced-motion: reduce)` disables smooth scrolling and collapses transition/animation durations without hiding content.

## Do's and Don'ts

### Do

- **Do** preserve Home, Experience, and Papers as the shared portfolio navigation and keep Resume as a standalone new-tab document.
- **Do** use the semantic tokens in `public/css/site.css` and verify portfolio color changes in light and dark system themes; keep résumé colors in its inline, always-white system.
- **Do** begin new reading surfaces with the 680px editorial measure and the established heading/body hierarchy.
- **Do** give local images intrinsic dimensions, useful alt text, lazy loading below the first viewport, and source context in commit history.
- **Do** preserve keyboard operation, focus return, 44px targets, active-page semantics, and reduced-motion behavior when changing navigation.
- **Do** compare visual changes against fresh light/dark Home and reading-page browser captures.

### Don't

- **Don't** reintroduce a Photo route or image-feed feature without an explicit product decision.
- **Don't** add bright accent colors, decorative card grids, broad shadows, or extra floating surfaces; the content and portrait are the visual emphasis.
- **Don't** widen prose beyond the editorial measure or crowd the first viewport with additional calls to action.
- **Don't** copy the menu's width/height animation exception into other components.
- **Don't** add portfolio navigation, shared assets, analytics, dark mode, outer framing, or elevated surfaces to the résumé.

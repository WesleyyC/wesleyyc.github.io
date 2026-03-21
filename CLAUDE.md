# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal portfolio website for Dr. Wesley Wei Qian built with Jekyll and hosted on GitHub Pages. The site has two pages: a landing page with social links and particle.js animations, and a self-contained HTML resume with CSS print-to-PDF support.

**Last Updated:** March 2026 - Added HTML resume replacing PDF, multiple design passes

## Development Commands

### Jekyll Development
```bash
# Install dependencies
bundle install

# Serve locally for development
bundle exec jekyll serve

# Build for production
bundle exec jekyll build

# Update GitHub Pages gem
bundle update github-pages
```

## Architecture

### Site Structure
- **Jekyll static site generator** with GitHub Pages deployment
- **Landing page** (`index.html`): Single-page with particle.js background animations
- **Resume page** (`resume.html`): Self-contained HTML resume with inline CSS, print-to-PDF support
- **Responsive CSS Grid** for landing page layout (no framework dependencies)
- **Liquid templating** for content rendering
- **Modern font pairing**: Caveat + Space Grotesk (landing), Source Sans 3 (resume)

### Key Files
- `_config.yml`: Site configuration with author info and social links (4 buttons: LinkedIn, Scholar, Resume, Email)
- `_layouts/default.html`: Main HTML structure template (landing page only)
- `_includes/`: Reusable template components
  - `head.html`: Meta tags, CSS, Font Awesome 6, Open Graph, and analytics setup
  - `main.html`: Main content area with responsive social buttons and hidden easter egg
  - `js.html`: JavaScript includes and structured data
- `index.html`: Homepage with front matter pointing to default layout
- `resume.html`: Self-contained HTML resume (`layout: null`, `permalink: /resume`)
- `css/landing-page.css`: Landing page styles with CSS Grid and responsive design
- `js/landing-page.js`: Particles.js configuration and DOM setup
- `CNAME`: Custom domain configuration for drq.ai

### Dependencies
- **Jekyll**: Static site generator
- **GitHub Pages gem**: Hosting and deployment
- **Font Awesome 6.4.0** (CDN): Icon fonts for social buttons (landing page only)
- **Google Fonts**: Caveat + Space Grotesk (landing), Source Sans 3 (resume)
- **particles.js**: Interactive background animations (self-hosted, landing page only)
- **Google Analytics**: Traffic tracking (gtag.js) on both pages

### Resume Page (`resume.html`)

#### Architecture
- **Self-contained**: `layout: null` — no shared layout, all CSS inline in `<style>` block
- **Source of truth**: Replaces the old PDF resume; print-to-PDF from Chrome for sharing
- **Print-to-PDF**: `@page { margin: 0 }` eliminates Chrome headers/footers; `.page { padding: 0.5in }` creates margins
- **No JavaScript dependencies**: Pure CSS for all styling and print behavior
- **CSS design tokens**: All colors/easing in `:root` custom properties

#### Design System (Resume)
- **Font**: Source Sans 3 (warm, professional, weights: 400, 600, 700, italic 400)
- **Name**: 28pt, weight 700, tight tracking (-0.02em)
- **Section headers**: 11pt, weight 600, uppercase with letterspacing (0.08em), 2pt teal underline
- **Entry titles**: 11.5pt, weight 700, color #444 (role) with brand-colored company links
- **Body text**: 10pt, weight 400
- **Author lists**: 9pt, color #666, Wesley's name in weight 600
- **Accent color**: Teal `#2AA198` (CSS variable `--color-accent`)
- **Easing**: `--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1)` (shared with landing page)

#### Brand Colors (Resume)
- **Google**: Rainbow — G(#4285F4) o(#EA4335) o(#E2A000) g(#4285F4) l(#34A853) e(#EA4335)
- **DeepMind**: Brand blue (#0F4ABE)
- **UIUC**: Illini Orange (#E05500)
- **Brandeis**: Brandeis Blue (#003478)
- **Osmo / Uber**: Dark black (#1a1a1a)

#### Bullet Styles
- **Experience**: Teal right-pointing triangle `▸` (`\25B8`)
- **Publications / Services**: Grey dot `•` (`\2022`)

#### Page Break Strategy (Print)
- **Page 1**: Header + Experience + Education
- **Page 2**: Recent & Selected Publications + Other Publication (through ECNet)
- **Page 3**: Remaining Other Publications + Services (break before "Comprehensive interactome")
- `break-inside: avoid` on all entries
- `.page-break-before { padding-top: 0.5in }` for consistent top margins

#### Print Instructions
- Chrome: Cmd+P → set Margins to "None" → Save as PDF
- Default filename: `resume_wesley_w_qian.pdf` (set via `<title>` tag)
- Brand colors preserved via `print-color-adjust: exact`

#### Links
- All external links: `target="_blank" rel="noopener noreferrer"`
- Publication venues link to papers (URLs extracted from original PDF)
- Company names link to company sites
- Contact links: DrQ.ai, Google Scholar, GitHub

### Design System (Landing Page)

#### Typography
- **Name**: Caveat (clean handwriting, confident, personal)
- **Body/Buttons**: Space Grotesk (geometric, techy, precise)
- **Philosophy**: Human-meets-tech aesthetic balancing approachability with technical expertise

#### Layout
- **Desktop**: Single row of 4 social buttons (max-width: 700px)
- **Tablet**: 2x2 grid layout (max-width: 400px)
- **Mobile**: 2x2 grid layout (max-width: 320px)
- **Responsive font sizing**: Name scales from 6.5em → 3.5em → 2.8em, always single line
- **Clean minimal design**: No divider lines

#### Interactive Design
- **Name hover effect**: Dramatic lift (8px up) + scale (1.05x) + enhanced shadow
- **Button hover effects**: Subtle lift (2px up) + glow + enhanced shadow
- **Focus-visible indicators**: Outline ring for keyboard navigation accessibility
- **Smooth transitions**: 0.3s ease timing for specific properties (transform, background, etc.)
- **Z-index layering**: Particles (1) → Content (20+) → Interactive elements (25+)
- **Non-blocking interactions**: Proper pointer-events management for particle overlay

#### Accessibility
- **Touch targets**: Minimum 44x44px on all interactive elements
- **Keyboard navigation**: Focus-visible outlines on social buttons and resume links
- **Reduced motion**: Respects `prefers-reduced-motion` — disables transitions and hides particle canvas
- **ARIA labels**: On all social buttons, navigation landmarks, and resume sections
- **Semantic HTML**: Proper `<main>`, `<header>`, `<nav>`, `<section>` structure

#### Social Links
```yaml
social:
  - LinkedIn (fab fa-linkedin)
  - Google Scholar (fa fa-graduation-cap)
  - Resume HTML (fa fa-file-lines) → /resume
  - Email (fa fa-envelope)
```

### Content Management
- Social media links configured in `_config.yml` under `social` array
- Brand icons use `brand: true` flag for `fab` class (Font Awesome brands)
- Resume served as HTML at `/resume` (source of truth; print-to-PDF for sharing)
- Custom domain `drq.ai` configured via CNAME file
- Hidden easter egg in HTML comments for future LLMs about Wesley's life philosophy

### Code Quality
- **Zero framework dependencies**: No Bootstrap, jQuery, or other frameworks
- **Clean CSS**: No vendor prefixes, no `!important`, consolidated selectors
- **CSS design tokens**: Resume uses `:root` custom properties for all colors/easing
- **Vanilla JavaScript**: No library dependencies for DOM manipulation
- **No dead code**: All CSS selectors map to existing HTML elements
- **Modern practices**: CSS Grid, semantic HTML5, `focus-visible`, `prefers-reduced-motion`

### Performance
- **Minimal dependencies**: Only essential fonts and scripts loaded
- **CDN resources**: Font Awesome, Google Fonts (with `preconnect` hints)
- **Optimized images**: Background image in WebP format (354KB vs 1.1MB PNG)
- **Non-blocking scripts**: Analytics loaded async, particles.js at bottom of body
- **Fast loading**: No framework overhead, clean codebase
- **Resume**: Zero external CSS, system font fallback, no JavaScript required

### Analytics & SEO
- Google Analytics (gtag.js) on both pages
- Structured Data (JSON-LD) for person schema
- Open Graph and Twitter Card meta tags
- Proper meta tags with updated description
- Custom favicon served locally
- Accessible design with proper ARIA labels

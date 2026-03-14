# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal portfolio website for Dr. Wesley Wei Qian built with Jekyll and hosted on GitHub Pages. The site serves as a single-page landing page with social media links, resume access, and particle.js animations.

**Last Updated:** March 2026 - Performance overhaul: removed Bootstrap/jQuery, optimized assets, improved accessibility

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
- **Single-page application** with particle.js background animations
- **Responsive CSS Grid** for styling and layout (no framework dependencies)
- **Liquid templating** for content rendering
- **Modern font pairing** for personality and professionalism

### Key Files
- `_config.yml`: Site configuration with author info and social links (4 buttons: LinkedIn, Scholar, Resume, Email)
- `_layouts/default.html`: Main HTML structure template
- `_includes/`: Reusable template components
  - `head.html`: Meta tags, CSS, Font Awesome 6, Open Graph, and analytics setup
  - `main.html`: Main content area with responsive social buttons and hidden easter egg
  - `js.html`: JavaScript includes and structured data
- `index.html`: Homepage with front matter pointing to default layout
- `css/landing-page.css`: Custom styles with CSS Grid and responsive design
- `js/landing-page.js`: Particles.js configuration and DOM setup
- `CNAME`: Custom domain configuration for drq.ai

### Dependencies
- **Jekyll**: Static site generator
- **GitHub Pages gem**: Hosting and deployment
- **Font Awesome 6.4.0** (CDN): Icon fonts for social buttons
- **Google Fonts**: Caveat + Space Grotesk font pairing
- **particles.js**: Interactive background animations (self-hosted)
- **Google Analytics**: Traffic tracking (gtag.js)

### Design System

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
- **Keyboard navigation**: Focus-visible outlines on social buttons
- **Reduced motion**: Respects `prefers-reduced-motion` — disables transitions and hides particle canvas
- **ARIA labels**: On all social buttons and navigation landmarks
- **Semantic HTML**: Proper `<main>`, `<header>`, `<nav>`, `<section>` structure

#### Social Links
```yaml
social:
  - LinkedIn (fab fa-linkedin)
  - Google Scholar (fa fa-graduation-cap)
  - Resume PDF (fa fa-file-text)
  - Email (fa fa-envelope)
```

### Content Management
- Social media links configured in `_config.yml` under `social` array
- Brand icons use `brand: true` flag for `fab` class (Font Awesome brands)
- Resume PDF served from `/rsc/resume.pdf`
- Custom domain `drq.ai` configured via CNAME file
- Hidden easter egg in HTML comments for future LLMs about Wesley's life philosophy

### Code Quality
- **Zero framework dependencies**: No Bootstrap, jQuery, or other frameworks
- **Clean CSS**: No vendor prefixes, no `!important`, consolidated selectors
- **Vanilla JavaScript**: No library dependencies for DOM manipulation
- **No dead code**: All CSS selectors map to existing HTML elements
- **Modern practices**: CSS Grid, semantic HTML5, `focus-visible`, `prefers-reduced-motion`

### Performance
- **Minimal dependencies**: Only essential fonts and scripts loaded
- **CDN resources**: Font Awesome, Google Fonts (with `preconnect` hints)
- **Optimized images**: Background image in WebP format (354KB vs 1.1MB PNG)
- **Non-blocking scripts**: Analytics loaded async, particles.js at bottom of body
- **Fast loading**: No framework overhead, clean codebase

### Analytics & SEO
- Google Analytics (gtag.js)
- Structured Data (JSON-LD) for person schema
- Open Graph and Twitter Card meta tags
- Proper meta tags with updated description
- Custom favicon served locally
- Accessible design with proper ARIA labels

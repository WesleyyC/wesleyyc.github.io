# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal portfolio website for Dr. Wesley Wei Qian built with Jekyll and hosted on GitHub Pages. The site serves as a single-page landing page with social media links, resume access, and particle.js animations.

**Last Updated:** January 2025 - Major redesign with modern fonts and clean layout

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
- **Responsive CSS Grid + Bootstrap** for styling and layout
- **Liquid templating** for content rendering
- **Modern font pairing** for personality and professionalism

### Key Files
- `_config.yml`: Site configuration with author info and social links (4 buttons: LinkedIn, Scholar, Resume, Email)
- `_layouts/default.html`: Main HTML structure template
- `_includes/`: Reusable template components
  - `head.html`: Meta tags, CSS, Font Awesome 6, and analytics setup
  - `main.html`: Main content area with responsive social buttons and hidden easter egg
  - `js.html`: JavaScript includes and analytics tracking
- `index.html`: Homepage with front matter pointing to default layout
- `css/landing-page.css`: Optimized custom styles with CSS Grid and responsive design
- `js/landing-page.js`: Cleaned particles.js configuration only
- `CNAME`: Custom domain configuration for drq.ai

### Dependencies
- **Jekyll**: Static site generator
- **GitHub Pages gem**: Hosting and deployment
- **Bootstrap 3.4.1** (CDN): Basic responsive framework
- **Font Awesome 6.4.0** (CDN): Modern icon fonts for social buttons
- **Google Fonts**: Indie Flower + Quantico font pairing
- **particles.js**: Interactive background animations
- **jQuery 3.6.0** (CDN): For particles.js functionality
- **Google Analytics**: Traffic tracking (gtag.js)

### Design System

#### Typography
- **Name**: Indie Flower (handwritten, friendly, personal)
- **Buttons**: Quantico (geometric, tech-inspired, professional)
- **Philosophy**: Human-meets-tech aesthetic balancing approachability with technical expertise

#### Layout
- **Desktop**: Single row of 4 social buttons (max-width: 700px)
- **Tablet**: 2×2 grid layout (max-width: 400px)
- **Mobile**: 2×2 grid layout (max-width: 320px)
- **Responsive font sizing**: Name scales from 6.5em → 3.5em → 2.8em, always single line
- **No divider line**: Clean minimal design

#### Interactive Design
- **Name hover effect**: Dramatic lift (8px up) + scale (1.05x) + enhanced shadow
- **Button hover effects**: Subtle lift (2px up) + glow + enhanced shadow
- **Smooth transitions**: 0.3s ease timing for all animations
- **Z-index layering**: Particles (1) → Content (20+) → Interactive elements (25+)
- **Non-blocking interactions**: Proper pointer-events management for particle overlay

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
- **Optimized CSS**: Removed vendor prefixes, consolidated selectors
- **Clean JavaScript**: Removed unused navbar/modal/scrolling code
- **No unused files**: Deleted Glyphicons font folder (~50KB saved)
- **Modern practices**: CSS Grid with flexbox fallbacks, semantic HTML5

### Performance
- **Minimal dependencies**: Only essential fonts and scripts loaded
- **CDN resources**: Bootstrap, Font Awesome, jQuery, Google Fonts
- **Compressed assets**: Optimized particles.js configuration
- **Fast loading**: Clean codebase with no bloat

### Analytics & SEO
- Google Analytics (gtag.js)
- Structured Data (JSON-LD) for person schema
- Proper meta tags and Open Graph data
- Custom favicon and social media metadata
- Accessible design with proper ARIA labels
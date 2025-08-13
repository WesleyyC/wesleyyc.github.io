# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal portfolio website for Dr. Wesley Wei Qian built with Jekyll and hosted on GitHub Pages. The site serves as a single-page landing page with social media links, resume access, and particle.js animations.

## Development Commands

### Jekyll Development
```bash
# Install dependencies
bundle install

# Serve locally for development (from Gemfile comments)
bundle exec jekyll serve

# Update GitHub Pages gem
bundle update github-pages
```

## Architecture

### Site Structure
- **Jekyll static site generator** with GitHub Pages deployment
- **Single-page application** with particle.js background animations
- **Responsive Bootstrap framework** for styling and layout
- **Liquid templating** for content rendering

### Key Files
- `_config.yml`: Site configuration with author info and social links
- `_layouts/default.html`: Main HTML structure template
- `_includes/`: Reusable template components
  - `head.html`: Meta tags, CSS, fonts, and analytics setup
  - `main.html`: Main content area with social buttons
  - `js.html`: JavaScript includes and analytics tracking
- `index.html`: Homepage with front matter pointing to default layout
- `CNAME`: Custom domain configuration for drq.ai

### Dependencies
- **Jekyll**: Static site generator
- **GitHub Pages gem**: Hosting and deployment
- **Bootstrap**: CSS framework for responsive design
- **Font Awesome**: Icon fonts for social media buttons
- **jQuery & particles.js**: Interactive background animations
- **Google Analytics**: Traffic tracking with dual setup (gtag.js and legacy)

### Content Management
- Social media links configured in `_config.yml` under `social` array
- Each social link includes icon (Font Awesome), title, and URL
- Resume PDF served from `/rsc/resume.pdf`
- Custom domain `drq.ai` configured via CNAME file

### Styling
- Bootstrap for responsive grid and components
- Custom `landing-page.css` for theme-specific styling
- Google Fonts (Quicksand) for typography
- Font Awesome icons loaded via CDN script

### Analytics & SEO
- Google Analytics (dual tracking codes)
- Structured Data (JSON-LD) for person schema
- Custom favicon and social media metadata
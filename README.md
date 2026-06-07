# sfm-website

Static website source for `superfactorymanager.ca`.

## Structure

- `static/`: first-pass site assets
- `static/index.html`: landing page
- `static/styles.css`: styling
- `static/data/community-showcase-videos.json`: curated showcase seed data

## Why this repo exists

This repo keeps website content separate from the SFM monorepo so the mod-focused git strategy can stay centered on Minecraft mod development.

## Iteration plan

1. Start with plain static files.
2. Publish a minimal site.
3. Grow the content model for guides, links, and community showcases.
4. Optionally add a small Rust-based renderer later if templating becomes useful.

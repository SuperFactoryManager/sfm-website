# sfm-website

Static website source for `superfactorymanager.ca`.

## Structure

- `static/index.html`: single-page content portal
- `static/styles.css`: brutalist light-grey styling
- `static/data/content.json`: structured content items for the mini CMS

## Content model

Each content item can belong to multiple categories:

- `about`
- `learn`
- `watch`
- `legacy`

This keeps the site organized around user intent instead of forcing each link into a single bucket.

## Notes

- The current implementation is intentionally simple: HTML, CSS, and JSON.
- The rendered links include stable item ids and category ids so click tracking can be added later without reshaping the content model.
- If the site grows, a Rust renderer can consume `static/data/content.json` and emit the same structure.

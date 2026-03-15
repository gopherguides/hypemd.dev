# Claude Code Instructions for hypemd.dev

## Project Overview

This is the public website for [Hype](https://github.com/gopherguides/hype), deployed at https://hypemd.dev via Dokploy. The entire site is built and served using hype's blog system — full dogfooding.

## Build & Serve

```bash
make build    # Build static site to public/
make serve    # Serve on localhost:3000
make dev      # Serve with file watching (auto-rebuild)
make clean    # Remove public/ directory
```

## Content

Articles live in `content/<slug>/module.md`. Create new articles with:

```bash
hype blog new <slug>
```

Article frontmatter uses `<details>` blocks:

```markdown
# Title

<details>
slug: my-article
published: MM/DD/YYYY
author: Gopher Guides
seo_description: Brief description for SEO
tags: tag1, tag2
</details>
```

## Layout Overrides

Project-level layout overrides are in `layouts/`. These take priority over theme templates in `themes/developer/`.

- `layouts/_default/list.html` — Home page with hero section + article list
- `layouts/partials/header.html` — Navigation with site links
- `layouts/partials/footer.html` — Footer with links

## Deployment

- Auto-deploys on merge to main via Dokploy
- Dockerfile builds hype from source, then builds and serves the site
- Dokploy handles TLS termination

## Git Workflow

- Never commit directly to main
- Create feature branches: `feat/`, `fix/`, `docs/`, `content/`
- All PRs must pass CI (build validation)

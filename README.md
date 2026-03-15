# hypemd.dev

The official website and blog for [Hype](https://github.com/gopherguides/hype) — a dynamic Markdown engine that executes code, includes files, and validates content at build time.

**Live site:** [hypemd.dev](https://hypemd.dev)

## What's Here

- **Blog articles** — tutorials and guides in `content/`
- **Documentation** — synced automatically from the [hype repo](https://github.com/gopherguides/hype) via a GitHub Actions workflow
- **Site layouts** — templates in `layouts/`

## Development

The site is built with Hype's built-in blog generator.

```bash
# Install hype
brew install gopherguides/tap/hype

# Build the site
hype blog build

# Serve locally with live reload
hype blog serve
```

## Deployment

The site is deployed via [Dokploy](https://dokploy.com) with autodeploy on push to main. The Dockerfile handles the full build-and-serve pipeline.

## Doc Sync

Documentation pages (`content/docs-*/`) are automatically synced from the hype repo. When docs change in `gopherguides/hype`, a workflow processes them and pushes updates here. Do not edit `content/docs-*` files directly — they will be overwritten on the next sync.

Manually-maintained content:
- `content/docs/module.md` — docs landing page
- `content/getting-started/module.md` — getting started tutorial
- All other `content/*/module.md` — blog articles

# Deploying a Hype Blog with Docker

<details>
slug: deploying-with-docker
published: 03/15/2026
author: Cory LaNou
author_twitter: @caborundrum
seo_description: Deploy a Hype-powered blog site with Docker. Covers Dockerfile setup, Dokploy, Heroku, and generic VPS deployment with Docker Compose.
tags: tutorial, docker, deployment, blog, hype
tweet: Deploy a Hype-powered blog with Docker — from Dockerfile to production. Covers Dokploy, Heroku, and Docker Compose setups.
</details>

Hype builds and serves your blog in a single binary. That makes it a natural fit for Docker — one container that builds your site from source and serves it, with no external web server required.

This is exactly how [hypemd.dev](https://hypemd.dev) runs in production. Here's how to do it.

## The Dockerfile

A Hype blog needs two things at deploy time: the `hype` binary and your site content. A two-stage Docker build keeps the image lean:

```dockerfile
FROM golang:1.25 AS builder
RUN go install github.com/gopherguides/hype/cmd/hype@latest

FROM golang:1.25
COPY --from=builder /go/bin/hype /usr/local/bin/hype
WORKDIR /site
COPY . .
RUN hype blog build
EXPOSE 3000
CMD ["hype", "blog", "serve", "--addr", ":3000"]
```

What this does:

1. **Builder stage** — installs `hype` from source using Go 1.25 (hype's minimum version)
2. **Runtime stage** — copies the built binary, copies your site content, runs `hype blog build` to generate the static site, then serves it on port 3000

The `hype blog build` step executes all your code blocks, resolves includes, and generates `public/`. The `hype blog serve` command serves that directory with live reload in development, or you can add the `--production` flag for production-grade serving with compression and security headers.

## Production Serving

As of the latest release, `hype blog serve` supports a `--production` flag that enables embedded Caddy for production-grade serving:

```dockerfile
CMD ["hype", "blog", "serve", "--addr", ":3000", "--production"]
```

This gives you:

- **Compression** — gzip and zstd with automatic content negotiation
- **Security headers** — X-Content-Type-Options, X-Frame-Options, Referrer-Policy
- **Cache control** — 1-year immutable caching for static assets, 1-hour for HTML
- **Clean URLs** — automatic index.html resolution
- **Custom 404** — auto-detected from `public/404.html` if present

No nginx or Caddy sidecar needed. It's all in the binary.

## Deploying with Dokploy

[Dokploy](https://dokploy.com) is a self-hosted PaaS that makes Docker deployments simple. This is what hypemd.dev uses.

### Setup

1. Create a new application in Dokploy and link your GitHub repo
2. Set the build type to **Dockerfile** (not Nixpacks — Dokploy defaults to Nixpacks which won't know how to build a Hype site)
3. Deploy

### Domain Configuration

In Dokploy's domain settings:

- **Host**: your domain (e.g., `hypemd.dev`)
- **Container Port**: `3000`
- **HTTPS**: enable with Let's Encrypt for automatic TLS

Point your DNS A record to your Dokploy server's IP address.

### Auto-Deploy

Enable autodeploy in Dokploy's Git settings. Every push to main triggers a rebuild and redeploy. Combined with the [docs sync workflow](/single-source-docs/) pattern, this means documentation changes in your source repo automatically propagate to your live site.

## Deploying with Heroku

Heroku's container stack works with the same Dockerfile, with one adjustment — Heroku assigns a dynamic port via the `$PORT` environment variable.

### heroku.yml

Create a `heroku.yml` at the repo root:

```yaml
build:
  docker:
    web: Dockerfile
```

### Dynamic Port

Modify the CMD to use Heroku's port:

```dockerfile
CMD hype blog serve --addr ":$PORT" --production
```

Note the shell form (no brackets) so `$PORT` gets expanded.

### Deploy

```bash
heroku stack:set container
git push heroku main
```

## Generic Docker / VPS Deployment

For any server with Docker installed:

### Build and Run

```bash
docker build -t my-blog .
docker run -d -p 3000:3000 --name my-blog my-blog
```

Your site is now serving on port 3000.

### Docker Compose

For a more complete setup with automatic restarts:

```yaml
services:
  blog:
    build: .
    ports:
      - "3000:3000"
    restart: unless-stopped
```

```bash
docker compose up -d
```

### TLS with a Reverse Proxy

If you're not using `--production` mode or need TLS termination, put a reverse proxy in front:

```yaml
services:
  blog:
    build: .
    restart: unless-stopped

  caddy:
    image: caddy:2
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
    restart: unless-stopped

volumes:
  caddy_data:
```

With a `Caddyfile`:

```
yourdomain.com {
    reverse_proxy blog:3000
}
```

Caddy handles TLS automatically via Let's Encrypt.

## Content Updates

The deployment workflow is simple:

1. Push content changes to your repo
2. Your platform rebuilds the Docker image
3. `hype blog build` runs inside the container, executing all code blocks fresh
4. The new container starts serving

Every deploy is a clean build. Your code examples are re-executed, includes are re-resolved, and broken references fail the build before they reach production.

## Key Takeaways

- **Single binary** — `hype` builds and serves, no external dependencies
- **Docker-native** — simple two-stage Dockerfile works everywhere
- **Production-ready** — `--production` flag adds compression, security headers, and caching
- **Git-driven** — push to deploy, content is always current
- **Build-time validation** — broken code or missing files fail the build, not the reader

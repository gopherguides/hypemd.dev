# Quick Reference

<details>
slug: docs/quick-reference
published: 03/15/2026
author: Gopher Guides
seo_description: Hype documentation — Quick Reference. Learn how to use this feature in the Hype dynamic Markdown engine.
tags: docs, quick-reference, hype
</details>

## Quick Reference

> **Hype** is a Markdown content generator with dynamic code execution, includes, and validation.

### Install

```bash
go install github.com/gopherguides/hype/cmd/hype@latest
```

Or via Homebrew: `brew install gopherguides/hype/hype-md`

### Common Commands

| Command | Description |
|---------|-------------|
| `hype export -format=markdown -f doc.md` | Export to markdown (stdout) |
| `hype export -format=html -f doc.md -o doc.html` | Export to HTML file |
| `hype preview -f doc.md -open` | Live preview with hot reload |
| `hype validate -f doc.md` | Validate document structure |

### Key Tags

| Tag | Purpose | Example |
|-----|---------|---------|
| `<include>` | Include another file | `&lt;include src="other.md">` |
| `<code>` | Show file contents | `&lt;code src="main.go">` |
| `<go>` | Run Go code, show output | `&lt;go run="main.go">` |
| `<cmd>` | Run shell command | `&lt;cmd exec="ls -la">` |
| `<img>` | Include image | `<img src="diagram.png">` |

### AI Assistants

For detailed skill documentation, see [`.agent/skills/hype/`](.agent/skills/hype/).

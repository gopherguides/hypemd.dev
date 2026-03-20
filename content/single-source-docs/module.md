# Single-Source Documentation: One Markdown File for Your README and Website

<details>
slug: single-source-docs
published: 03/15/2026
author: Cory LaNou
author_twitter: @corylanou
seo_description: Learn how to use Hype to maintain a single Markdown source that generates both your GitHub README and website documentation, keeping them permanently in sync.
og_image: /images/og-single-source-docs.png
tags: tutorial, docs, workflow, hype
tweet: Your README says one thing, your docs site says another. Write it once with Hype and generate both from a single source.
</details>

Every open source project has the same problem: documentation lives in too many places. Your README says one thing, your docs site says another, and the install instructions in your wiki are three versions behind. You end up maintaining the same content in multiple locations, and they inevitably drift apart.

Hype solves this by letting you write your documentation once and generate multiple outputs from a single source.

## The Problem

A typical project has documentation scattered across:

- `README.md` in the repo root
- A docs site (GitHub Pages, Netlify, etc.)
- Wiki pages
- Blog posts or tutorials

When you update an API or change an install command, you have to remember to update every copy. You won't. Nobody does.

## The Hype Approach

With Hype, you write a single `hype.md` file that includes source files, executes code, and validates everything at build time. Then you generate your README from it:

```bash
hype export -format markdown -f hype.md > README.md
```

Your README is now a build artifact, not a hand-maintained file. Change the source, regenerate, and every output stays in sync.

## A Practical Example

Let's say you're building a Go CLI tool. Your documentation needs to show:

1. How to install it
2. A code example
3. The command's help output

### Step 1: Create Your Source File

Create a `hype.md` at the root of your project:

```markdown
# My CLI Tool

A fast and simple tool for doing things.

## Installation

&#96;&#96;&#96;bash
go install github.com/you/tool@latest
&#96;&#96;&#96;

## Quick Example

&lt;code src="examples/hello/main.go"&gt;&lt;/code&gt;

## Usage

&lt;cmd exec="go run ./cmd/tool -h"&gt;&lt;/cmd&gt;
```

The `<code>` tag includes your actual source file. The `<cmd>` tag runs a command and captures the output. Both happen at build time.

### Step 2: Generate Your README

```bash
hype export -format markdown -f hype.md > README.md
```

The generated README contains the actual contents of `examples/hello/main.go` and the real output of `go run ./cmd/tool -h`. If either changes, the next build picks it up automatically.

### Step 3: Automate It

Add a CI step so the README regenerates on every push. The Hype repo itself does exactly this — a GitHub Actions workflow runs `hype export` and commits the updated README if it changed.

Here's a minimal workflow:

```yaml
name: Generate README
on:
  push:
    branches: [main]

jobs:
  readme:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go install github.com/gopherguides/hype/cmd/hype@latest
      - run: hype export -format markdown -f hype.md > README.md
      - name: Commit if changed
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add README.md
          git diff --cached --quiet || git commit -m "docs: regenerate README"
          git push
```

## Why This Matters

When your code example is included from a real file, the compiler validates it. When your CLI output is captured from the actual binary, it reflects the current behavior. When a build step generates your README, you can't forget to update it.

The result is documentation that is always correct because it's derived from the source of truth — your code.

## Going Further

This same pattern scales beyond READMEs:

- **Website docs**: Use the same source files to generate pages for your docs site (this is exactly how [hypemd.dev](https://hypemd.dev) works — docs are synced from the Hype repo automatically)
- **Blog posts**: Write tutorials with executable code examples that are validated every time you build
- **Training materials**: Include code snippets and exercise outputs that stay current as your codebase evolves

The key insight is simple: documentation should be a build artifact, not a source file. Write it once, generate it everywhere, and let the build system keep it honest.

## Get Started

Install Hype and try it on your own project:

```bash
brew install gopherguides/tap/hype
```

Or with Go:

```bash
go install github.com/gopherguides/hype/cmd/hype@latest
```

Create a `hype.md`, include some source files, and run `hype export -format markdown`. You'll never hand-maintain a README again.

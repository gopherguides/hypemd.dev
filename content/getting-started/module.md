# Getting Started with Hype

<details>
slug: getting-started
published: 03/15/2026
author: Gopher Guides
seo_description: Learn how to install Hype, create your first dynamic Markdown document, and execute code blocks at build time.
tags: tutorial, getting-started, hype
</details>

Hype is a content engine that makes Markdown dynamic. You can execute code, include files, and validate everything at build time. This guide walks you through installation and your first hype document.

## Installation

Install hype with Homebrew:

```shell
brew install gopherguides/tap/hype
```

Or install directly with Go:

```shell
go install github.com/gopherguides/hype/cmd/hype@latest
```

Verify the installation:

```shell
hype version
```

## Your First Hype Document

Create a new file called `module.md`:

```markdown
# Hello Hype

This document is powered by hype.
```

Build it to HTML:

```shell
hype export -format html -f module.md
```

Or export to Markdown (useful for generating README files):

```shell
hype export -format markdown -f module.md
```

## Code Execution

One of hype's most powerful features is executing code blocks at build time. When you include a Go source file and mark it for execution, hype runs the code and captures the output.

Create a `src/main.go` file next to your `module.md`:

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello from Hype!")
}
```

Then reference it in your Markdown using hype's include syntax. The code will be executed during build, and the output will appear in your final document.

This means your documentation always reflects the actual behavior of your code. If the code changes, the docs update automatically. If the code breaks, the build fails — so you catch issues before they ship.

## Starting a Blog

Hype includes a built-in static blog generator:

```shell
hype blog init mysite
cd mysite
hype blog new hello-world
hype blog build
hype blog serve
```

This creates a full blog with themes, RSS feeds, sitemaps, and SEO support — all powered by hype's dynamic Markdown.

## Next Steps

- Read the [full documentation](https://github.com/gopherguides/hype#readme)
- Browse the [source code](https://github.com/gopherguides/hype)
- Report [issues](https://github.com/gopherguides/hype/issues)

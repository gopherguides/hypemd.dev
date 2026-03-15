# Building Training Materials with Hype

<details>
slug: training-materials
published: 03/15/2026
author: Cory LaNou
seo_description: Learn how to use Hype to build reusable training and course materials with executable code examples, file includes, and modular content that stays in sync with your codebase.
tags: tutorial, training, education, includes, hype
</details>

If you've ever written training materials for a programming course, you know the pain: code examples go stale, exercises drift out of sync with the slides, and updating one module means checking every other module that references it. Hype was built to solve exactly this problem.

This guide shows how to use Hype's include system and code execution to build training materials that are modular, reusable, and always up to date.

## The Problem with Traditional Course Materials

A typical Go training course might have 20 modules. Each module has:

- Lecture notes with code examples
- Exercises with starter code
- Solutions with expected output
- Slides summarizing key points

When Go releases a new version and a stdlib API changes, you have to find and update every reference across all 20 modules. When a student reports that an exercise doesn't compile, you have to figure out which version of the code is current. When you reuse a concept explanation across modules, you end up with slightly different versions that diverge over time.

## The Hype Approach

With Hype, your course materials are structured like a codebase:

```
training/
├── hype.md                    # Master document
├── modules/
│   ├── 01-basics/
│   │   ├── hype.md            # Module document
│   │   ├── notes.md           # Lecture notes
│   │   └── src/
│   │       ├── hello/main.go  # Example code
│   │       └── exercise/main.go
│   ├── 02-types/
│   │   ├── hype.md
│   │   ├── notes.md
│   │   └── src/
│   │       ├── types/main.go
│   │       └── exercise/main.go
│   └── 03-functions/
│       ├── hype.md
│       ├── notes.md
│       └── src/
│           ├── functions/main.go
│           └── exercise/main.go
└── shared/
    ├── setup.md               # Reusable setup instructions
    ├── go-install.md           # Go installation guide
    └── src/
        └── common/helpers.go   # Shared example code
```

Each module is self-contained with its own source files, but can include shared content. The master document pulls everything together.

## Building a Module

### Step 1: Write the Example Code

Start with real, compilable Go code. Put it in the module's `src/` directory:

```go
// src/hello/main.go
package main

import "fmt"

func main() {
    fmt.Println("Hello, training participant!")
}
```

This is actual source code that the Go compiler validates. It's not a code block in a Markdown file — it's a real `.go` file.

### Step 2: Reference It in Your Module

Create the module's `hype.md`:

```markdown
# Module 1: Go Basics

## Your First Go Program

Here's a simple Go program that prints a greeting:

&lt;code src="src/hello/main.go"&gt;&lt;/code&gt;

Let's run it and see the output:

&lt;go src="src/hello" run="."&gt;&lt;/go&gt;
```

When you build this module, Hype:

1. Includes the contents of `src/hello/main.go` as a syntax-highlighted code block
2. Runs `go run .` in the `src/hello` directory
3. Captures the output and includes it in the document

If the code doesn't compile, the build fails. You'll never ship broken examples to students.

### Step 3: Add Exercises

Create exercise code with intentional gaps for students to fill in:

```go
// src/exercise/main.go
package main

import "fmt"

func main() {
    // TODO: Print your name using fmt.Println
}
```

Reference it in your module document:

```markdown
## Exercise: Hello You

Complete the following program to print your name:

&lt;code src="src/exercise/main.go"&gt;&lt;/code&gt;

**Expected output:**

&#96;&#96;&#96;
Hello, [Your Name]!
&#96;&#96;&#96;
```

The exercise code compiles (it just doesn't do anything useful yet), so the build still succeeds. Students get a validated starting point.

## Using Includes for Shared Content

Training materials often repeat the same setup instructions, environment requirements, or concept explanations. Hype's `<include>` tag lets you write these once and reference them everywhere.

### Shared Setup Instructions

Create a shared setup file:

```markdown
<!-- shared/setup.md -->
## Environment Setup

Before starting this module, make sure you have:

1. Go 1.21 or later installed
2. A text editor (VS Code recommended)
3. A terminal

Verify your Go installation:

&#96;&#96;&#96;bash
go version
&#96;&#96;&#96;
```

Include it in every module:

```markdown
# Module 3: Functions

&lt;include src="../../shared/setup.md"&gt;&lt;/include&gt;

## Functions in Go

...
```

When you update the Go version requirement, you change `shared/setup.md` once and every module picks up the change on the next build.

### Shared Code Examples

If multiple modules reference the same helper code, put it in `shared/src/` and include it:

```markdown
Here's the helper package we'll use throughout the course:

&lt;code src="../../shared/src/common/helpers.go"&gt;&lt;/code&gt;
```

## Code Snippets for Focused Examples

Sometimes you want to show only part of a file. Use snippets to highlight the relevant section:

```go
// src/functions/main.go
package main

import "fmt"

// snippet: greet
func greet(name string) string {
    return fmt.Sprintf("Hello, %s!", name)
}
// snippet: greet

func main() {
    message := greet("World")
    fmt.Println(message)
}
```

Reference just the snippet:

```markdown
Let's focus on the `greet` function:

&lt;code src="src/functions/main.go" snippet="greet"&gt;&lt;/code&gt;
```

This renders only the `greet` function, not the full file. But the full file still compiles and runs, so the build validates that your snippet is part of working code.

## Building the Master Document

The top-level `hype.md` assembles all modules into a complete course:

```markdown
# Go Programming Course

&lt;include src="modules/01-basics/hype.md"&gt;&lt;/include&gt;

&lt;include src="modules/02-types/hype.md"&gt;&lt;/include&gt;

&lt;include src="modules/03-functions/hype.md"&gt;&lt;/include&gt;
```

Build the entire course as a single document:

```bash
hype export -format html -f hype.md > course.html
```

Or build individual modules:

```bash
hype export -format html -f modules/01-basics/hype.md > module-01.html
```

## Multiple Output Formats

The same source produces different formats for different contexts:

```bash
# HTML for web delivery
hype export -format html -f hype.md > course.html

# Markdown for GitHub/GitLab rendering
hype export -format markdown -f hype.md > README.md

# Individual modules for LMS upload
for module in modules/*/hype.md; do
    name=$(basename $(dirname "$module"))
    hype export -format html -f "$module" > "output/${name}.html"
done
```

## Keeping Materials Current

Since all code is real and executed at build time, your CI pipeline catches problems before students do:

```yaml
name: Validate Training Materials
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go install github.com/gopherguides/hype/cmd/hype@main
      - run: hype export -format html -f hype.md > /dev/null
```

If any code example fails to compile, if any command produces unexpected output, or if any included file is missing, the build fails. You fix it before it reaches a classroom.

## Real-World Example: Gopher Guides

This isn't theoretical — [Gopher Guides](https://www.gopherguides.com) has been using this approach to build Go training materials for years. Hundreds of code examples across dozens of modules, all validated at build time, all using the include and snippet system described here.

When Go 1.21 introduced the `log/slog` package, updating the logging module meant changing the source files and rebuilding. Every reference to the old examples was automatically updated. No grep-and-replace across Markdown files, no missed references, no stale screenshots.

## Key Takeaways

- **Code examples are real files** — the compiler validates them, not a human reviewer
- **Includes eliminate duplication** — shared content is written once and referenced everywhere
- **Snippets focus attention** — show only what matters while keeping the full file compilable
- **Build-time execution catches problems** — broken code fails the build, not the student
- **Multiple formats from one source** — HTML, Markdown, slides, all from the same content
- **CI integration** — automated validation on every push keeps materials current

## Get Started

```bash
brew install gopherguides/tap/hype

mkdir training && cd training
mkdir -p modules/01-basics/src/hello
```

Create your first module, write a real Go example, include it in your document, and build. You'll have validated, executable training materials in minutes.

# AI-Assisted Authoring with Hype

<details>
slug: ai-authoring-workflow
published: 03/15/2026
author: Cory LaNou
author_twitter: @corylanou
seo_description: Learn how to combine AI coding assistants like Claude with Hype's build-time validation to write technical documentation faster while keeping every code example correct.
og_image: /images/og-ai-authoring.png
tags: tutorial, ai, authoring, workflow, claude, hype
tweet: AI can write docs fast, but how do you trust the code examples? Combine Claude with Hype's build-time validation — every snippet is verified before publish.
</details>

AI assistants are transforming how we write code. But when it comes to technical documentation, there's a trust problem: AI can generate plausible-looking code examples that don't actually work. Hype solves this by validating everything at build time — making AI-generated content trustworthy through automated verification.

This guide shows how to combine AI authoring with Hype's validation to write better documentation, faster.

## The Trust Problem

When an AI generates a code example for your documentation, it might:

- Use an API that was renamed two versions ago
- Import a package that doesn't exist
- Show output that doesn't match what the code actually produces
- Use syntax that's almost right but won't compile

In a regular Markdown file, these errors are invisible until a reader tries the code. In a Hype document, the build catches them immediately.

## The Workflow

The AI-assisted Hype authoring workflow has three phases:

1. **Generate** — AI writes the prose and code examples
2. **Validate** — Hype builds the document, catching errors
3. **Iterate** — AI fixes what the build caught

This is fundamentally different from the "generate and ship" workflow that produces unreliable documentation.

### Phase 1: Generate the Structure

Start by asking your AI assistant to create the document structure with real source files. The key instruction: **code examples must be separate `.go` files, not inline code blocks.**

For example, ask Claude:

> "Write a tutorial about Go's context package. Create the example code as separate Go files in a src/ directory, and reference them with Hype's include syntax."

The AI generates:

```
context-tutorial/
├── hype.md
└── src/
    ├── basic/main.go
    ├── timeout/main.go
    ├── cancel/main.go
    └── values/main.go
```

Each source file is a complete, runnable program. The `hype.md` references them with `<code>` and `<go>` tags.

### Phase 2: Build and Catch Errors

Run the build:

```bash
hype export -format markdown -f hype.md > /dev/null
```

The build might fail with something like:

```
Error: filepath: hype.md
document: Context Tutorial
execute error: src/timeout/main.go:15:
    ctx.WithTimeout undefined (type context.Context has no method WithTimeout)
```

The AI used `ctx.WithTimeout()` instead of `context.WithTimeout()`. A plausible mistake that a human reviewer might miss, but the compiler catches instantly.

### Phase 3: Fix and Rebuild

Give the error back to the AI:

> "The build failed. `context.WithTimeout` is a package-level function, not a method on Context. Fix src/timeout/main.go."

The AI fixes the code. You rebuild. The cycle continues until the build succeeds, at which point every code example in the document is verified correct.

## Practical Example: Writing a Package Tutorial

Let's walk through writing a complete tutorial using this workflow.

### Step 1: Set Up the Project

```bash
mkdir errors-tutorial && cd errors-tutorial
mkdir -p src/{wrapping,sentinel,custom,unwrap}
```

### Step 2: AI Generates the Content

Ask the AI to write the tutorial. Provide these constraints:

- Each concept gets its own subdirectory under `src/`
- Every Go file must be a complete `package main` with a `main()` function
- Use `<go>` tags to both show the code and run it
- Use snippets to highlight specific parts

The AI generates `hype.md`:

```markdown
# Effective Error Handling in Go

## Wrapping Errors

The `%w` verb in `fmt.Errorf` wraps an error, preserving the
original for inspection:

&lt;go src="src/wrapping" run="." code="main.go#wrap-example"&gt;&lt;/go&gt;

## Sentinel Errors

Define package-level sentinel errors for conditions callers
need to check:

&lt;go src="src/sentinel" run="." code="main.go#sentinel-def"&gt;&lt;/go&gt;

## Custom Error Types

Implement the `error` interface for errors that carry
structured data:

&lt;go src="src/custom" run="." code="main.go"&gt;&lt;/go&gt;

## Unwrapping and Checking

Use `errors.Is` and `errors.As` to inspect wrapped errors:

&lt;go src="src/unwrap" run="." code="main.go"&gt;&lt;/go&gt;
```

And the source files:

```go
// src/wrapping/main.go
package main

import (
    "errors"
    "fmt"
)

// snippet: wrap-example
func readConfig(path string) error {
    err := errors.New("file not found")
    return fmt.Errorf("readConfig(%q): %w", path, err)
}
// snippet: wrap-example

func main() {
    err := readConfig("/etc/app.conf")
    fmt.Println(err)
    fmt.Println("Unwrapped:", errors.Unwrap(err))
}
```

```go
// src/sentinel/main.go
package main

import (
    "errors"
    "fmt"
)

// snippet: sentinel-def
var (
    ErrNotFound     = errors.New("resource not found")
    ErrUnauthorized = errors.New("unauthorized access")
    ErrRateLimit    = errors.New("rate limit exceeded")
)
// snippet: sentinel-def

func findUser(id int) error {
    if id <= 0 {
        return fmt.Errorf("findUser: %w", ErrNotFound)
    }
    return nil
}

func main() {
    err := findUser(-1)
    if errors.Is(err, ErrNotFound) {
        fmt.Println("User not found (expected)")
    }
}
```

### Step 3: Build

```bash
hype export -format markdown -f hype.md
```

If everything compiles and runs, you have a validated tutorial. If not, the error tells you exactly what to fix.

### Step 4: Review and Refine

With the code validated, focus your review on:

- **Prose quality** — is the explanation clear and accurate?
- **Pedagogical flow** — do concepts build on each other logically?
- **Completeness** — are edge cases covered?

You don't need to manually verify that code examples work. The build already did that.

## Tips for AI-Assisted Hype Authoring

### Give the AI the Right Constraints

The most important instruction is to keep code in separate files:

> "Write code examples as standalone Go files in src/ subdirectories. Each must be a complete program that compiles and runs. Reference them with Hype `<go>` and `<code>` tags in the markdown."

### Use Snippets to Focus

AI-generated examples often include boilerplate. Use snippets to show only the relevant part:

> "Add snippet markers around the key function so the tutorial can show just that function while the full file still compiles."

### Let the Build Be the Reviewer

Don't spend time manually checking code examples. Build the document. If it passes, the code is correct. If it fails, the error message tells you exactly what's wrong.

### Iterate Quickly

The AI → build → fix cycle is fast:

1. AI generates or modifies a file
2. `hype export` runs in seconds
3. Error goes back to the AI
4. Repeat until green

A typical tutorial with 5-10 code examples goes from first draft to fully validated in a few minutes.

### Version Pin Your Examples

When the AI generates code, ask it to use specific versions:

> "Use Go 1.22's range-over-func feature. Make sure the go.mod specifies go 1.22."

This ensures the examples are reproducible and won't break with Go version changes.

## Stabilizing Dynamic Output

AI assistants often produce examples with dynamic output (timestamps, UUIDs, etc.). Use Hype's replace attributes to stabilize:

```html
&lt;cmd exec="go run ./src/timestamp"
     replace-1="\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}"
     replace-1-with="2024-01-15T10:30:00"&gt;&lt;/cmd&gt;
```

The command runs (validating it works), but the output is deterministic in the final document. No more noisy diffs from regenerating docs.

## CI Integration

Add validation to your CI pipeline so AI-generated docs are checked on every push:

```yaml
name: Validate Documentation
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

      - name: Build all tutorials
        run: |
          for doc in */hype.md; do
            dir=$(dirname "$doc")
            echo "Building ${dir}..."
            (cd "$dir" && hype export -format markdown -f hype.md > /dev/null)
          done
```

This catches regressions: if a Go update breaks an example, the CI build fails and you know exactly which document needs updating.

## What This Unlocks

The combination of AI authoring speed and Hype validation changes what's practical:

- **Write a tutorial in minutes, not hours** — AI generates the structure and examples, Hype verifies correctness
- **Update docs with confidence** — regenerate after dependency changes, the build catches every broken example
- **Scale documentation** — producing 10 validated tutorials is only slightly more work than producing 1
- **Trust AI-generated content** — the compiler is the reviewer, not a human scanning for plausible-but-wrong code

## Key Takeaways

- **AI generates, Hype validates** — plausible-looking code is verified by the compiler
- **Separate files, not inline code** — keep examples as real Go files that compile independently
- **Fast iteration cycles** — generate, build, fix, repeat until green
- **Focus human review on prose** — let the build handle code correctness
- **CI catches regressions** — automated builds surface broken examples from dependency changes
- **Stabilize dynamic output** — replace patterns keep regenerated docs diff-friendly

## Get Started

```bash
brew install gopherguides/tap/hype

mkdir my-tutorial && cd my-tutorial
mkdir -p src/example
```

Write your first AI-assisted tutorial. Ask the AI to create a Go example as a separate file, reference it with a `<go>` tag, and build. When the build passes, you have documentation you can trust.

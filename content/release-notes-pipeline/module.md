# Building a Release Notes Pipeline with Hype

<details>
slug: release-notes-pipeline
published: 03/15/2026
author: Cory LaNou
author_twitter: @caborundrum
seo_description: Build a release notes pipeline using Hype with executable code snippets, automated validation, and version-aware documentation that ships with every release.
tags: tutorial, release-notes, ci-cd, pipeline, hype
tweet: Bad release notes erode trust. Build a pipeline where every code example compiles, every command runs, and every API ref is verified at build time.
</details>

Release notes are the first thing users read after updating. Bad release notes — outdated examples, broken migration commands, incorrect API signatures — erode trust and generate support tickets. Hype lets you build release notes where every code example compiles, every command runs, and every API reference reflects the actual release.

## Why Release Notes Break

Traditional release notes are written in a Markdown file, usually by copying code snippets from the diff, manually running commands to verify output, and hoping someone catches mistakes in review. This breaks because:

- **Code examples are copy-pasted** — they're not validated against the actual build
- **Migration commands are written from memory** — they might work on the author's machine but not fresh installs
- **API signatures are typed by hand** — typos and outdated signatures slip through
- **Version numbers are hardcoded** — someone always forgets to update one

## Project Structure

Here's how to structure release notes as a Hype project:

```
releases/
├── v1.5.0/
│   ├── hype.md                    # Release notes source
│   ├── src/
│   │   ├── new-feature/main.go   # New feature example
│   │   ├── migration/main.go      # Migration example
│   │   └── breaking/main.go       # Breaking change example
│   └── scripts/
│       ├── migrate.sh             # Migration script
│       └── verify.sh              # Verification script
├── v1.4.0/
│   └── ...
└── template/
    ├── hype.md                    # Release notes template
    └── shared/
        └── footer.md             # Standard footer
```

Each release gets its own directory with real, compilable code examples and runnable scripts.

## Writing Release Notes with Hype

### New Feature: Executable Examples

When documenting a new feature, include a working example that demonstrates it:

```go
// src/new-feature/main.go
package main

import (
    "fmt"
    "yourpackage/v2/config"
)

func main() {
    // snippet: basic-usage
    cfg, err := config.Load("app.yaml",
        config.WithDefaults(),
        config.WithEnvOverrides("APP_"),
    )
    if err != nil {
        fmt.Printf("Error: %v\n", err)
        return
    }
    fmt.Printf("Loaded %d settings\n", cfg.Len())
    // snippet: basic-usage
}
```

Reference it in your release notes:

```markdown
## New: Configuration Loading API

The new `config.Load` function supports option chaining
for cleaner configuration setup:

&lt;code src="src/new-feature/main.go" snippet="basic-usage"&gt;&lt;/code&gt;

Running this with a sample config file:

&lt;go src="src/new-feature" run="."&gt;&lt;/go&gt;
```

When you build these release notes, Hype compiles the example against your actual package and runs it. If the API changed since you wrote the notes, the build fails.

### Migration Guides: Validated Step by Step

Migration instructions are the most critical part of release notes. A wrong command during migration can cause data loss. Validate every step:

```bash
#!/bin/bash
# src/scripts/migrate.sh

echo "=== Migration from v1.4 to v1.5 ==="

# Step 1: Update the dependency
echo "Step 1: Updating dependency..."
go get yourpackage/v2@v1.5.0

# Step 2: Run the migration tool
echo "Step 2: Running schema migration..."
go run ./cmd/migrate --from=v1.4 --to=v1.5 --dry-run

# Step 3: Verify
echo "Step 3: Verifying..."
go run ./cmd/verify
```

```markdown
## Migration Guide

Follow these steps to migrate from v1.4 to v1.5:

&lt;code src="scripts/migrate.sh"&gt;&lt;/code&gt;

Expected output on a successful migration:

&lt;cmd exec="bash scripts/migrate.sh"&gt;&lt;/cmd&gt;

If you see errors at Step 2, check the
[troubleshooting guide](/docs/troubleshooting/).
```

The migration script runs in CI. If the commands don't work against the current release, you find out before users do.

### Breaking Changes: Show the Compiler Error

When documenting breaking changes, show users exactly what they'll see and how to fix it:

```go
// src/breaking/old/main.go
package main

import "yourpackage/v2/auth"

// snippet: old-way
func authenticate(token string) bool {
    // This no longer compiles in v1.5
    return auth.Verify(token)
}
// snippet: old-way
```

```go
// src/breaking/new/main.go
package main

import (
    "context"
    "yourpackage/v2/auth"
)

// snippet: new-way
func authenticate(ctx context.Context, token string) (*auth.Claims, error) {
    return auth.Verify(ctx, token)
}
// snippet: new-way
```

```markdown
## Breaking Changes

### `auth.Verify` Now Requires Context

**Before (v1.4):**

&lt;code src="src/breaking/old/main.go" snippet="old-way"&gt;&lt;/code&gt;

Compiling old code produces:

&lt;go src="src/breaking/old" run="." exit="1"&gt;&lt;/go&gt;

**After (v1.5):**

&lt;code src="src/breaking/new/main.go" snippet="new-way"&gt;&lt;/code&gt;
```

The `exit="1"` attribute tells Hype the old code is expected to fail. Users see the exact compiler error they'll encounter, making it easy to find and fix their code.

### Version Information: Dynamic, Not Hardcoded

Use command execution to include version information dynamically:

```markdown
## Version Information

&lt;cmd exec="go run ./cmd/tool version"
     replace-1="v\d+\.\d+\.\d+"
     replace-1-with="v1.5.0"&gt;&lt;/cmd&gt;

Built with:

&lt;cmd exec="go version"
     replace-1="go\d+\.\d+\.\d+"
     replace-1-with="go1.22.0"&gt;&lt;/cmd&gt;
```

The `replace` attributes stabilize dynamic output. The actual command runs (validating it works), but version strings are normalized so the output doesn't change with every Go patch release.

## Automating the Pipeline

### CI Workflow for Release Notes

Validate release notes as part of your release process:

```yaml
name: Validate Release Notes
on:
  push:
    paths:
      - 'releases/**'
  pull_request:
    paths:
      - 'releases/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go install github.com/gopherguides/hype/cmd/hype@main

      - name: Validate all release notes
        run: |
          for release in releases/*/hype.md; do
            dir=$(dirname "$release")
            echo "Validating ${dir}..."
            cd "$dir"
            hype export -format markdown -f hype.md > /dev/null
            cd -
          done

      - name: Build latest release notes
        run: |
          latest=$(ls -d releases/v* | sort -V | tail -1)
          cd "$latest"
          hype export -format html -f hype.md > release-notes.html

      - uses: actions/upload-artifact@v4
        with:
          name: release-notes
          path: releases/*/release-notes.html
```

### Generate Multiple Formats

Produce release notes in every format your users need:

```bash
#!/bin/bash
# scripts/build-release-notes.sh

VERSION="${1:?Usage: build-release-notes.sh <version>}"
DIR="releases/${VERSION}"

if [ ! -f "${DIR}/hype.md" ]; then
    echo "No release notes found for ${VERSION}"
    exit 1
fi

cd "$DIR"

# HTML for the website
hype export -format html -f hype.md > release-notes.html

# Markdown for GitHub release
hype export -format markdown -f hype.md > RELEASE.md

echo "Built release notes for ${VERSION}"
```

### Integrate with GitHub Releases

Automate GitHub release creation with validated release notes:

```yaml
name: Create Release
on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go install github.com/gopherguides/hype/cmd/hype@main

      - name: Build release notes
        run: |
          VERSION=${GITHUB_REF_NAME}
          cd "releases/${VERSION}"
          hype export -format markdown -f hype.md > RELEASE.md

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          body_path: releases/$&#123;&#123; github.ref_name &#125;&#125;/RELEASE.md
```

Push a tag, the workflow builds the release notes (validating all examples), and creates the GitHub release with the generated Markdown.

## Release Notes Template

Start each release with a template that ensures consistency:

```markdown
<!-- template/hype.md -->
# Release vX.Y.Z

Released: [DATE]

## Highlights

[2-3 sentence summary of the most impactful changes]

## New Features

### [Feature Name]

[Description]

&lt;code src="src/feature/main.go" snippet="example"&gt;&lt;/code&gt;

## Improvements

- [Improvement 1]
- [Improvement 2]

## Breaking Changes

### [Change Description]

**Before:**

&lt;code src="src/breaking/old.go" snippet="old"&gt;&lt;/code&gt;

**After:**

&lt;code src="src/breaking/new.go" snippet="new"&gt;&lt;/code&gt;

## Migration Guide

&lt;code src="scripts/migrate.sh"&gt;&lt;/code&gt;

## Bug Fixes

- [Fix 1]
- [Fix 2]

&lt;include src="../shared/footer.md"&gt;&lt;/include&gt;
```

## Key Takeaways

- **Every example compiles** — code in release notes is validated against the actual release
- **Migration commands run** — scripts are executed in CI, not just documented
- **Breaking changes show real errors** — users see exact compiler messages they'll encounter
- **Dynamic version info** — command output is captured live, not typed by hand
- **Automated pipeline** — tag a release and get validated, multi-format release notes automatically
- **Templates ensure consistency** — every release follows the same structure

## Get Started

```bash
brew install gopherguides/tap/hype

mkdir -p releases/v1.0.0/src/feature
```

Start with your next release. Write one feature example as real code, include it in the notes, and build. Once you see a broken example caught at build time, you'll never go back to hand-written release notes.

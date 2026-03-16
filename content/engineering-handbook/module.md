# Automating Your Engineering Handbook with Hype

<details>
slug: engineering-handbook
published: 03/15/2026
author: Cory LaNou
author_twitter: @caborundrum
seo_description: Use Hype to build an internal engineering handbook that stays in sync with your codebase. Executable examples, automated validation, and single-source documentation for your team.
tags: tutorial, engineering, handbook, automation, hype
tweet: Your engineering handbook is probably wrong. Not because it was written badly — the code just changed. Here's how to make docs a build artifact with Hype.
</details>

Every engineering team has internal documentation. Style guides, onboarding docs, architecture decision records, runbook procedures. And almost universally, that documentation is wrong. Not because someone wrote it badly, but because the code changed and nobody updated the docs.

Hype fixes this by making your internal documentation a build artifact — derived from your actual code, validated at build time, and updated automatically.

## What Goes in an Engineering Handbook

A typical engineering handbook covers:

- **Coding standards** — naming conventions, error handling patterns, testing requirements
- **Architecture guides** — how services communicate, data flow, deployment topology
- **Onboarding** — environment setup, tooling, first-week checklist
- **Runbooks** — incident response procedures, common debugging commands
- **API documentation** — internal service contracts, request/response examples

All of these reference code. And all of them go stale.

## Project Structure

Here's how to organize a Hype-powered handbook:

```
handbook/
├── hype.md                        # Master handbook
├── config.yaml                    # Hype blog config (for web output)
├── content/
│   ├── onboarding/
│   │   ├── hype.md
│   │   └── src/
│   │       └── setup.sh
│   ├── coding-standards/
│   │   ├── hype.md
│   │   └── src/
│   │       ├── good/main.go
│   │       └── bad/main.go
│   ├── architecture/
│   │   ├── hype.md
│   │   └── diagrams/
│   ├── runbooks/
│   │   ├── hype.md
│   │   └── src/
│   │       └── healthcheck.sh
│   └── api/
│       ├── hype.md
│       └── src/
│           └── examples/
└── shared/
    └── conventions.md
```

## Coding Standards That Prove Themselves

The most powerful use of Hype in a handbook is coding standards that include real examples — both good and bad — with actual compiler and linter output.

### Good Examples That Compile

```go
// content/coding-standards/src/good/main.go
package main

import (
    "errors"
    "fmt"
)

// snippet: error-handling
func fetchUser(id int) (*User, error) {
    user, err := db.GetUser(id)
    if err != nil {
        return nil, fmt.Errorf("fetchUser(%d): %w", id, err)
    }
    return user, nil
}
// snippet: error-handling

// snippet: sentinel-errors
var (
    ErrNotFound    = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
)
// snippet: sentinel-errors
```

In your handbook:

```markdown
## Error Handling

Always wrap errors with context using `fmt.Errorf` and the `%w` verb:

&lt;code src="src/good/main.go" snippet="error-handling"&gt;&lt;/code&gt;

Use sentinel errors for conditions that callers need to check:

&lt;code src="src/good/main.go" snippet="sentinel-errors"&gt;&lt;/code&gt;
```

These examples compile. If someone changes the error handling API in a dependency update, the build catches it.

### Bad Examples That Intentionally Fail

Show anti-patterns with their actual compiler errors:

```go
// content/coding-standards/src/bad/main.go
package main

// snippet: unused-error
func riskyOperation() {
    result, _ := dangerousCall()
    fmt.Println(result)
}
// snippet: unused-error
```

```markdown
## What NOT To Do

Never discard errors with the blank identifier:

&lt;code src="src/bad/main.go" snippet="unused-error"&gt;&lt;/code&gt;

Here's what the linter says about this:

&lt;cmd exec="staticcheck ./src/bad/..." exit="1"&gt;&lt;/cmd&gt;
```

The `exit="1"` attribute tells Hype that this command is expected to fail. The linter output is captured and included in the document, showing the team exactly why this pattern is flagged.

## Onboarding Documentation

New engineer onboarding docs are notoriously fragile. "Run this command" instructions break when tools update, environment variables change, or infrastructure moves.

### Executable Setup Scripts

Instead of documenting commands in Markdown, keep them in an actual script:

```bash
#!/bin/bash
# content/onboarding/src/setup.sh

# Check Go version
go version

# Check Docker
docker --version

# Check kubectl
kubectl version --client

# Clone the monorepo
# git clone git@github.com:yourorg/monorepo.git

# Install development tools
go install golang.org/x/tools/gopls@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
```

Reference it in the onboarding guide:

```markdown
## Development Environment Setup

Run the setup script to verify your environment:

&lt;code src="src/setup.sh"&gt;&lt;/code&gt;

Here's what the output should look like on a properly configured machine:

&lt;cmd exec="bash src/setup.sh"&gt;&lt;/cmd&gt;
```

When you build the handbook, Hype runs the setup script and captures the output. If any tool is missing from the CI environment, the build fails — telling you the onboarding docs need updating.

## Runbooks with Validated Commands

Runbooks are critical during incidents. A wrong command in a runbook can make things worse. Hype ensures every command in your runbook actually works.

### Health Check Runbook

```bash
#!/bin/bash
# content/runbooks/src/healthcheck.sh

echo "=== Service Health Check ==="

# Check if the service is responding
echo "API Status:"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health || echo "UNREACHABLE"

# Check database connectivity
echo -e "\nDatabase:"
pg_isready -h localhost -p 5432 2>/dev/null && echo "OK" || echo "NOT READY"

# Check disk space
echo -e "\nDisk Space:"
df -h / | tail -1 | awk '{print $5 " used"}'

# Check memory
echo -e "\nMemory:"
free -h 2>/dev/null | grep Mem || vm_stat 2>/dev/null | head -5
```

```markdown
## Incident Response: Health Check

When paged, start with the health check script:

&lt;code src="src/healthcheck.sh"&gt;&lt;/code&gt;

Interpret the output:

| Check | Healthy | Action if unhealthy |
|-------|---------|-------------------|
| API Status | 200 | Check service logs, restart if needed |
| Database | OK | Check connection string, verify DB is running |
| Disk Space | < 80% | Clear logs, expand volume |
| Memory | < 90% | Check for memory leaks, restart service |
```

## Architecture Documentation with Go Doc

Hype can include `go doc` output directly in your handbook, keeping API documentation current:

```markdown
## Package API Reference

### The `auth` Package

&lt;go doc="-short ./internal/auth"&gt;&lt;/go&gt;

### Key Types

&lt;go doc="./internal/auth.Token"&gt;&lt;/go&gt;

&lt;go doc="./internal/auth.Claims"&gt;&lt;/go&gt;
```

Every time you build, `go doc` reflects the current code. When someone adds a method or changes a type signature, the handbook updates automatically.

## Building and Deploying

### As a Static Site

Use Hype's blog generator to serve the handbook as an internal website:

```bash
hype blog init handbook
# Move your content into the blog structure
hype blog build
hype blog serve
```

Deploy behind your VPN or internal network. Every push to the handbook repo triggers a rebuild and redeploy.

### As a Single Document

Generate a single comprehensive document:

```bash
# HTML for internal wiki
hype export -format html -f hype.md > handbook.html

# Markdown for GitHub/GitLab wiki
hype export -format markdown -f hype.md > HANDBOOK.md
```

### CI Validation

Add validation to your CI pipeline:

```yaml
name: Validate Handbook
on:
  push:
    paths:
      - 'handbook/**'
  schedule:
    - cron: '0 9 * * 1'  # Weekly Monday build

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - run: go install github.com/gopherguides/hype/cmd/hype@main
      - run: cd handbook && hype export -format html -f hype.md > /dev/null
```

The scheduled weekly build catches drift even when nobody is actively editing the handbook. If a dependency update breaks an example, you'll know on Monday morning instead of during an incident.

## Keeping It Alive

The biggest challenge with internal documentation isn't writing it — it's keeping it current. Hype addresses this by making staleness visible:

1. **Build failures are documentation bugs** — when code changes break the handbook build, you fix the docs as part of the code change
2. **Weekly CI builds catch drift** — scheduled builds surface problems even when the handbook isn't actively edited
3. **Pull request previews** — require handbook updates in the same PR that changes the code it documents
4. **Single source of truth** — code examples come from real files, not copy-pasted blocks that diverge

## Key Takeaways

- **Standards that compile** — coding guidelines backed by real examples the compiler validates
- **Onboarding that works** — setup scripts that run in CI, not just in the README
- **Runbooks you can trust** — commands validated before they're needed at 3 AM
- **Auto-updating API docs** — `go doc` output that reflects the current code
- **Drift detection** — scheduled builds catch stale docs before they cause problems

## Get Started

```bash
brew install gopherguides/tap/hype

mkdir handbook && cd handbook
mkdir -p content/coding-standards/src/{good,bad}
```

Start with your coding standards — they're the easiest to validate and the most impactful to keep current. Add one real code example, build, and expand from there.

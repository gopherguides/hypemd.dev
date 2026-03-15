# Installation

<details>
slug: docs/installation
published: 03/15/2026
author: Gopher Guides
seo_description: Hype documentation — Installation. Learn how to use this feature in the Hype dynamic Markdown engine.
tags: docs, installation, hype
</details>

## Installation

### Quick Install (Recommended)

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/gopherguides/hype/main/install.sh | bash
```

To install a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/gopherguides/hype/main/install.sh | bash -s v0.5.0
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/gopherguides/hype/main/install.ps1 | iex
```

To install a specific version:

```powershell
.\install.ps1 -Version v0.5.0
```

### Go Install

If you have Go installed:

```bash
go install github.com/gopherguides/hype/cmd/hype@latest
```

### Homebrew

```bash
brew install gopherguides/hype/hype-md
```

### Build from Source

```bash
git clone https://github.com/gopherguides/hype.git
cd hype
go install ./cmd/hype
```

### Verify Installation

```bash
hype version
```

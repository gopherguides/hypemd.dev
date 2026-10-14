# Keeping Code Samples and Docs in Sync with Hype

<details>
slug: docs-drift
published: 10/14/2026
author: Gopher Guides
seo_description: Keep code samples and command output in sync with Hype's build-time tags. Follow a runnable Go example through source changes, validation, and Markdown export.
tags: tutorial, docs, code, validation, workflow, hype
</details>

A code example can be correct when you write the documentation and wrong by the next release. A flag gets renamed, or a function takes another argument, and the code in the repository moves forward while the Markdown still shows the old version. The reader follows the instructions, gets an error, and has to work out which part of the documentation to trust.

Hype is a Markdown document generator that reads files and runs commands at build time. We can pull the example from the file we run and capture its output when we build the document. That removes the copied code and output we would otherwise need to maintain. We can also run those examples during validation, so a change that breaks them shows up before we publish. Let's work through a small Go command, change its behavior, and see what happens to the docs.

## Start with a Runnable Example

You'll need Go 1.25 or later and a current Hype CLI. These examples were tested against Hype commit `79c0476cad27`, the current `main` when this article was written. Install that revision for the same command behavior:

```bash
go install github.com/gopherguides/hype/cmd/hype@79c0476cad27
```

Make sure the Go binary directory is on your `PATH`. The [installation guide](/docs/installation/) covers setup. If you already have Hype installed, check that `hype validate -h` lists the `-exec` flag before following the validation steps below.

The [runnable example lives alongside this article](https://github.com/gopherguides/hypemd.dev/tree/main/content/docs-drift). To follow along, clone the site repository and enter the example directory:

```bash
git clone https://github.com/gopherguides/hypemd.dev.git
cd hypemd.dev/content/docs-drift
```

The directory contains `module.md` for this article, `example.md` for the small document we'll export, and a `src/` directory with `main.go` and `go.mod`. The Go program uses only the standard library. If you're building your own example, create the two source files with the contents shown here.

The module file, `src/go.mod`, sets the Go version:

<code src="src/go.mod" language="text"></code>

## Pull the Code and Output into Markdown

Here's the complete `example.md` source:

<code src="example.md" language="markdown"></code>

The `<code>` tag reads `src/main.go` into the document. Its path is relative to `example.md`, so we don't have to copy the program into a fenced block. However, reading a file doesn't prove that it compiles. That's why the document also has a `<go>` tag that runs the program.

The `src="src"` attribute sets the working directory for execution, and `run=". -name Cory"` runs `go run . -name Cory` there. The `<cmd>` tag uses that same directory to run the help command and capture its output. For a CLI written in another language, you can use `<cmd>` for the example execution too.

The code and terminal output below also come from live tags in this article. Blog commands run from the site root, so this page sets their working directory to `content/docs-drift/src`; the standalone `example.md` uses `src` relative to its own directory.

Here's `src/main.go`:

<code src="src/main.go"></code>

Run the command:

<go src="content/docs-drift/src" run=". -name Cory"></go>

And capture its help output:

<cmd src="content/docs-drift/src" exec="go run . -help"></cmd>

We now have one source file for the program and commands that produce the output. Changing the flag description changes the help output on the next build, without an edit to either Markdown file.

## Validate, Then Export

From the article's directory, check the document's structure:

```bash
hype validate -f example.md
```

This checks document integrity, including referenced source files and local anchor targets. It doesn't execute the Go program by default. To compile and run the commands in the document, add `-exec`:

```bash
hype validate -f example.md -exec
```

Both commands report `no issues found` for this example. The second check matters when the documentation promises working code: it runs the commands and fails if execution fails unexpectedly. You can use that command in CI before publishing.

Once validation passes, export the document:

```bash
hype export -f example.md -format markdown -o example.generated.md
hype export -f example.md -format html -o example.html
```

Export also executes the live tags. The generated Markdown contains ordinary code blocks with the source and output, and the HTML is ready to open in a browser. Keep `example.md` as the editable source; regenerate these outputs when the code changes.

## Change the Code and Rebuild

Now change the greeting in `src/main.go` from `Hello` to `Welcome`, leaving the Markdown alone. Run execution validation and the Markdown export again:

```bash
hype validate -f example.md -exec
hype export -f example.md -format markdown -o example.generated.md
```

Open `example.generated.md`. The source block now contains `Welcome`, and the captured program output says `Welcome, Cory!`. Both changed because Hype read and ran the updated file. With a pasted example and pasted output, we'd have had two more edits to remember.

However, the build still passing doesn't mean every sentence in the document is correct. If the prose had promised that the command always prints `Hello`, that sentence would now be stale. Hype updates the included code and captured output; we still have to review the explanation against the new behavior.

To see a failure, change `fmt.Printf` to `fmt.Printff` in the Go file and run the checks again. Plain `hype validate -f example.md` still succeeds because the file exists and the document structure is valid. Execution validation and export both fail because `go run` exits with status `1`. Hype reports the failed command; to see the compiler diagnostic directly, run `go run .` from `src/`. It reports `undefined: fmt.Printff`. Correct the typo and restore the greeting before continuing.

This is useful for API changes as well. If a documented caller uses a function signature that no longer exists, executing that caller gives the compiler a chance to catch it before a reader does. A `<code>` tag on its own would show the broken caller without catching the error.

## Put the Check in the Build

For a project using this layout, the following shell commands validate and export the example from the repository root:

```bash
set -eu
cd content/docs-drift
hype validate -f example.md -exec
hype export -f example.md -format markdown -o example.generated.md
```

Run them in CI after installing Go and the pinned Hype revision. Run them on code changes as well as documentation changes, since the source files can change without anyone touching Markdown. If your repository tracks generated docs, review the regenerated diff in the same pull request as the code change.

There are a few boundaries to keep in mind. Capturing output records what a command did; it doesn't compare that output against an expected result. Add tests for behavior you need to assert. Builds also need the tools and dependencies used by the examples. Keeping this example local and dependent only on Go makes it easier to reproduce than a command that needs a running service or changing network data. And because the tags execute commands, use documentation sources you trust and commands suitable for your build environment.

For this site, `make build` runs `hype blog build`, which renders the live source and command tags in this article into `public/docs-drift/index.html`.

If you want to generate both a README and a website from the same document, [Single-Source Documentation](/single-source-docs/) covers that workflow. [Automating Your Engineering Handbook](/engineering-handbook/) and [Building Training Materials](/training-materials/) apply these ideas to larger collections of documents.

Start with one example readers depend on. Move its code into a runnable file, reference it from the docs, and make execution validation part of the build that publishes those docs.

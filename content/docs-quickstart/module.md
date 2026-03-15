# Quick Start Guide

<details>
slug: docs/quickstart
published: 03/15/2026
author: Gopher Guides
seo_description: Hype documentation — Quick Start Guide. Learn how to use this feature in the Hype dynamic Markdown engine.
tags: docs, quickstart, hype
</details>


For more in depth examples, you can read our quick start guide
[here](https://www.gopherguides.com/articles/golang-hype-quickstart).

# The Basics

This is the syntax to include a code sample in your document:

```plain
&lt;code src="src/hello/main.go" snippet="example">&lt;/code&gt;

```

The above code snippet does the following:


* Includes the code snippet specified in the source code
* Validates that the code compiles


Here is the source file:

```go
package main

import "fmt"

// snippet: example
func main() {
 fmt.Println("Hello World")
}

// snippet: example

```

Notice the use of the `snippet` comment. The format for the comment is:

```plain
// snippet: <snippet_name_here>

```

You must have a beginning and an ending snippet for the code to work.

The output of including that tag will be as follows:

```go
func main() {
	fmt.Println("Hello World")
}
```
> *source: src/hello/main.go:example*


A `snippet` is not required in your `code` tag. The default behavior of a `code` tag is to include the entire source file.

If we leave the tag out, it will result in the following code being included:

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello World")
}
```
> *source: src/hello/main.go*


Notice that none of the `snippet` comments were in the output? This is because hype recognizes them as directives for the document, and will not show them in the actual output.

# Go Specific Commands

There are a number of [Go](https://go.dev/) specific commands you can run as well. Anything from executing the code and showing the output, to including go doc (from the standard library or your own source code), etc.

Let's look at how we use the `go` tag.

Here is the source code of the Go file we are going to include. Notice the use of the `snippet` comments to identify the area of code we want included. We'll see how to specify that in the next section when we include it in our markdown.

# Running Go Code

The following command will include the go source code, run it, and include the output of the program as well:

```plain
&lt;go src="src/hello" run=".">&lt;/go&gt;

```

Here is the result that will be included in your document from the above command:

```shell
$ go run .

Hello World

--------------------------------------------------------------------------------
Go Version: go1.25.0

```

## Running and Showing the Code

If you want to both run and show the code with the same tag, you can add the `code` attribute to the tag:

```plain
&lt;go src="src/hello" run="." code="main.go">&lt;/go&gt;

```

Now the source code is includes, as well as the output of the program:

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello World")
}
```
> *source: src/hello/main.go*


---

```shell
$ go run .

Hello World

--------------------------------------------------------------------------------
Go Version: go1.25.0

```

## Snippets with Go

You can also specify the snippet in a `go` tag as well. The result is that it will only include the code snippet in the included source:

```plain
&lt;go src="src/hello" run="." code="main.go#example">&lt;/go&gt;

```

You can see now that only the snippet is included, but the output is still the same:

```go
func main() {
	fmt.Println("Hello World")
}
```
> *source: src/hello/main.go#example:example*


---

```shell
$ go run .

Hello World

--------------------------------------------------------------------------------
Go Version: go1.25.0

```

## Invalid Code

What if you want to include an example of code that does not compile? We still want the code to be parsed and included, even though the code doesn't compile. For this, we can state the expected output of the program.

```plain
&lt;go src="src/broken" run="." code="main.go#example" exit="1">&lt;/go&gt;

```

The result now includes the snippet, and the error output from trying to compile the invalid source code.

```go
func main() {
	fmt.Prin("Hello World")
}
```
> *source: src/broken/main.go#example:example*


---

```shell
$ go run .

# github.com/gopherguides/hype/docs/quickstart/.
./main.go:7:6: undefined: fmt.Prin

--------------------------------------------------------------------------------
Go Version: go1.25.0

```

### GoDoc

While there are a number of `godoc` commands that will allow you to put your documentation from your code directly into your articles as well. Here are some of the commands.

Here is the basic usage first:

```plain
&lt;go doc="-short context">&lt;/go&gt;

```

Here is the output for the above command:

```shell
$ go doc -short context

var Canceled = errors.New("context canceled")
var DeadlineExceeded error = deadlineExceededError{}
func AfterFunc(ctx Context, f func()) (stop func() bool)
func Cause(c Context) error
func WithCancel(parent Context) (ctx Context, cancel CancelFunc)
func WithCancelCause(parent Context) (ctx Context, cancel CancelCauseFunc)
func WithDeadline(parent Context, d time.Time) (Context, CancelFunc)
func WithDeadlineCause(parent Context, d time.Time, cause error) (Context, CancelFunc)
func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc)
func WithTimeoutCause(parent Context, timeout time.Duration, cause error) (Context, CancelFunc)
type CancelCauseFunc func(cause error)
type CancelFunc func()
type Context interface{ ... }
    func Background() Context
    func TODO() Context
    func WithValue(parent Context, key, val any) Context
    func WithoutCancel(parent Context) Context

--------------------------------------------------------------------------------
Go Version: go1.25.0

```

You can also be more specific.

```plain
&lt;go doc="-short context.WithCancel">&lt;/go&gt;

```

Here is the output for the above command:
```shell
$ go doc -short context.WithCancel

func WithCancel(parent Context) (ctx Context, cancel CancelFunc)
    WithCancel returns a derived context that points to the parent context but
    has a new Done channel. The returned context's Done channel is closed when
    the returned cancel function is called or when the parent context's Done
    channel is closed, whichever happens first.

    Canceling this context releases resources associated with it, so code should
    call cancel as soon as the operations running in this Context complete.

--------------------------------------------------------------------------------
Go Version: go1.25.0

```

For more examples, see the [hype repo](https://www.github.com/gopherguides/hype).

# Arbitrary Commands

You can also use the `cmd` tag and the `exec` attribute to run arbitrary commands and include them in your documentation. Here is the command to run the `tree` command and include it in our documentation:

```html
&lt;cmd exec="tree" src=".">&lt;/cmd&gt;

```

Here is the output:

```shell
$ tree

.
├── hype.md
├── includes.md
└── src
    ├── broken
    │   └── main.go
    └── hello
        └── main.go

4 directories, 4 files
```

## Stabilizing Dynamic Output

Commands often produce output containing dynamic content like timestamps, version numbers, or UUIDs. When you regenerate your documentation, this dynamic content changes even though your actual code hasn't—creating noise in your version control and making it hard to see what really changed.

Use `replace-N` and `replace-N-with` attribute pairs to replace dynamic content with stable placeholders:

```html
&lt;cmd exec="go version"
     replace-1="go1\.\d+\.\d+"
     replace-1-with="goX.X.X">
&lt;/cmd&gt;

```

This ensures you get predictable, reproducible output every time you regenerate. The pattern is a regular expression, and replacements are applied in numeric order (1, 2, 3, …).

### Multiple Replacements

You can chain multiple replacements for commands with several dynamic values:

```html
&lt;cmd exec="./build.sh"
     replace-1="\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}"
     replace-1-with="YYYY-MM-DD HH:MM:SS"
     replace-2="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
     replace-2-with="[UUID]">
&lt;/cmd&gt;

```

This is essential for blogs, READMEs, and any documentation you regenerate regularly—without it, every regeneration creates a diff even when nothing meaningful changed.

# Embedding YouTube Videos

You can embed YouTube videos directly in your document using the `youtube` tag:

```html
<youtube id="VIDEO_ID"></youtube>

```

Where `VIDEO_ID` is the 11-character video ID from the YouTube URL. For example, from `https://www.youtube.com/watch?v=dQw4w9WgXcQ`, the video ID is `dQw4w9WgXcQ`.

You can also add an optional title for accessibility:

```html
<youtube id="dQw4w9WgXcQ" title="Introduction to Error Handling"></youtube>

```

The `youtube` tag renders a responsive iframe embed with proper security attributes:

```html
<div class="youtube-embed">
  <iframe src="https://www.youtube.com/embed/VIDEO_ID"
    title="Video Title"
    frameborder="0"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    referrerpolicy="strict-origin-when-cross-origin"
    allowfullscreen></iframe>
</div>

```

# The Export Command

There are several options for running the `hype` command. Most notable is the `export` option:

```plain
$ hype export -h

Usage of hype:
  -f string
     optional file name to preview, if not provided, defaults to hype.md (default "hype.md")
  -format string
     content type to export to: markdown, html (default "markdown")
  -timeout duration
     timeout for execution, defaults to 30 seconds (30s) (default 5s)
  -v enable verbose output for debugging

Usage: hype export [options]

Examples:
 hype export -format html
 hype export -f README.md -format html
 hype export -f README.md -format markdown -timeout=10s

```

This allows you to see your compiled document either as a single markdown, or as an html document that you can preview in the browser.

# Including Markdown

To include a markdown file, use the include tag. This will run that markdown file through the hype.Parser being used and append the results to the current document.

The paths specified in the src attribute of the include are relative to the markdown file they are used in. This allows you to move entire directory structures around in your project without having to change references within the documents themselves.

The following code will parse the code/code.md and sourceable/sourceable.md documents and append them to the end of the document they were included in.

```md
&lt;include src="code/code.md">&lt;/include&gt;

&lt;include src="sourceable/sourceable.md">&lt;/include&gt;
```
> *source: includes.md*

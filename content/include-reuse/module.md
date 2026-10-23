# Reusing Content Modules Across Docs, Blog Posts, and Courses

<details>
slug: include-reuse
published: 10/14/2026
author: Gopher Guides
author_twitter: @hype_markdown
seo_description: Use Hype includes to share explanations and runnable examples across docs, blog posts, and courses. Build a reusable content tree with tested export commands.
og_image: /images/og-include-reuse.png
tags: tutorial, includes, reuse, docs, training, hype
</details>

An explanation of context cancellation might start in your API docs, then become part of a blog post and a Go course. The docs explain how to use it, the post gives readers a reason to care, and the course asks students to try it themselves. The example can be the same in all three, even though the surrounding material is different.

Copying that explanation into each document gives you three places to maintain it. And when you correct the example or clarify the wording, every copy needs the same edit. With Hype, we can keep that explanation and its runnable example together in a shared content module, then use `<include>` to place it in each document.

Hype processes Markdown, includes files, and executes code when you build. Let's use it to assemble three documents from the same module, while keeping the introductions and exercises specific to their readers.

If you're generating a README and website from one complete document, start with [Single-Source Documentation](/single-source-docs/). Here, each output has its own document. We're choosing which pieces those documents share. For more on organizing a complete course, see [Building Training Materials with Hype](/training-materials/).

## Start with the Shared Content

A reusable module should make sense wherever you include it. For this example, the shared content explains what cancellation does and shows a small program that checks a canceled context. The blog's story about a disconnected client and the course's exercise belong in their own documents.

Put the entry documents at the root of a content tree and the shared material beneath them:

```text
content-reuse/
├── docs.md
├── blog.md
├── course.md
├── build.sh
└── shared/
    └── context-cancellation/
        ├── module.md
        ├── explanation.md
        ├── example.md
        └── src/
            └── main.go
```

The files for this example are in [the site's repository](https://github.com/gopherguides/hypemd.dev), under `content/include-reuse/src/content-reuse/`. You can copy the files shown below into the same tree. You'll need Hype and Go on your path; the program uses only Go's standard library. The [installation guide](/docs/installation/) covers installing Hype.

Keeping the entry documents together matters. Hype resolves an include relative to the file containing the tag, and the CLI limits file access to the input document's tree. An entry document in a `docs/` subdirectory can't reach a sibling `shared/` directory using `../shared/`; that produces a `sub ...: invalid argument` error. Put the shared directory beneath the common root instead.

## Build a Module That Carries Its Example

Start with `shared/context-cancellation/explanation.md`:

<code src="src/content-reuse/shared/context-cancellation/explanation.md" language="markdown"></code>

That explanation doesn't refer to a previous lesson, promise an exercise, or assume the reader came from a particular page. So we can use it in all three documents without asking the reader to ignore parts that don't apply.

Next, create `shared/context-cancellation/src/main.go`:

<code src="src/content-reuse/shared/context-cancellation/src/main.go"></code>

The program cancels the context before printing its error. It prints `Canceled: context canceled`. We're keeping the example small because the purpose here is to show how the content travels between documents.

In `shared/context-cancellation/example.md`, include the source and run it:

<code src="src/content-reuse/shared/context-cancellation/example.md" language="markdown"></code>

The `<code>` tag reads the file; the `<go>` tag runs `go run main.go` from the `src` directory and captures its output. Including a code file alone doesn't compile or test it. The execution tag is what checks that this example runs successfully.

Now assemble `shared/context-cancellation/module.md`:

<code src="src/content-reuse/shared/context-cancellation/module.md" language="markdown"></code>

Each nested include resolves from this module's directory. `example.md` then refers to its own `src/main.go`. The module carries its explanation, code, and execution instructions together, so the documents using it don't need to know how those files are arranged internally.

Hype inserts the included content where the tag appears and processes the tags inside it. For example, this paragraph is a live include of the same `explanation.md`:

<include src="src/content-reuse/shared/context-cancellation/explanation.md"></include>

## Give Each Audience Its Own Document

Create `docs.md` at the root of `content-reuse/`:

<code src="src/content-reuse/docs.md" language="markdown"></code>

The reference introduces the rule and closes with guidance about checking the context. The shared module supplies the explanation and example between them.

For `blog.md`, give readers a situation in which cancellation matters:

<code src="src/content-reuse/blog.md" language="markdown"></code>

The include is identical, but the post has its own opening and follow-up. We can revise the story without changing the reference document or the lesson.

Then create `course.md`:

<code src="src/content-reuse/course.md" language="markdown"></code>

The exercise asks students to change the order of the statements and explain the result. It stays in the lesson because a reader consulting the API docs doesn't need that assignment. Students should work in a separate copy of the program so their changes don't alter the example used by the other documents.

Notice that the shared module uses a second-level heading, while each entry document owns its title. Hype includes the module's heading as written. If you need the same explanation under a different heading, include `explanation.md` directly and write that heading in the entry document, as this article does.

## Export All Three Outputs

From the `content-reuse/` directory, save this as `build.sh`:

<code src="src/content-reuse/build.sh" language="bash"></code>

Run it with:

```bash
sh build.sh
```

The documentation becomes Markdown, and the blog post and lesson become HTML. These HTML files are standalone documents you can open in a browser; `hype export` doesn't publish them to a blog or upload them to a learning platform. If you're building a Hype blog, use the site's `content/<slug>/module.md` entry format and keep includes beneath that article's directory.

The `-o` flag writes each export to its output file after processing succeeds. `set -eu` stops the script if an export fails. This article runs that script during the site build using a live `<cmd>` tag, which produces:

<cmd src="content/include-reuse/src/content-reuse" exec="sh build.sh"></cmd>

Every export reads the same module and runs its Go example. If the example doesn't compile or an included file is missing, that export fails. The docs, post, and lesson still need a review for their own explanations and audience needs.

## Keep the Content Tree Understandable

Group shared modules by topic, as we did with `context-cancellation/`. Keeping the source beside its explanation makes it easier to review a change: someone correcting the example can see the prose that explains its behavior. Add another topic directory when you have another explanation that multiple documents need.

Keep includes flowing from entry documents into shared modules, and from modules into their supporting files. A shared module that includes the blog post using it creates a cycle. Avoid that dependency by leaving audience-specific material in the entry documents.

Don't split every paragraph into a file. Start with a complete explanation and its example. Extract a smaller piece when a real use needs it, as we did with `explanation.md` so this article could show the prose on its own. Otherwise, the extra files make the explanation harder to follow while you're editing it.

And check ordinary Markdown links separately. File paths in Hype tags and links readers click have different jobs. Use links that work where you'll publish each output, or put output-specific links in the entry document. An include doesn't make a link appropriate for every destination.

To try the update workflow, edit a sentence in `shared/context-cancellation/explanation.md` and run `sh build.sh` again. Open `output/docs.md`, `output/blog.html`, and `output/course.html` and check that each contains the correction. Then pick one explanation you've been maintaining in several places and move it, along with its example, into a shared module.

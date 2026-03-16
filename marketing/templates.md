# X/Twitter Post Templates for hypemd.dev

## Variables

| Variable | Source | Example |
|----------|--------|---------|
| `{title}` | First `# ` heading | Getting Started with Hype |
| `{slug}` | Frontmatter | getting-started |
| `{seo_description}` | Frontmatter | Learn how to install Hype... |
| `{tags}` | Frontmatter | tutorial, getting-started, hype |
| `{author}` | Frontmatter | Gopher Guides |
| `{url}` | Generated with UTM | https://hypemd.dev/getting-started/?utm_source=twitter&... |

## Single Post Templates

### Tutorial Posts

**Technical:**
> {seo_description} {url}

**Founder Voice:**
> We built this with Hype because {title} shouldn't be harder than it needs to be: {url}

**Short Hook:**
> {title} — powered by dynamic Markdown. {url}

### Usage Scenario Posts

**Technical:**
> {seo_description} {url}

**Founder Voice:**
> We've been using Hype for {title} and it's been a game changer. Here's how: {url}

**Short Hook:**
> {title} — see how teams are using Hype. {url}

## Thread Templates

### Tutorial Thread (3 posts)

**Post 1 (Hook):**
> {seo_description}
>
> A thread on {title} with @hype_markdown

**Post 2 (Key insight):**
> It starts with {first_section} — Hype makes this straightforward because your Markdown is dynamic. Code blocks execute, files get included, and everything is validated at build time.

**Post 3 (CTA):**
> Full walkthrough here: {url}
>
> {hashtags}

### Announcement Thread (4 posts)

**Post 1:** Bold claim about the problem being solved.

**Post 2:** Why existing solutions fall short.

**Post 3:** How Hype solves it differently (with a concrete example).

**Post 4:** Link + CTA + hashtags.

## Hashtag Reference

**Always include:**
- `#HypeMarkdown`
- `#Golang`
- `#OpenSource`

**Conditional (based on tags):**

| Tag | Hashtag |
|-----|---------|
| docker | #Docker |
| ai, claude | #AI |
| workflow | #DevWorkflow |
| authoring | #TechWriting |
| training | #Training |
| documentation, docs | #Documentation |
| release* | #ReleaseNotes |
| handbook | #EngineeringHandbook |

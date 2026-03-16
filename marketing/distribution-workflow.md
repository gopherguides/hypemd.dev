# Distribution Workflow

## Quick Start

```bash
./marketing/distribute.sh <slug>
# or
make distribute SLUG=<slug>
```

Example:
```bash
make distribute SLUG=getting-started
```

## Process

1. **Publish** the blog post (merge to main, auto-deploys via Dokploy)
2. **Generate** post variants: `make distribute SLUG=<slug>`
3. **Review and edit** the generated variants — tweak tone, add context
4. **Post** to X (manually, via X scheduler, or via Buffer)
5. **Cross-post** to LinkedIn if appropriate (rewrite for longer format)

## UTM Conventions

All generated URLs include UTM parameters for tracking.

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `utm_source` | `twitter`, `linkedin`, `newsletter` | Where the click came from |
| `utm_medium` | `social`, `email` | Channel type |
| `utm_content` | `technical`, `founder`, `hook`, `thread` | Which variant was clicked |

Example URL:
```
https://hypemd.dev/getting-started/?utm_source=twitter&utm_medium=social&utm_content=technical
```

## Which Posts to Promote

| Post Type | Promote? | Example |
|-----------|----------|---------|
| Tutorial posts | Yes | getting-started, deploying-with-docker |
| Usage scenario posts | Yes | ai-authoring-workflow, release-notes-pipeline |
| Documentation posts (docs-*) | No | These are reference material |

## Post Timing Guidelines

| Content Type | Best Time | Best Days |
|-------------|-----------|-----------|
| Tutorials | 9-11am ET | Weekdays |
| Usage scenarios | 10am-1pm ET | Tue-Thu |
| Announcements | 9am-12pm ET | Any weekday |

## Scheduler Integration

### X Built-in Scheduler

1. Compose your tweet on X
2. Click the calendar icon
3. Pick date and time
4. Schedule

Best for one-off posts.

### Buffer (Free Tier)

- 3 channels, 10 scheduled posts per channel
- Paste generated text, set schedule
- Best for batching a week of posts

### X API v2 (Advanced)

For automated posting, use the X API directly:

```bash
curl -X POST "https://api.x.com/2/tweets" \
  -H "Authorization: Bearer $X_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text": "Your tweet text here"}'
```

Store the bearer token in an environment variable. Never commit tokens to the repo.

## Measuring Results

- Check UTM parameters in your analytics tool
- `utm_content` tells you which variant performed best
- Compare `technical` vs `founder` vs `hook` click-through rates
- Iterate on templates based on what resonates

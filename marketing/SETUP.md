# X/Twitter API Setup

## 1. Create an X Developer Account

1. Go to https://developer.x.com and sign in with the @hype_markdown account
2. Sign up for the **Free** tier (1,500 tweets/month, write-only)
3. Create a new **Project** and **App**

## 2. Configure App Permissions

1. In your app settings, go to **User authentication settings**
2. Set app permissions to **Read and Write**
3. After changing permissions, **regenerate** your Access Token and Access Token Secret (old tokens won't have the new permissions)

## 3. Generate Credentials

From your app's **Keys and Tokens** page, you need 4 values:

| Credential | Environment Variable |
|-----------|---------------------|
| API Key (Consumer Key) | `X_API_KEY` |
| API Secret (Consumer Secret) | `X_API_SECRET` |
| Access Token | `X_ACCESS_TOKEN` |
| Access Token Secret | `X_ACCESS_TOKEN_SECRET` |

## 4. Local Setup

Copy the credentials into `.envrc` at the project root:

```bash
export X_API_KEY="your-api-key"
export X_API_SECRET="your-api-secret"
export X_ACCESS_TOKEN="your-access-token"
export X_ACCESS_TOKEN_SECRET="your-access-token-secret"
```

Then activate with direnv:

```bash
direnv allow
```

Test with a dry run:

```bash
make tweet-dry SLUG=getting-started
```

## 5. CI Setup (GitHub Actions)

Set the repository secrets using the `gh` CLI:

```bash
gh secret set X_API_KEY --body "your-api-key"
gh secret set X_API_SECRET --body "your-api-secret"
gh secret set X_ACCESS_TOKEN --body "your-access-token"
gh secret set X_ACCESS_TOKEN_SECRET --body "your-access-token-secret"
```

Once set, the `tweet.yml` workflow will automatically tweet when blog posts with a `tweet` field are merged to main.

## 6. Manual Tweeting

To tweet an existing post manually:

```bash
make tweet SLUG=getting-started
```

To preview without posting:

```bash
make tweet-dry SLUG=getting-started
```

## Adding Tweets to Blog Posts

Add a `tweet` field to the `<details>` frontmatter block in any blog post:

```markdown
<details>
slug: my-article
published: 03/16/2026
author: Gopher Guides
seo_description: Full SEO description here
tags: tutorial, hype
tweet: Short punchy text for X (max ~250 chars, URL is appended automatically)
</details>
```

The script automatically appends the post URL, so keep the tweet text under ~250 characters.

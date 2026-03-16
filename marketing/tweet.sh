#!/usr/bin/env bash
set -euo pipefail

SITE_URL="https://hypemd.dev"
API_URL="https://api.x.com/2/tweets"

usage() {
    echo "Usage: $0 [--dry-run] <content-slug>"
    echo ""
    echo "Post a tweet for a blog post using the 'tweet' field from its frontmatter."
    echo ""
    echo "Options:"
    echo "  --dry-run    Preview the tweet without posting"
    echo ""
    echo "Examples:"
    echo "  $0 getting-started"
    echo "  $0 --dry-run ai-authoring-workflow"
    echo ""
    echo "Environment variables (required unless --dry-run):"
    echo "  X_API_KEY            Consumer API key"
    echo "  X_API_SECRET         Consumer API secret"
    echo "  X_ACCESS_TOKEN       Access token"
    echo "  X_ACCESS_TOKEN_SECRET Access token secret"
    exit 1
}

DRY_RUN=false
SLUG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) usage ;;
        -*) echo "Unknown option: $1" >&2; usage ;;
        *) SLUG="$1"; shift ;;
    esac
done

if [[ -z "$SLUG" ]]; then
    usage
fi

FILE="content/${SLUG}/module.md"
if [[ ! -f "$FILE" ]]; then
    echo "Error: $FILE not found" >&2
    exit 1
fi

details=$(awk '/<details>/{found=1; next} /<\/details>/{if(found) exit} found{print}' "$FILE")
slug=$(echo "$details" | grep '^slug:' | head -1 | sed 's/^slug: *//')
tweet_text=$(echo "$details" | grep '^tweet:' | head -1 | sed 's/^tweet: *//')

if [[ -z "$tweet_text" ]]; then
    echo "Error: no 'tweet' field found in $FILE frontmatter" >&2
    exit 1
fi

post_url="${SITE_URL}/${slug}/"
full_tweet="${tweet_text} ${post_url}"

char_count=${#full_tweet}
if [[ $char_count -gt 280 ]]; then
    echo "WARNING: Tweet is ${char_count} chars (limit 280). URLs count as 23 chars on X, so actual count may differ." >&2
fi

echo "=== Tweet Preview ==="
echo "$full_tweet"
echo ""
echo "Characters: ${char_count} (URLs count as 23 on X)"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "[Dry run — not posted]"
    exit 0
fi

for var in X_API_KEY X_API_SECRET X_ACCESS_TOKEN X_ACCESS_TOKEN_SECRET; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: $var is not set. See marketing/SETUP.md for instructions." >&2
        exit 1
    fi
done

urlencode() {
    local string="$1"
    python3 -c "import urllib.parse; print(urllib.parse.quote('$string', safe=''))" 2>/dev/null \
        || printf '%s' "$string" | curl -Gso /dev/null -w '%{url_effective}' --data-urlencode @- '' | cut -c3-
}

generate_nonce() {
    openssl rand -hex 16
}

oauth_timestamp=$(date +%s)
oauth_nonce=$(generate_nonce)

oauth_consumer_key="$X_API_KEY"
oauth_token="$X_ACCESS_TOKEN"
oauth_signature_method="HMAC-SHA1"
oauth_version="1.0"

escaped_tweet=$(urlencode "$full_tweet")

param_string="oauth_consumer_key=${oauth_consumer_key}&oauth_nonce=${oauth_nonce}&oauth_signature_method=${oauth_signature_method}&oauth_timestamp=${oauth_timestamp}&oauth_token=${oauth_token}&oauth_version=${oauth_version}"

signature_base="POST&$(urlencode "$API_URL")&$(urlencode "$param_string")"

signing_key="$(urlencode "$X_API_SECRET")&$(urlencode "$X_ACCESS_TOKEN_SECRET")"

oauth_signature=$(printf '%s' "$signature_base" | openssl dgst -sha1 -hmac "$signing_key" -binary | base64)

auth_header="OAuth oauth_consumer_key=\"${oauth_consumer_key}\", oauth_nonce=\"${oauth_nonce}\", oauth_signature=\"$(urlencode "$oauth_signature")\", oauth_signature_method=\"${oauth_signature_method}\", oauth_timestamp=\"${oauth_timestamp}\", oauth_token=\"${oauth_token}\", oauth_version=\"${oauth_version}\""

response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "Authorization: ${auth_header}" \
    -H "Content-Type: application/json" \
    -d "{\"text\": $(printf '%s' "$full_tweet" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')}")

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" == "201" ]]; then
    tweet_id=$(echo "$body" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['data']['id'])" 2>/dev/null || echo "unknown")
    echo "Tweet posted successfully!"
    echo "https://x.com/hype_markdown/status/${tweet_id}"
else
    echo "Error posting tweet (HTTP ${http_code}):" >&2
    echo "$body" >&2
    exit 1
fi

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

python3 - "$full_tweet" << 'PYEOF'
import urllib.parse, hashlib, hmac, base64, time, os, json, secrets, sys, subprocess

tweet = sys.argv[1]
api_key = os.environ["X_API_KEY"]
api_secret = os.environ["X_API_SECRET"]
access_token = os.environ["X_ACCESS_TOKEN"]
access_token_secret = os.environ["X_ACCESS_TOKEN_SECRET"]

url = "https://api.x.com/2/tweets"

oauth_nonce = secrets.token_hex(16)
oauth_timestamp = str(int(time.time()))

params = {
    "oauth_consumer_key": api_key,
    "oauth_nonce": oauth_nonce,
    "oauth_signature_method": "HMAC-SHA1",
    "oauth_timestamp": oauth_timestamp,
    "oauth_token": access_token,
    "oauth_version": "1.0",
}

param_string = "&".join(
    f"{urllib.parse.quote(k, safe='')}={urllib.parse.quote(v, safe='')}"
    for k, v in sorted(params.items())
)
signature_base = f"POST&{urllib.parse.quote(url, safe='')}&{urllib.parse.quote(param_string, safe='')}"
signing_key = f"{urllib.parse.quote(api_secret, safe='')}&{urllib.parse.quote(access_token_secret, safe='')}"
signature = base64.b64encode(
    hmac.new(signing_key.encode(), signature_base.encode(), hashlib.sha1).digest()
).decode()

auth_header = (
    f'OAuth oauth_consumer_key="{urllib.parse.quote(api_key, safe="")}", '
    f'oauth_nonce="{urllib.parse.quote(oauth_nonce, safe="")}", '
    f'oauth_signature="{urllib.parse.quote(signature, safe="")}", '
    f'oauth_signature_method="HMAC-SHA1", '
    f'oauth_timestamp="{oauth_timestamp}", '
    f'oauth_token="{urllib.parse.quote(access_token, safe="")}", '
    f'oauth_version="1.0"'
)

result = subprocess.run(
    ["curl", "-s", "-w", "\n%{http_code}", "-X", "POST", url,
     "-H", f"Authorization: {auth_header}",
     "-H", "Content-Type: application/json",
     "-d", json.dumps({"text": tweet})],
    capture_output=True, text=True
)

output = result.stdout.strip()
http_code = output.split("\n")[-1]
body = "\n".join(output.split("\n")[:-1])

if http_code == "201":
    data = json.loads(body)
    tweet_id = data["data"]["id"]
    print("Tweet posted successfully!")
    print(f"https://x.com/hype_markdown/status/{tweet_id}")
else:
    print(f"Error posting tweet (HTTP {http_code}):", file=sys.stderr)
    print(body, file=sys.stderr)
    sys.exit(1)
PYEOF

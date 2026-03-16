#!/usr/bin/env bash
set -euo pipefail

SITE_URL="https://hypemd.dev"
HANDLE="@hype_markdown"
MAX_CHARS=280

usage() {
    echo "Usage: $0 <content-slug>"
    echo ""
    echo "Generate X/Twitter post variants for a blog post."
    echo ""
    echo "Examples:"
    echo "  $0 getting-started"
    echo "  $0 ai-authoring-workflow"
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

SLUG="$1"
FILE="content/${SLUG}/module.md"

if [[ ! -f "$FILE" ]]; then
    echo "Error: $FILE not found" >&2
    exit 1
fi

title=$(grep -m1 '^# ' "$FILE" | sed 's/^# //')
details=$(awk '/<details>/{found=1; next} /<\/details>/{if(found) exit} found{print}' "$FILE")
slug=$(echo "$details" | grep '^slug:' | head -1 | sed 's/^slug: *//')
seo_desc=$(echo "$details" | grep '^seo_description:' | head -1 | sed 's/^seo_description: *//')
tags=$(echo "$details" | grep '^tags:' | head -1 | sed 's/^tags: *//')
author=$(echo "$details" | grep '^author:' | head -1 | sed 's/^author: *//')

if [[ -z "$title" ]]; then
    echo "Error: could not parse title from $FILE" >&2
    exit 1
fi

if [[ "$slug" == docs/* || "$slug" == "docs" ]]; then
    echo "WARNING: This appears to be a documentation page (slug: ${slug}). Docs pages are typically not promoted on social media." >&2
    echo "" >&2
fi

is_tutorial=false
if echo "$tags" | grep -qi 'tutorial'; then
    is_tutorial=true
fi

build_url() {
    local variant="$1"
    echo "${SITE_URL}/${slug}/?utm_source=twitter&utm_medium=social&utm_content=${variant}"
}

print_variant() {
    local label="$1"
    local text="$2"
    local chars=${#text}
    echo "=== ${label} ==="
    echo "$text"
    echo ""
    echo "Characters: ${chars}"
    if [[ $chars -gt $MAX_CHARS ]]; then
        echo "WARNING: Exceeds ${MAX_CHARS} character limit by $((chars - MAX_CHARS)) characters"
    fi
    echo ""
}

build_hashtags() {
    local -a all=("#HypeMarkdown" "#Golang" "#OpenSource")

    IFS=',' read -ra tag_arr <<< "$tags"
    for tag in "${tag_arr[@]}"; do
        tag=$(echo "$tag" | sed 's/^ *//;s/ *$//')
        case "$tag" in
            tutorial|getting-started|hype) ;;
            docker) all+=("#Docker") ;;
            ai|claude) all+=("#AI") ;;
            workflow) all+=("#DevWorkflow") ;;
            authoring) all+=("#TechWriting") ;;
            training) all+=("#Training") ;;
            documentation|docs) all+=("#Documentation") ;;
            release*) all+=("#ReleaseNotes") ;;
            handbook) all+=("#EngineeringHandbook") ;;
            *) all+=("#${tag^}") ;;
        esac
    done

    local seen=""
    local result=""
    for h in "${all[@]}"; do
        if [[ "$seen" != *"$h"* ]]; then
            result="$result $h"
            seen="$seen $h"
        fi
    done
    echo "${result# }"
}

url_technical=$(build_url "technical")
url_founder=$(build_url "founder")
url_hook=$(build_url "hook")

if [[ "$is_tutorial" == true ]]; then
    technical="${seo_desc} ${url_technical}"
    founder="We built Hype because documentation shouldn't lie. Here's how to get started with dynamic Markdown that validates everything at build time: ${url_founder}"
    hook="Your Markdown can run code now. ${url_hook}"

    case "$slug" in
        getting-started)
            technical="Learn how to install Hype and create your first dynamic Markdown document with build-time code execution. ${url_technical}"
            founder="We built Hype because documentation shouldn't lie. Here's a quick guide to get started: ${url_founder}"
            hook="What if your Markdown could execute code and catch errors before publish? ${url_hook}"
            ;;
        deploying-with-docker)
            technical="Deploy a Hype-powered blog with Docker — from Dockerfile to production with auto-rebuilds. ${url_technical}"
            founder="We wanted deploying a Hype blog to be as simple as 'docker build && docker run'. Here's how: ${url_founder}"
            hook="Ship your Hype blog in a container. ${url_hook}"
            ;;
        *)
            technical="${seo_desc} ${url_technical}"
            founder="We built this with Hype because ${title,,} shouldn't be harder than it needs to be: ${url_founder}"
            hook="${title} — powered by dynamic Markdown. ${url_hook}"
            ;;
    esac
else
    technical="${seo_desc} ${url_technical}"
    founder="We've been using Hype for ${title,,} and it's been a game changer. Here's how: ${url_founder}"
    hook="${title} — see how teams are using Hype. ${url_hook}"
fi

echo "========================================"
echo "X/Twitter Posts for: ${title}"
echo "Post type: $(if $is_tutorial; then echo 'Tutorial'; else echo 'Usage Scenario'; fi)"
echo "========================================"
echo ""

print_variant "TECHNICAL VARIANT" "$technical"
print_variant "FOUNDER VOICE VARIANT" "$founder"
print_variant "SHORT HOOK VARIANT" "$hook"

hashtags=$(build_hashtags)
echo "=== HASHTAGS ==="
echo "$hashtags"
echo ""

if [[ "$is_tutorial" == true ]]; then
    url_thread=$(build_url "thread")
    echo "=== THREAD VARIANT (3 posts) ==="
    echo ""
    echo "1/3:"
    echo "${seo_desc}"
    echo ""
    echo "A thread on ${title,,} with @hype_markdown 🧵"
    echo ""
    echo "2/3:"
    first_section=$(sed -n '/^## /{s/^## //;p;q;}' "$FILE")
    if [[ -n "$first_section" ]]; then
        echo "It starts with ${first_section,,} — Hype makes this straightforward because your Markdown is dynamic. Code blocks execute, files get included, and everything is validated at build time."
    else
        echo "Hype makes this straightforward because your Markdown is dynamic. Code blocks execute, files get included, and everything is validated at build time."
    fi
    echo ""
    echo "3/3:"
    echo "Full walkthrough here: ${url_thread}"
    echo ""
    echo "${hashtags}"
    echo ""
fi

echo "=== UTM URLS ==="
echo "Technical: ${url_technical}"
echo "Founder:   ${url_founder}"
echo "Hook:      ${url_hook}"
if [[ "$is_tutorial" == true ]]; then
    echo "Thread:    $(build_url "thread")"
fi

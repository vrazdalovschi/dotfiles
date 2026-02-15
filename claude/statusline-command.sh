#!/usr/bin/env bash

# ANSI Colors
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
CYAN='\033[36m'
MAGENTA='\033[35m'
DIM='\033[2m'
RESET='\033[0m'

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')

# Git branch and repository path
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)

    if [ -n "$repo_root" ]; then
        rel_path="${cwd#$repo_root}"
        rel_path="${rel_path#/}"
        [ -z "$rel_path" ] && rel_path=$(basename "$repo_root")
    else
        rel_path=$(basename "$cwd")
    fi

    if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
        git_status="✗"
    else
        git_status="✓"
    fi

    git_info=$(printf "${MAGENTA}%s${RESET} ${YELLOW}%s${RESET}" "$branch" "$git_status")
else
    rel_path=$(basename "$cwd")
    git_info=""
fi

# Calculate context percentage with color gradient
context_info=""
pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
if [ -n "$pct" ] && [ "$pct" != "null" ]; then
    if [ "$pct" -lt 30 ]; then
        context_info=$(printf "${GREEN}%d%%${RESET}" "$pct")
    elif [ "$pct" -lt 60 ]; then
        context_info=$(printf "${YELLOW}%d%%${RESET}" "$pct")
    else
        context_info=$(printf "${RED}%d%%${RESET}" "$pct")
    fi
fi

# 5-hour account usage from Anthropic OAuth API (cached 30s)
usage_info=""
CACHE_FILE="/tmp/claude-usage-cache.json"
if [[ "$OSTYPE" == darwin* ]]; then
    AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
else
    AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
fi

API=""
[ -f "$CACHE_FILE" ] && [ "$AGE" -lt 30 ] && API=$(cat "$CACHE_FILE")

if [ -z "$API" ]; then
    if [[ "$OSTYPE" == darwin* ]]; then
        CREDS=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    elif [ -f "$HOME/.claude/.credentials.json" ]; then
        CREDS=$(cat "$HOME/.claude/.credentials.json")
    fi
    TOKEN=$(echo "$CREDS" | sed -n 's/.*"claudeAiOauth"[^}]*"accessToken"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    if [ -n "$TOKEN" ]; then
        API=$(curl -s --max-time 3 "https://api.anthropic.com/api/oauth/usage" \
            -H "Authorization: Bearer $TOKEN" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "User-Agent: claude-code/2.0.76")
        echo "$API" > "$CACHE_FILE" 2>/dev/null
    fi
fi

if [ -n "$API" ]; then
    ACCT_PCT=$(echo "$API" | sed -n 's/.*"five_hour"[^}]*"utilization"[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -1)
    ACCT_PCT=${ACCT_PCT%.*}
    ACCT_PCT=${ACCT_PCT:-0}
    RESET_AT=$(echo "$API" | sed -n 's/.*"five_hour"[^}]*"resets_at"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

    TIME_STR=""
    if [ -n "$RESET_AT" ]; then
        if [[ "$OSTYPE" == darwin* ]]; then
            RESET_EPOCH=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "${RESET_AT:0:19}" +%s 2>/dev/null || echo 0)
        else
            RESET_EPOCH=$(date -u -d "${RESET_AT:0:19}" +%s 2>/dev/null || echo 0)
        fi
        SECS=$((RESET_EPOCH - $(date +%s)))
        [ "$SECS" -lt 0 ] && SECS=0
        TIME_STR="$((SECS / 3600))h$(((SECS % 3600) / 60))m"
    fi

    # Color the 5H usage percentage
    if [ "$ACCT_PCT" -lt 50 ]; then
        usage_color="$GREEN"
    elif [ "$ACCT_PCT" -lt 70 ]; then
        usage_color="$YELLOW"
    else
        usage_color="$RED"
    fi

    # Color the reset timer
    if [ -n "$TIME_STR" ]; then
        if [ "$SECS" -lt 3600 ]; then
            time_color="$GREEN"
        elif [ "$SECS" -lt 12600 ]; then
            time_color="$YELLOW"
        else
            time_color="$RED"
        fi
        usage_info=$(printf "${DIM}5H${RESET} ${usage_color}%d%%${RESET} ${time_color}%s${RESET}" "$ACCT_PCT" "$TIME_STR")
    else
        usage_info=$(printf "${DIM}5H${RESET} ${usage_color}%d%%${RESET}" "$ACCT_PCT")
    fi
fi

# Build status line: path (branch ✓) • model • context% • 5H usage
printf "${GREEN}%s${RESET}" "$rel_path"
[ -n "$git_info" ] && printf " (%b)" "$git_info"
[ -n "$model" ] && [ "$model" != "null" ] && printf " ${DIM}•${RESET} ${CYAN}%s${RESET}" "$model"
[ -n "$context_info" ] && printf " ${DIM}•${RESET} %b" "$context_info"
[ -n "$usage_info" ] && printf " ${DIM}•${RESET} %b" "$usage_info"

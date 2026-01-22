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

# Build status line: path (branch ✓) • model • context%
printf "${GREEN}%s${RESET}" "$rel_path"
[ -n "$git_info" ] && printf " (%b)" "$git_info"
[ -n "$model" ] && [ "$model" != "null" ] && printf " ${DIM}•${RESET} ${CYAN}%s${RESET}" "$model"
[ -n "$context_info" ] && printf " ${DIM}•${RESET} %b" "$context_info"

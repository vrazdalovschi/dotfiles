#!/usr/bin/env bash

# Claude Code notification hook - sends macOS notification when tasks complete
input=$(cat)

message=$(echo "$input" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
title="Claude Code"

# Terminal bell (triggers VSCode visual bell icon)
printf '\a'

# macOS notification with sound
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e "display notification \"${message}\" with title \"${title}\" sound name \"Glass\""
elif command -v notify-send &> /dev/null; then
  notify-send "${title}" "${message}" -u normal -i terminal
fi

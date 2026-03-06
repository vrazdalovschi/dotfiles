#!/usr/bin/env bash
# PreToolUse hook: rewrites shell commands via RTK for token savings.
# Requires: jq, rtk >= 0.23.0
# Silently passes through if either dependency is missing.

if ! command -v jq &>/dev/null; then exit 0; fi
if ! command -v rtk &>/dev/null; then exit 0; fi

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

REWRITTEN=$(rtk rewrite "$CMD" 2>/dev/null) || exit 0
[ "$REWRITTEN" = "$CMD" ] && exit 0

UPDATED_INPUT=$(echo "$INPUT" | jq --arg cmd "$REWRITTEN" '.tool_input.command = $cmd')

jq -n --argjson updated "$UPDATED_INPUT" '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "RTK auto-rewrite",
    "updatedInput": $updated.tool_input
  }
}'

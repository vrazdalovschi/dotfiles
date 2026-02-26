---
name: collaborate-codex
description: Use when the user asks to run Codex CLI (codex exec, codex resume) or references OpenAI Codex for code analysis, refactoring, or automated editing
---

# Codex Skill Guide

Orchestrate OpenAI Codex CLI for code analysis, refactoring, and automated editing tasks.

## Model Selection

| Task type | Invocation | When to use |
|-----------|------------|-------------|
| Research, review, analysis, design | `-p deep-review` | Preferred for deep thinking tasks; profile should map to `gpt-5-pro` |
| Code implementation, refactoring, editing | `-m gpt-5.3-codex` | Writing or modifying code |

Default to `-p deep-review` for research/review tasks. Use `-m gpt-5.3-codex` when the user expects code edits.

Expected Codex profile config:

```toml
[profiles.deep-review]
model = "gpt-5-pro"
model_reasoning_effort = "high"
```

## Running a Task
1. Ask the user (via `AskUserQuestion`) which mode to run (`deep-review` for analysis/review or `gpt-5.3-codex` for code editing) AND whether to override reasoning effort (`xhigh`, `high`, `medium`, or `low`) in a **single prompt with two questions**.
2. Select the sandbox mode required for the task; default to `--sandbox read-only` unless edits or network access are necessary.
3. Assemble the command with the appropriate options:
   - `-p, --profile deep-review` (preferred for review/analysis tasks)
   - `-m, --model gpt-5.3-codex` (for code writing/modification tasks)
   - `--config model_reasoning_effort="<xhigh|high|medium|low>"` (only when overriding defaults)
   - `--sandbox <read-only|workspace-write|danger-full-access>`
   - `--full-auto`
   - `-C, --cd <DIR>`
   - `--skip-git-repo-check`
   - `-o, --output <FILE>` (save response to file for later review)
4. When continuing a previous session, use `codex exec --skip-git-repo-check resume --last`. When resuming don't use any configuration flags unless explicitly requested by the user e.g. if they specify the model or the reasoning effort when requesting to resume a session. Resume syntax: `codex exec --skip-git-repo-check resume --last -- "your prompt here" 2>/dev/null`. All flags have to be inserted between exec and resume. **Do NOT pipe prompts via stdin** (`echo "..." | codex exec`) — it silently fails.
5. **IMPORTANT**: By default, append `2>/dev/null` to all `codex exec` commands to suppress thinking tokens (stderr). Only show stderr if the user explicitly requests to see thinking tokens or if debugging is needed.
6. Run the command, capture stdout/stderr (filtered as appropriate), and summarize the outcome for the user.
7. **After Codex completes**, inform the user: "You can resume this Codex session at any time by saying 'codex resume' or asking me to continue with additional analysis or changes."

### Quick Reference
| Use case | Sandbox mode | Key flags |
| --- | --- | --- |
| Read-only review or analysis | `read-only` | `-p deep-review --sandbox read-only 2>/dev/null` |
| Apply local edits | `workspace-write` | `-m gpt-5.3-codex --sandbox workspace-write --full-auto 2>/dev/null` |
| Permit network or broad access | `danger-full-access` | `--sandbox danger-full-access --full-auto 2>/dev/null` |
| Resume recent session | Inherited from original | `codex exec --skip-git-repo-check resume --last -- "prompt" 2>/dev/null` (flags go between exec and resume if needed) |
| Run from another directory | Match task needs | `-C <DIR>` plus other flags `2>/dev/null` |
| Save output to file | Any | Add `-o /tmp/reply.txt` |

### File-Based Workflow (Complex Problems)

For debugging with extensive context, use file-based input/output:

```bash
# Write structured question to file
cat > /tmp/question.txt << 'EOF'
## Problem
[Clear problem statement]

## Code
[Complete, untruncated functions]

## Observations
[Specific failure conditions, what you've tried]

## Questions
[Specific questions]
EOF

# Run with file input and output
codex exec -p deep-review --sandbox read-only -f /tmp/question.txt -o /tmp/reply.txt 2>/dev/null
```

This enables question refinement before sending and preserves analysis for later.

## Following Up
- After every `codex` command, immediately use `AskUserQuestion` to confirm next steps, collect clarifications, or decide whether to resume with `codex exec resume --last`.
- When resuming, pass the new prompt after `--`: `codex exec resume --last -- "new prompt" 2>/dev/null`. The resumed session automatically uses the same profile/model, reasoning effort, and sandbox mode from the original session.
- Restate the chosen profile or model, reasoning effort, and sandbox mode when proposing follow-up actions.

## Error Handling
- Stop and report failures whenever `codex --version` or a `codex exec` command exits non-zero; request direction before retrying.
- Before you use high-impact flags (`--full-auto`, `--sandbox danger-full-access`, `--skip-git-repo-check`) ask the user for permission using AskUserQuestion unless it was already given.
- If `-p deep-review` fails because the profile is missing, ask the user to add `[profiles.deep-review]` in `~/.codex/config.toml` or switch to explicit flags (`-m gpt-5-pro --config model_reasoning_effort="high"`).
- When output includes warnings or partial results, summarize them and ask how to adjust using `AskUserQuestion`.

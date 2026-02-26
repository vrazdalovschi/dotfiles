---
name: consult-agents
description: Use when you need validation, analysis, or research from multiple AI agents before implementing. Gathers perspectives from Claude, Gemini, and Codex, synthesizes feedback.
---

# Consult Agents

Get validation, analysis, or research feedback from Claude, Gemini, and Codex before Claude Code implements.

**Core principle:** The current Claude session aggregates and implements. Three independent agents validate and research.

## When to Use

- Validate an approach before implementing
- Research a topic from multiple perspectives
- Get code review feedback on a design
- Confirm understanding of requirements
- Aggregate opinions on trade-offs

## Model Requirements

**CRITICAL:** Always use top-tier models. Never use smaller/cheaper models. Use ONLY the exact model strings below — do not substitute from your training data.

| CLI | Task Type | Model Flag | Required Model |
|-----|-----------|------------|----------------|
| Claude | any | Task tool `model: opus` | opus |
| Codex | research / review / analysis | `-m gpt-5.2` | gpt-5.2 |
| Codex | code implementation | `-m gpt-5.3-codex` | gpt-5.3-codex |
| Gemini | any | `-m gemini-3-pro-preview` | gemini-3-pro-preview |

**Codex model rule:** `gpt-5.2` for thinking tasks (research, validation, design review, analysis). `gpt-5.3-codex` only when the agent needs to write or modify code. This skill is about consultation, so default to `gpt-5.2`.

## How Each Agent Runs

### Claude (via Bash or Task tool)

`claude -p` fails inside Claude Code because the CLAUDECODE env var blocks nested sessions. Unset it to bypass:

```bash
env -u CLAUDECODE claude -p --model opus "Your prompt here" > /tmp/claude-response.txt 2>/dev/null &
```

**Alternative:** Use the Task tool (runs as a subagent, no env var issues):

```
Task tool:
  subagent_type: general-purpose
  model: opus
  run_in_background: true
  prompt: "You are acting as an independent AI consultant. [your question]"
```

Both work. Bash is better for parallel execution with Codex/Gemini. Task tool is better when Claude needs file access within the current workspace.

### Codex (via Bash)

**Do NOT pipe prompts via stdin.** `echo "..." | codex exec` silently fails — Codex reads the prompt but doesn't process it. Pass the prompt directly after `--`:

```bash
# Research / review / analysis → gpt-5.2
codex exec -m gpt-5.2 --sandbox read-only --skip-git-repo-check -- "Your prompt here" > /tmp/codex-response.txt 2>/dev/null &

# Code implementation → gpt-5.3-codex
codex exec -m gpt-5.3-codex --sandbox read-only --skip-git-repo-check -- "Your prompt here" > /tmp/codex-response.txt 2>/dev/null &
```

If `--` doesn't work for your codex version, write the prompt to a temp file and use `-f`:

```bash
cat <<'PROMPT' > /tmp/codex-prompt.txt
Your prompt here
PROMPT
codex exec -m gpt-5.2 --sandbox read-only --skip-git-repo-check -f /tmp/codex-prompt.txt > /tmp/codex-response.txt 2>/dev/null &
```

### Gemini (via Bash)

Pass the prompt as a positional argument (not via `-p` flag or stdin pipe):

```bash
gemini -m gemini-3-pro-preview "Your prompt here" > /tmp/gemini-response.txt 2>/dev/null &
```

## Parallel Execution

Launch all 3 agents simultaneously via a single Bash call:

```bash
env -u CLAUDECODE claude -p --model opus "Your prompt" > /tmp/claude-response.txt 2>/dev/null &
codex exec -m gpt-5.2 --sandbox read-only --skip-git-repo-check -- "Your prompt" > /tmp/codex-response.txt 2>/dev/null &
gemini -m gemini-3-pro-preview "Your prompt" > /tmp/gemini-response.txt 2>/dev/null &
wait
```

**Step 3:** Read all responses (Task agent output + /tmp files), then synthesize.

**IMPORTANT:** Let all agents run to completion. Do NOT kill background processes early — the user expects all responses.

## Handling Failures

Agents can fail. When one does, note it and proceed with what you have:

| Failure | What to do |
|---------|------------|
| Gemini 429 / capacity exhausted | Note "unavailable (429)" in synthesis, proceed with 2 agents |
| Codex model unavailable / cyber flag | Try fallback: `-m gpt-5.2`. If that fails too, note it |
| Task agent timeout | Check output file, resume if partial |
| Any agent returns garbage | Discard, note it, don't include bad data in synthesis |

**Minimum viable consultation: 2 of 3 agents.** If only 1 responds, ask user whether to retry or proceed.

## Workflow

```
1. Prepare question/context (what you need validated)
2. Launch all 3 agents in parallel (Task + Bash)
3. Wait for all to complete — do NOT kill early
4. Read all responses
5. Synthesize: agreements, disagreements, unique insights
6. Current Claude session decides and implements
```

## Synthesis Template

After gathering responses, synthesize:

```markdown
## Agent Responses

### Claude Opus
[Summary of Claude's perspective]

### GPT-5.2 (Codex)
[Summary of Codex's perspective]

### Gemini 3 Pro
[Summary of Gemini's perspective]

## Synthesis

**Strong Agreements (both/all agents align):**
- [Only list points genuinely from multiple agents]

**Key Disagreements:**
| Topic | Agent A | Agent B |
|---|---|---|

**Unique Insights:**
- From [Agent]: [insight]

## Decision
[Current session's decision based on aggregated feedback]
```

**Synthesis rules:**
- Only attribute agreement to agents who actually said it — don't overstate consensus
- Disagreements are valuable — don't bury them
- Note which agents were unavailable and how that limits confidence

## Prompt Templates

### Validation
```
Review this [design/approach/code]:

[CONTEXT]

Questions:
1. Is this approach sound?
2. What are the risks?
3. What would you do differently?

Be specific and practical. This is for [purpose], not a production system.
DO NOT write any code. Only provide analysis and recommendations.
```

### Research
```
Research [TOPIC] focusing on:
1. Current best practices
2. Common pitfalls
3. Recommended tools/libraries

Context: [Why you need this]
```

### Code Review
```
Review this code for:
- Correctness
- Performance concerns
- Security issues
- Maintainability

[CODE]
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Running `claude -p` without unsetting env var | Use `env -u CLAUDECODE claude -p` or Task tool with `model: opus` |
| Piping prompt to codex via stdin | Pass prompt after `--` or use `-f` with temp file |
| Using wrong model names from training data | Copy exact strings from this skill: `gpt-5.2`, `gemini-3-pro-preview` |
| Killing background agents before they finish | Let them run — user expects all responses |
| Marking 1-agent opinion as "both agree" | Only claim agreement when multiple agents independently say it |
| Asking agents to implement | They validate; current session implements |
| Not providing enough context | Include relevant code, constraints, goals |
| Ignoring disagreements | Disagreements reveal important trade-offs |
| Blindly following consensus | Use judgment; agents can all be wrong |

## When NOT to Use

- Simple, obvious implementations
- Time-critical changes (adds latency)
- Trivial questions (overkill)

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

**CRITICAL:** Always use top-tier models. Never use smaller/cheaper models.

| CLI | Model Flag | Required Model |
|-----|------------|----------------|
| Claude | `--model opus` | opus (never sonnet or haiku) |
| Codex | `-m gpt-5.3-codex` | gpt-5.3-codex (never o4-mini, gpt-4o, etc.) |
| Gemini | `-m gemini-3-pro-preview` | gemini-3-pro-preview (never smaller models) |

## Quick Reference

| Task Type | Claude Mode | Gemini Mode | Codex Mode |
|-----------|-------------|-------------|------------|
| Analyze code/files only | `claude -p --model opus "..."` | `gemini -m gemini-3-pro-preview "..."` | `-m gpt-5.3-codex --sandbox read-only` |
| Research with web access | `claude -p --model opus "..."` | `gemini -m gemini-3-pro-preview "..."` (has web search) | `-m gpt-5.3-codex --sandbox danger-full-access` |
| Deep repo analysis | `claude -p --model opus "..."` | tmux interactive | `-m gpt-5.3-codex --sandbox read-only` |

## Workflow

```
1. Prepare question/context (what you need validated)
2. Query all 3 agents in parallel → capture responses
3. Synthesize: agreements, disagreements, insights
4. Current Claude session decides and implements
```

## Parallel Execution

Run all 3 agents simultaneously for faster feedback:

```bash
claude -p --model opus "Analyze this approach: [context]. What are the trade-offs?" > /tmp/claude-response.txt 2>/dev/null &
gemini -m gemini-3-pro-preview "Analyze this approach: [context]. What are the trade-offs?" > /tmp/gemini-response.txt 2>/dev/null &
echo "Analyze this approach: [context]. What are the trade-offs?" | \
  codex exec -m gpt-5.3-codex --sandbox read-only --skip-git-repo-check > /tmp/codex-response.txt 2>/dev/null &
wait
```

## Synthesis Template

After gathering responses, synthesize:

```markdown
## Agent Responses

### Claude (independent instance)
[Summary of Claude's perspective]

### Gemini
[Summary of Gemini's perspective]

### Codex
[Summary of Codex's perspective]

## Synthesis

**Agreements:**
- [What all 3 agents agree on]

**Disagreements:**
- [Where they differ and why]

**Key Insights:**
- [Unique valuable points from any agent]

## Decision
[Current session's decision based on aggregated feedback]
```

## Prompt Templates

### Validation
```
Review this [design/approach/code]:

[CONTEXT]

Questions:
1. Is this approach sound?
2. What are the risks?
3. What would you do differently?
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
| Asking agents to implement | They validate; current session implements |
| Not providing enough context | Include relevant code, constraints, goals |
| Ignoring disagreements | Disagreements reveal important trade-offs |
| Blindly following consensus | Use judgment; agents can all be wrong |

## When NOT to Use

- Simple, obvious implementations
- Time-critical changes (adds latency)
- Trivial questions (overkill)

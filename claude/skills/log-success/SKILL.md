---
name: log-success
description: Use when something works unusually well during agentic coding - fast completion, first-try success, elegant solution, minimal intervention needed. Captures WHY things worked to build repeatable patterns.
---

# Log Success

You are helping the user log a success/win that occurred during agentic coding. Most people skip this - they only log failures. But understanding WHY things work is just as important as why they fail. Capture what went RIGHT.

## Core Philosophy

**Success patterns are as valuable as failure patterns.** When something clicks, there's usually a reason - a well-structured prompt, good context management, or effective harness configuration. Capture it before you forget.

## When to Use

Invoke `/log-success` when:
- Task accomplished unusually smoothly
- First-try success on something complex
- Minimal intervention needed
- Elegant solution emerged
- New technique or tip worked really well
- Context management was particularly effective
- Prompt structure produced excellent results

## Logs Directory

All success logs are stored in: `claude/logs/successes/`
- Format: `success-YYYY-MM-DD-NNN.md`
- Metadata tracking: `claude/logs/metadata.json`

## Your Task

1. **Review the recent conversation** to understand what went notably well
2. **Ask 4-6 clarifying questions** specific to what actually happened
3. **Trace the triggering prompt** - Get the EXACT prompt that led to success (verbatim)
4. **Identify the key ingredient** - What was the ONE thing that made the difference?
5. **Log the success** using the template below

## Interview Questions (Be Specific)

Questions should cover what actually happened:

**What specifically went well:**
- "That auth flow came together in under 20 minutes. What about the prompt setup made it work so smoothly?"
- "You didn't have to correct me once during the refactor. Was that luck or did the context in CLAUDE.md help?"
- "The solution I suggested was cleaner than what you initially had in mind. What made it click?"

**Why it worked:**
- "What context did you provide upfront that prevented the usual back-and-forth?"
- "Was there something different about how you structured this prompt?"
- "Did you use any specific technique from recent learning?"

**The setup:**
- "How much context was in the window when this happened?"
- "Did you /clear recently before this task?"
- "Were there specific CLAUDE.md instructions that helped?"

**Reproducibility:**
- "Could you do this again with the same approach?"
- "Should this become a standard practice in your workflow?"
- "Is this worth adding to CLAUDE.md?"

## Log Template

```markdown
# Success #[ID]: [Short Descriptive Name]
**Date:** [YYYY-MM-DD]
**Project/Context:** [What were you working on]

## What Went Well
[2-3 sentences - what succeeded and why it was notable]

## Success Category
**Primary factor:** [Pick ONE]

### Prompt Excellence
- [ ] **Clear constraints** - Specified both what TO do and what NOT to do
- [ ] **Right abstraction level** - Not too high-level, not too detailed
- [ ] **Success criteria defined** - Clear definition of "done"
- [ ] **Good structure** - Well-organized with XML tags or clear sections
- [ ] **Minimal but complete** - Just enough info, no noise

### Context Management
- [ ] **Fresh context** - /cleared at right time
- [ ] **Lean CLAUDE.md** - Only essential instructions loaded
- [ ] **Just-in-time context** - Provided info when needed, not upfront
- [ ] **Good handoff** - Context transferred effectively between sessions

### Harness Configuration
- [ ] **Right agent type** - Matched agent to task perfectly
- [ ] **Effective parallelization** - Independent tasks ran concurrently
- [ ] **Good validation** - Checks caught issues early
- [ ] **Subagent orchestration** - Context flowed correctly to subagents

### Technique Applied
- [ ] **New technique worked** - Tip from reading/community paid off
- [ ] **Pattern reuse** - Applied previously learned pattern effectively
- [ ] **Tool usage** - MCP or tool used at right moment

## The Triggering Prompt
```
[Exact prompt that led to success - verbatim]
```

## What Made This Prompt Work
[Analyze the specific elements that contributed to success]

## Key Ingredient
[The ONE thing that made the biggest difference]

## The Win
- **What you expected:** [Expected outcome]
- **What you got:** [Actual outcome - equal or better]
- **Time saved:** [Compared to usual approach]

## Reproducibility
- **Repeatable?** [Yes/No - can you do this again?]
- **Add to workflow?** [Should this become standard practice?]
- **Add to CLAUDE.md?** [Worth encoding as instruction?]

## One-Line Lesson
[Actionable insight to remember and apply again]

---
*Logged on [timestamp]*
```

## Important

- Be specific about what worked - vague success logs are useless
- Focus on what the USER did right, not just that Claude performed well
- The goal is to build repeatable patterns
- Capture the exact prompt - you'll want to reference it later
- This is especially valuable when trying new techniques from online resources

## Workflow

1. Something works unusually well
2. User invokes `/log-success`
3. Claude asks clarifying questions about what happened
4. Capture the exact successful prompt verbatim
5. Identify the key ingredient that made it work
6. Log to `claude/logs/successes/` directory
7. Consider adding successful pattern to CLAUDE.md if broadly applicable

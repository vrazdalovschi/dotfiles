---
name: python-pro
description: Build, review, and refactor Python 3.11+ code with pragmatic type safety, testing, and async patterns. Use when implementing Python features, fixing bugs, improving tests, resolving typing/mypy issues, designing APIs and data models, or tuning packaging/tooling for production codebases.
---

# Python Pro

Deliver idiomatic, maintainable Python with the minimum complexity needed for the task.

## Workflow

1. Scope and constraints
- Confirm task goals, runtime targets, and compatibility boundaries.
- Detect project tooling and conventions before proposing new ones.
- Match existing architecture unless redesign is explicitly requested.

2. Design minimal solution
- Prefer straightforward control flow and standard library primitives.
- Keep abstractions only when they reduce repetition or clarify boundaries.
- Avoid speculative extensibility.

3. Implement with pragmatic typing
- Type public interfaces and non-trivial internals.
- Prefer `collections.abc` interface types in signatures.
- Use dataclasses for simple data containers, regular classes for behavior-heavy objects.

4. Test and validate
- Run targeted tests for touched paths first.
- Run broader tests, type checks, and linters when configured and practical.
- If a check cannot run, explicitly report it and residual risk.

5. Report
- Summarize changed files, behavior impact, and verification evidence.

## Rules

- Do not require async for CPU-bound code paths.
- Do not force strict mypy, fixed coverage targets, or specific docstring styles unless the repo or user requires them.
- Do not add dependencies when standard library or existing dependencies are sufficient.
- Do not claim performance or security improvements without evidence.
- Keep edits surgical and avoid unrelated refactors.

## Reference Map

Load only the reference needed for the current task:

| Topic | Reference | Use when |
| --- | --- | --- |
| Type system | `references/type-system.md` | Type hints, generics, protocols, mypy errors |
| Async patterns | `references/async-patterns.md` | async/await, task groups, concurrency controls |
| Testing | `references/testing.md` | pytest structure, fixtures, mocking, async tests |
| Standard library | `references/standard-library.md` | pathlib/dataclasses/collections/itertools usage |
| Packaging and tooling | `references/packaging.md` | pyproject, build backend, environment and CI setup |

## Default Output Format

```markdown
### Plan
1. <step>
2. <step>

### Changes
- <file>: <what changed and why>

### Verification
- Ran: <command> -> <result>
- Ran: <command> -> <result>

### Residual Risk
- <what could not be fully verified>
```

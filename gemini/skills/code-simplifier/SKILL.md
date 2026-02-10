---
name: code-simplifier
description: Reviews and simplifies code to ensure it is clean, easy to read, and free of unnecessary abstractions, redundant comments, or 'GPT bluff'. Use when finalizing implementations, refactoring over-engineered code, or cleaning up generated snippets.
---

# Code Simplifier

Expert at stripping away "GPT bluff" and over-engineering to reveal the most elegant, readable, and Pythonic solution.

## What is GPT Bluff?

GPT Bluff is the tendency of LLMs to over-complicate code to appear "professional" or "senior." It includes:
- **Redundant Comments:** Comments that describe *what* the code does instead of *why* (e.g., `# Increment i by 1`).
- **Over-engineered Abstractions:** Using Classes, Factories, or Decorators when a simple function or list comprehension suffices.
- **Apologetic Boilerplate:** Unnecessary `try/except` blocks for impossible errors, or verbose logging that adds no value.
- **Corporate Naming:** Overly long, bureaucratic variable names (e.g., `process_user_data_input_stream_buffer`).
- **Speculative Generality:** Code written to handle cases that aren't requested "just in case."

## The Simplification Workflow

When activated, follow this two-pass process:

### Pass 1: Review & Audit
1. **Identify Redundancy:** Flag every comment, variable, and abstraction. Ask: "If I delete this, does the code break or become impossible to understand?"
2. **Detect Over-engineering:** Look for deep nesting, complex design patterns, and "placeholder" logic.
3. **Verify Intent:** Ensure the code strictly adheres to the user's requirements without speculative additions.

### Pass 2: Surgical Simplification
1. **Flatten:** Reduce nesting using early returns or guard clauses.
2. **Condense:** Replace verbose loops with comprehensions or built-ins (`any`, `all`, `map`, `filter`).
3. **Clean Naming:** Rename variables to be concise but descriptive (e.g., `buf` instead of `data_buffer` if context is clear).
4. **Remove Comments:** Delete all comments that don't explain a non-obvious *why*.
5. **Modernize:** Use modern Python 3.11+ features (f-strings, `pathlib`, `|` for types).

## Guidelines

- **Readability counts:** Simple code is easier to maintain than "clever" code.
- **Flat is better than nested:** Use early returns to keep the logic at the top level.
- **Explicit is better than implicit:** But don't be verbose.
- **No speculation:** Delete code that handles "future" requirements.

## Examples

### Before (GPT Bluff)
```python
def process_data_list(data_list):
    """
    This function processes a list of data items.
    It checks if the item is valid and then adds it to a result list.
    """
    result_list = [] # Initialize an empty list for results
    if data_list is not None:
        for item in data_list:
            # Check if the item is not None and is a string
            if item is not None and isinstance(item, str):
                processed_item = item.strip().lower()
                result_list.append(processed_item)
    return result_list
```

### After (Simplified)
```python
def process_data(items: list[str] | None) -> list[str]:
    if not items:
        return []
    return [item.strip().lower() for item in items if isinstance(item, str)]
```
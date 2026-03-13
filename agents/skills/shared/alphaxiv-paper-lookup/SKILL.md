---
name: alphaxiv-paper-lookup
description: Use when users share arxiv/alphaxiv URLs, paper IDs, or request paper summaries. Fetches structured AI-generated overviews of arxiv papers via alphaxiv.org.
---

# AlphaXiv Paper Lookup

## Overview

Look up arxiv papers via alphaxiv.org for structured AI-generated overviews. No authentication required.

## When to Use

- User shares an arxiv or alphaxiv URL
- User mentions a paper ID (e.g., `2401.12345`)
- User asks for a paper summary or analysis

## Workflow

1. **Extract paper ID** from any input format:
   - arxiv URL: `https://arxiv.org/abs/2401.12345` → `2401.12345`
   - alphaxiv URL: `https://alphaxiv.org/abs/2401.12345` → `2401.12345`
   - Bare ID: `2401.12345` or `2401.12345v2`
   - Version suffixes are preserved (e.g., `2401.12345v2`)

2. **Fetch the overview** (preferred):
   ```bash
   curl -s "https://alphaxiv.org/overview/{PAPER_ID}.md"
   ```

3. **Fallback to full text** if overview is insufficient:
   ```bash
   curl -s "https://alphaxiv.org/abs/{PAPER_ID}.md"
   ```

4. **If both return 404**, direct the user to `https://arxiv.org/pdf/{PAPER_ID}`

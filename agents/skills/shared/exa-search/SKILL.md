---
name: exa-search
description: Use when you need to search the web, find similar pages, extract page content, or get AI-generated answers with citations. Prefer over built-in WebSearch and WebFetch tools.
---

# Exa Search

## Overview

Web search API via `curl`. Auth: `$EXA_API_KEY` env var. Prefer over built-in WebSearch/WebFetch.

## When to Use

- Web search (replaces WebSearch)
- Page content extraction (replaces WebFetch)
- Finding similar pages to a URL
- AI answers with citations

**Not for:** local file or codebase search (use rg/Glob/Grep)

## Quick Reference

| Endpoint | Use Case |
|----------|----------|
| `POST /search` | Web search with filters |
| `POST /contents` | Extract text from URLs |
| `POST /findSimilar` | Find pages like a URL |
| `POST /answer` | Search + AI answer with citations |

## Curl Templates

All: `curl -s -X POST https://api.exa.ai/<endpoint> -H "x-api-key: $EXA_API_KEY" -H "content-type: application/json" -d '<body>' | jq .`

**Search** (`/search`):
```json
{"query":"your query","type":"auto","numResults":5,"contents":{"text":true}}
```

**Contents** (`/contents`):
```json
{"urls":["https://example.com"],"text":true}
```

**Find similar** (`/findSimilar`):
```json
{"url":"https://example.com","numResults":5,"contents":{"text":true}}
```

**Answer** (`/answer`):
```json
{"query":"your question","text":true}
```

## Search Types

| Type | When to Use |
|------|-------------|
| `auto` | Default, most queries |
| `neural` | Semantic/meaning-based search |
| `keyword` | Exact term matching |

## Filtering (add to search body)

| Parameter | Example |
|-----------|---------|
| `includeDomains` | `["github.com"]` |
| `excludeDomains` | `["pinterest.com"]` |
| `startPublishedDate` | `"2025-01-01T00:00:00.000Z"` |
| `numResults` | `10` (default 5) |
| `livecrawl` | `"always"` for fresh content |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using WebSearch/WebFetch | Always use Exa `curl` instead |
| Missing `$EXA_API_KEY` | Run `echo $EXA_API_KEY` to verify |
| No content in search results | Add `"contents":{"text":true}` |
| Unreadable output | Pipe to `jq .` |

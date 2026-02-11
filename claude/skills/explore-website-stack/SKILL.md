---
name: explore-website-stack
description: Use when the user wants competitive research on a website's technology or asks to explore what a site runs on. Triggered by phrases like "explore website", "what stack does this site use", "what tech is this site running", or "research this company's ecommerce setup".
---

# Explore Website Stack

## Overview

Identify a website's technology stack by navigating key pages and running JavaScript detection checks. Also research public business intelligence (revenue, traffic, catalog size, leadership changes). Produces a structured markdown report with concrete evidence and source URLs for every finding.

**This report is used by the sales team.** Every claim must be backed by verifiable proof — an intercepted network request, a specific JS global, a DOM element, or a source URL. Unverified statements are not acceptable. If something cannot be confirmed, state "Not confirmed" rather than guessing.

## When to Use

- User asks what platform/tech a website runs on
- Competitive research on e-commerce or content sites
- Identifying search providers, recommendation engines, A/B testing tools
- Auditing third-party integrations on a live site

## Tool

Use **Playwriter** (`mcp__playwriter__execute`) or **agent-browser** (CLI via Bash) for browser interactions. Both support JS execution, network interception, and page navigation.

- **Playwriter**: MCP server, inline JS, `state` persistence, response headers via `fetch()`. Requires Chrome extension enabled.
- **agent-browser**: CLI via Bash, `--json` output, daemon persistence, cloud provider fallback. Requires `npm install -g agent-browser`.

Use whichever is available. If both are available, prefer Playwriter for its MCP integration.

## Workflow

### Phase 1: Homepage Detection

1. Create a new page and navigate to the target URL
2. Wait for full load (`waitForPageLoad`)
3. Run platform detection JS from `detection-reference.md`
4. Collect initial analytics/CDN signals

### Phase 2: Network Interception Setup

1. Set up request/response listeners on the page **before any navigation**
2. Store captured XHR/fetch requests in `state.requests` and search API response bodies in `state.searchApiResponses` (needed for Phase 3.5 catalog estimation)
3. This must be active throughout Phases 3-5 to capture real API calls

### Phase 3: Search — Actually Perform a Search

**Do not just navigate to `/search?q=...`.** You must use the site's search UI:

1. Find the search input in the navigation bar (use accessibility snapshot or DOM query)
2. Click on it, type a generic term (e.g., "blue" or "shirt"), and submit
3. **While typing**: check intercepted requests for autocomplete/suggest API calls (these reveal the search provider)
4. **After results load**: check intercepted requests for the search query API call
5. Match intercepted request domains against known provider patterns from `detection-reference.md`
6. Also check search-specific globals on the search results page

**What counts as proof for search provider:**
- Intercepted XHR/fetch request to a provider domain (e.g., `*.algolianet.com`, `core.dxpapi.com`) containing the search query — this is the strongest proof
- Autocomplete requests to a provider domain during typing
- Globals alone (e.g., `window.BrTrk`) prove the script is loaded, NOT that it handles search. Always pair with network evidence.

### Phase 3.5: Catalog Size Estimation

Run immediately after Phase 3 while search results are loaded and `state.searchApiResponses` has data.

1. Check `state.searchApiResponses` — if any responses were captured, try **Strategy 1** (search API replay) from `detection-reference.md`
2. Replay the captured API URL with `q=*` and `rows=0` (strips filters) to get the total indexed product count
3. If wildcard fails, retry with `q=a` as a broad fallback
4. If no search API was captured, try **Strategy 2** (extract "X of Y items" text from the loaded search results page)
5. Store result in `state.catalogEstimate = { count, method, field, url }`

This costs at most 1-2 extra API calls and gives a concrete catalog count for the report. Strategies 3 (sitemap) and 4 (visible count) are fallbacks — try them during Phase 6 if Strategies 1-2 yielded nothing.

### Phase 4: Category / Browse Page — Navigate, Filter, Sort, Paginate

1. Find a category link in the site navigation and **click it** (don't hardcode a URL)
2. Wait for the PLP (product listing page) to load
3. **Sort**: change the sort order (e.g., "Price Low to High") and check what requests fire
4. **Filter**: apply a filter (e.g., size, color) and check what requests fire
5. **Paginate**: scroll to load more products or click "Next Page" and check requests
6. Each of these actions may reveal the browse/merchandising provider — match request domains against known patterns
7. Check if filtering/sorting causes full page reloads (server-side) or XHR calls (client-side / third-party)

**What counts as proof for browse/merchandising:**
- XHR/fetch to a provider domain triggered by sort/filter/paginate actions
- URL parameters changing to include provider-specific query syntax

### Phase 5: Product Detail Page (PDP) — Click Into a Product

1. From the PLP or search results, **click on an actual product** (don't hardcode a PDP URL)
2. Wait for the PDP to fully load
3. **Recommendations**: scroll down to find "You may also like" / "Customers also viewed" carousels. Check:
   - What network requests fired when the carousel loaded
   - Data attributes on carousel containers (e.g., `data-br-widget`, `nosto_element`)
   - Script sources specific to recommendation providers
4. **Reviews**: look for review widgets below the product. Check for provider DOM elements and script loads
5. **Social proof**: check for "X people viewing this" or similar widgets
6. **Payment options**: check for BNPL badges (Afterpay, Klarna, Affirm) and payment provider scripts
7. Run tracking/pixel detection JS from `detection-reference.md`

### Phase 6: Business Intelligence Research

Use `WebSearch` to gather public business data. **Every statement must include a source URL.** If a search returns no credible results, state "No public data found" — never fabricate.

Research these topics in parallel where possible:
1. **Revenue / Sales volume** — search for annual revenue, earnings reports, funding rounds
2. **Traffic / Sessions** — search SimilarWeb, press mentions of traffic figures
3. **Catalog size** — use `state.catalogEstimate` from Phase 3.5 as the primary source. If Phase 3.5 yielded nothing, try sitemap count (Strategy 3) or web search for press mentions as cross-reference
4. **Recent leadership changes** — search for CEO/CTO/CXO changes in last 2 years
5. **Major e-commerce shifts** — replatforming, acquisitions, market expansion in last 2 years

### Phase 7: Multi-Agent Research (Optional)

Dispatch Gemini and/or Codex via `collaborate-gemini` / `collaborate-codex` skills. Use the `consult-agents` skill pattern.

**Critical: agents must provide proof for every claim.** This report goes to the sales team — unverified statements destroy credibility.

Give each agent this exact prompt structure:

```
Research {domain} and answer:
1. What e-commerce platform does this site run on? Provide the URL or source that confirms this.
2. What is their estimated annual revenue? Provide the source URL.
3. Any major leadership changes (CEO, CTO, CXO) in the last 2 years? Provide the source URL.
4. Any recent replatforming, acquisitions, or market expansion? Provide the source URL.

RULES:
- Every single claim MUST include a source URL as proof.
- If you cannot find a credible source for a claim, write "No public data found" instead.
- Do NOT state anything without a verifiable reference.
- Do NOT guess, infer, or fill in gaps from general knowledge.
- If blocked or unable to access a source, say so explicitly.
```

**When merging agent findings into the report:**
- Discard any claim from Gemini/Codex that lacks a source URL — no exceptions
- If an agent's finding contradicts browser-detected evidence, browser evidence wins
- If an agent surfaces a credible sourced finding that Claude missed, include it with attribution (e.g., "Source: Gemini research — [URL]")
- Never merge hallucinated or unsourced data into the report

### Phase 8: Compile Report

Print the final markdown report directly in chat. The report must be **presentation-ready** — formatted for sharing in Slack, email, or marketing decks without editing. Use clear visual hierarchy, consistent spacing, and the table-based layout below.

```markdown
# {domain} — Technology Stack Report

> Generated {date} via automated browser analysis + public research

---

## Technology Summary

| Category | Provider | Confidence |
|----------|----------|------------|
| **Platform** | {name} | {Network/DOM/Script} |
| **Search** | {name} | {Network/DOM/Script} |
| **Browse/Merch** | {name} | {Network/DOM/Script} |
| **Recommendations** | {name} | {Network/DOM/Script} |
| **A/B Testing** | {name} | {Network/DOM/Script} |
| **CDN** | {name} | {Network/DOM/Script} |
| **Reviews** | {name} | {Network/DOM/Script} |
| **Chat** | {name} | {Network/DOM/Script} |
| **Payments** | {names} | {Network/DOM/Script} |
| **Email/SMS** | {name} | {Network/DOM/Script} |
| **Loyalty** | {name} | {Network/DOM/Script} |

## Business Intelligence

> Every item below MUST include a source URL. If no credible source found, write "No public data found."

| Metric | Value | Source |
|--------|-------|--------|
| **Revenue** | {figure} | [source]({url}) |
| **Traffic** | {figure} | [source]({url}) |
| **Catalog Size** | {count} | {method}: `{field}` via `{api url or page}` |
| **Parent Company** | {name} | {relationship} |

### Recent Changes (last 2 years)

| Date | Change | Source |
|------|--------|--------|
| {date} | {leadership change: name, role} | [source]({url}) |
| {date} | {e-commerce shift: replatforming, acquisition, expansion} | [source]({url}) |

## Useful Links

| Resource | URL |
|----------|-----|
| Website | {domain} |
| Search API | `{intercepted search API domain}` |
| Sitemap | {sitemap URL if found} |
| {SimilarWeb / Crunchbase / LinkedIn / etc.} | {url} |

---

## Evidence Details

> Technical proof for each detection above. Ordered by evidence strength: Network > DOM > Script/Global.

### Platform

| | |
|---|---|
| **Platform** | {platform name and tier if detectable} |
| **Evidence** | {globals found, asset URLs, meta tags} |

### Search

| | |
|---|---|
| **Provider** | {provider name or "Native/Unknown"} |
| **How confirmed** | {describe the action taken: typed in search bar, submitted query} |
| **Network proof** | `{intercepted XHR/fetch URL with query param}` |
| **Supporting** | {globals, script sources — secondary to network proof} |

### Browse / Merchandising

| | |
|---|---|
| **Provider** | {provider name or "Native/Platform default"} |
| **How confirmed** | {describe actions: sorted by price, filtered by size, paginated} |
| **Network proof** | `{intercepted requests during sort/filter/paginate}` |

### Recommendations / Carousels

| | |
|---|---|
| **Provider** | {provider name or "Native/Unknown"} |
| **How confirmed** | {scrolled to carousel on PDP, observed network requests} |
| **Network proof** | `{intercepted requests when carousel rendered}` |
| **Supporting** | {data attributes, script sources, DOM containers} |

### A/B Testing

| | |
|---|---|
| **Provider** | {provider name or "None detected"} |
| **Evidence** | {globals, script tags, cookies} |

### Analytics & Tracking

| Provider | Evidence |
|----------|----------|
| {provider 1} | {evidence} |
| {provider 2} | {evidence} |

### CDN / Infrastructure

| | |
|---|---|
| **CDN** | {provider name} |
| **Evidence** | {response headers, asset domains} |

### Other Integrations

| Category | Provider | Evidence |
|----------|----------|----------|
| Reviews | {provider} | {proof} |
| Chat | {provider} | {proof} |
| Payments | {providers} | {proof} |
| Email/SMS | {provider} | {proof} |
| Loyalty | {provider} | {proof} |
| UGC | {provider} | {proof} |
| Affiliate | {provider} | {proof} |

### Catalog Size Evidence

| | |
|---|---|
| **Count** | {state.catalogEstimate.count} |
| **Method** | {state.catalogEstimate.method} |
| **Field** | `{state.catalogEstimate.field or matchedText}` |
| **API URL** | `{state.catalogEstimate.url}` |

---

*Report methodology: automated browser navigation with JS detection, network interception during search/browse/PDP interactions, and public web research. Confidence levels: Network (intercepted API call) > DOM (HTML elements) > Script (JS global loaded).*
```

## Evidence Hierarchy

Not all evidence is equal. The report must classify each finding by strength:

1. **Network proof (strongest):** Intercepted XHR/fetch request to a provider's API domain during a real user action (search, filter, paginate, load carousel). Example: `GET core.dxpapi.com/api/v1/core/?q=blue` proves Bloomreach handles search.
2. **Behavioral proof:** Observed outcome from a user action that matches provider behavior. Example: sorting on PLP triggers a request to `*.algolianet.com` with sort params.
3. **DOM proof:** Provider-specific HTML elements, data attributes, or container classes. Example: `<div data-bv-show="reviews">` proves Bazaarvoice renders reviews.
4. **Global/script proof (weakest alone):** JavaScript globals or script sources from a provider. Example: `window.BrTrk` proves Bloomreach tracking JS is loaded, but does NOT prove it handles search. **Always pair with network or DOM proof for functional claims.**

A script being loaded on a page only proves the tag is fired — not that the provider powers a specific feature. Always perform the action (search, sort, filter, view PDP) and check what network requests result.

## Self-Updating Rule

**Before compiling the final report**, check if any provider you detected is missing from `detection-reference.md`. If so, add it immediately. This is not optional — it is how the skill learns over time.

For each new provider, add a detection entry with:
- **Name and category** (e.g., "Curalate — UGC / Visual Commerce")
- **Global variable** (e.g., `window.Curalate`)
- **Script URL hostname pattern** (e.g., `edge.curalate.com`)
- **Network request domain pattern** (e.g., `*.curalate.com`)
- **DOM selector** if applicable (e.g., `[data-curalate]`)
- **Example evidence string** exactly as it appeared in your findings (e.g., `"scripts from edge.curalate.com loaded on homepage and PDP"`)

Also update existing entries if you find a stronger detection method than what's documented (e.g., you discover a new API domain a provider uses for search that isn't listed).

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Checking globals on homepage and claiming a provider handles search | Must perform actual search and intercept network requests during the action |
| Navigating to `/search?q=...` directly instead of using the search UI | Use the site's search bar — autocomplete requests during typing reveal the provider |
| Reporting `window.BrTrk` as proof of Bloomreach search | BrTrk is a tracking pixel. Need `core.dxpapi.com` requests with search query params |
| Hardcoding PDP/PLP URLs instead of clicking through the site | Click actual nav links and products to trigger natural page lifecycle and tracking |
| Including Gemini/Codex claims without source URLs | Discard any unsourced agent claim — sales team needs verifiable data |
| Saying "Shopify" without evidence beyond a script load | `window.Shopify` is definitive. But `cdn.shopify.com` on a third-party site is not — it could be Shopify Buy Button only |
| Not setting up network interception before navigating | Must set up listeners in Phase 2 before Phases 3-5 or you miss the requests |
| Running catalog estimation before setting up response interception | The `page.on('response')` listener must be active in Phase 2 before Phase 3 search triggers API calls — otherwise `state.searchApiResponses` is empty |
| Using wildcard query without removing filters | Replaying with `q=*` but keeping `fq`, `filter`, or `facetFilters` params gives a narrowed count — always strip filter params before replay |

## Important Notes

- Run each detection phase in a **separate** tool call to keep code short and debuggable
- Always check `detection-reference.md` for the specific JS snippets per category
- Report only what you find evidence for. If a category has no detections, say "None detected"
- Include raw evidence (variable names, URLs, header values) so the user can verify
- **Proofs are mandatory.** Every business intelligence claim must have a source URL. If a search fails or returns nothing credible, state "No public data found" — never guess or hallucinate
- If the site blocks automation (bot detection, CAPTCHA, WAF), report what was blocked and skip that phase — do not fabricate results
- **Never skip user actions.** Do not just check globals on the homepage. You must actually search, browse a category, sort, filter, paginate, and visit a PDP. Each action may reveal a different provider.
- When dispatching Gemini/Codex agents, give them the domain name and ask for specific research (e.g., "What platform does example.com run on? What is their estimated annual revenue?"). Merge their findings with browser-detected evidence in the final report, noting the source of each finding

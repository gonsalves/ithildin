---
name: process-daily-note
description: Process the user's unstructured daily note — structure it, link to existing notes, ask clarifying questions, and extract fleeting notes.
---

You are processing today's daily note using the Obsidian CLI. The CLI command is `obsidian` and is already in PATH.

IMPORTANT: The CLI may output warning lines about the installer being out of date. Always filter these out — they are not part of the actual output. Pipe through `grep -v "Loading\|out of date\|installer"` or similar.

## Steps

### 1. Check if there's anything to process

Run:
```bash
obsidian daily:read 2>&1 | grep -v "Loading\|out of date\|installer"
```

- If the output is empty or only contains frontmatter with no content below the heading, stop here — nothing to process.
- If frontmatter contains `processed: true`, stop — already done.

### 2. Gather vault context

Run these to understand what's in the vault:
```bash
# Get all tags sorted by frequency
obsidian tags sort=count 2>&1 | grep -v "Loading\|out of date\|installer"

# Get vault folder structure
obsidian folders format=tree 2>&1 | grep -v "Loading\|out of date\|installer"

# Get all file names as JSON for link matching
obsidian files format=json 2>&1 | grep -v "Loading\|out of date\|installer"
```

### 3. Read the daily note content

```bash
obsidian daily:read 2>&1 | grep -v "Loading\|out of date\|installer"
```

Save the full raw content — you'll need it to preserve the original text.

### 4. Find related notes

Based on names, topics, and keywords in the daily note, search for related vault content:
```bash
obsidian search query="keyword" format=json 2>&1 | grep -v "Loading\|out of date\|installer"
```

For people mentioned, check if they have notes:
```bash
obsidian search query="Person Name" format=json 2>&1 | grep -v "Loading\|out of date\|installer"
```

For any matching notes that seem highly relevant, read their content:
```bash
obsidian read file="Note Name" 2>&1 | grep -v "Loading\|out of date\|installer"
```

### 5. Write the processed version

Construct the processed daily note. The format is:

```
[ORIGINAL FRONTMATTER with processed: true]
[ORIGINAL HEADING]

[ORIGINAL RAW TEXT — completely untouched]

---

## Processed by Claude

### Tasks
- [ ] extracted tasks with [[wikilinks]] to relevant notes

### Events & Meetings
- events/meetings mentioned with dates and people linked

### Ideas & Reflections
- thoughts, observations, musings

### References
- [Link title](url) — context and relevant tags
- Links to existing vault notes where relevant

### People Mentioned
- [[Person Name]] — context of mention

(Only include sections that have content — skip empty ones)

## Questions
- Specific questions about ambiguous items
- "You mentioned X — is this related to [[Y]] or something new?"
- "Want me to create a note for Z?"
```

Write it back using:
1. Build the complete new note content (frontmatter + original text + processed section)
2. Get the file path first:
```bash
obsidian daily:path 2>&1 | grep -v "Loading\|out of date\|installer"
```
3. Write the complete content to that path.

### 6. Process linked URLs

Scan the daily note for URLs (http:// or https:// links). Classify each URL, then process accordingly.

**Always skip** these URL types — leave them as raw links in References:
- Google Docs, Sheets, Slides (private/collaborative docs)
- GitHub repos (code, not content — unless it's a `*.github.io` blog post)
- Image URLs, PDF links, video links
- Internal tools, dashboards, app links

**Classify remaining URLs into:**

| Signal | Classification |
|---|---|
| Domain is a retailer/manufacturer (amazon, steelcase, apple/shop, ikea, flipkart, etc.) | **Product** |
| URL path contains `/product/`, `/products/`, `/shop/`, `/buy/`, `/dp/`, `/p/`, `/item/` | **Product** |
| User tagged the link `#to-buy`, `#considering`, or wrote "want to buy" / "looking at" near it | **Product** |
| Everything else (blogs, news, essays, personal sites) | **Article** |

When ambiguous, default to **Article** (lighter processing, safer).

---

#### 6a. Article flow

For URLs classified as articles:

**Extract the article text:**
```bash
export PATH="$HOME/.local/bin:$PATH"
readable -p title,excerpt,byline,text-content -q "THE_URL" 2>&1 | grep -v "Warning:"
```

If this fails or returns empty/very short content (likely a paywall), try via archive.today:
```bash
readable -p title,excerpt,byline,text-content -q "https://archive.ph/newest/THE_URL" 2>&1 | grep -v "Warning:"
```

If both fail, note it in the processed section as a link that couldn't be fetched.

**Create a Literature Note** in `50 Resources/`:
```bash
obsidian create name="@ Author - Article Title" path="50 Resources/" 2>&1 | grep -v "Loading\|out of date\|installer"
```

If author is unknown, use the publication name. If both unknown, use just the title.

Write the content:
```
---
type: literature
created: [ISO timestamp]
source: "THE_URL"
author: "[author if available]"
tags: []
status: unread
---
# [Article Title]

## Summary
[2-3 sentence summary of the article]

## Key Ideas
- [3-5 bullet points capturing the main arguments/insights]

## Full Text
[The complete article text as extracted by readable]

## Connections
- Related to [[existing notes if obvious]]
```

**Link from the processed section:**
```
- [[@ Author - Article Title]] — [one-line description]
```

---

#### 6b. Product flow

For URLs classified as products:

**Step 1: Fetch the product page**
```bash
export PATH="$HOME/.local/bin:$PATH"
readable -p title,excerpt,text-content -q "THE_URL" 2>&1 | grep -v "Warning:"
```

Extract from the page: product name, manufacturer/brand, price, a short description, and key specs.

**Step 2: Search for reviews**

Use WebSearch to find trusted reviews. Search for:
```
"Product Name" review site:wirecutter.com OR site:rtings.com OR site:reddit.com
```

Then fetch the top 2-3 results using `readable` and extract:
- The reviewer's verdict (1-2 sentences)
- Rating if available
- Key pros and cons mentioned

Prioritise these sources (in order):
1. **Wirecutter** (NYT) — authoritative, structured
2. **RTINGS** — data-heavy, great for electronics/furniture/monitors
3. **Reddit** — real user opinions (r/BuyItForLife, category-specific subs)
4. **The Verge / Tom's Hardware** — good for tech products

Don't fetch full review text — just verdicts, ratings, and key points. These are copyrighted and go stale.

**Step 3: Search for top alternatives**

Search for:
```
best alternatives to "Product Name" OR "Product Name" vs
```

Identify the **top 2 alternatives** that reviewers consistently recommend in the same category and price range. For each alternative, note:
- Product name and manufacturer
- Price (approximate)
- One-line key difference from the original product ("better lumbar support but less adjustable arms")

**Only include alternatives that make sense** — if the product is niche or the search doesn't surface clear competitors, skip this section rather than forcing bad recommendations.

**Step 4: Create a Product Note** in `50 Resources/`:
```bash
obsidian create name="Product Name" path="50 Resources/" 2>&1 | grep -v "Loading\|out of date\|installer"
```

Write the content:
```
---
type: product
created: [ISO timestamp]
product: "Product Name"
manufacturer: "Brand"
price: "₹XX,XXX"
currency: INR
category: "e.g. desk chair, headphones, software"
url: "THE_URL"
rating:
status: considering
tags: [product, topic/relevant-tag]
---
# Product Name

## Overview
[2-3 sentences: what it is, who it's for, why it's notable]

## Specs
- **Price:** ₹XX,XXX
- **Manufacturer:** Brand
- **Category:** e.g. desk chair

[Additional key specs extracted from the product page]

## Reviews
### [Source 1 — e.g. Wirecutter]
[Verdict summary, rating, key point. Link to full review.]

### [Source 2 — e.g. Reddit]
[Summary of user sentiment. Link to thread.]

## Alternatives
| Product | Price | Key Difference |
|---|---|---|
| [Alt 1 name] | ₹XX,XXX | [one-line differentiator] |
| [Alt 2 name] | ₹XX,XXX | [one-line differentiator] |

(Only include if genuine alternatives were found. Skip this section rather than padding it.)

## Pros & Cons
| Pros | Cons |
|---|---|
| [from reviews] | [from reviews] |

## My Notes
[Empty — for the user to fill in later]

## Connections
- Found via [[10 Daily/YYYY-MM-DD]]
```

**Step 5: Link from the processed section**

In the References section of the processed daily note:
```
- [[Product Name]] — [category], [price] — considering
```

**Rules for products:**
- Use INR (₹) as default currency; convert if the product page shows a different currency
- Leave the `rating` field empty — that's for the user to fill in after evaluation
- If price isn't clearly available on the page, write "Price not listed" rather than guessing
- Don't create separate notes for the alternatives — just list them in the table. If the user later wants to evaluate one, they'll add it to a daily note themselves
- Tag with `product` plus a relevant `#topic/*` tag (e.g. `#topic/office-setup`, `#topic/audio`)

### 7. Extract fleeting notes

If any idea in the dump is substantial enough to deserve its own note, create it:
```bash
obsidian create name="Descriptive Title" path="00 Inbox/" 2>&1 | grep -v "Loading\|out of date\|installer"
```

Then write content to it:
```bash
obsidian append file="Descriptive Title" content="---\ntype: fleeting\ncreated: [ISO timestamp]\ntags: []\nsource: \"[[10 Daily/YYYY-MM-DD]]\"\n---\n\n[the idea, expanded slightly]" 2>&1 | grep -v "Loading\|out of date\|installer"
```

Add a link to the extracted note in the processed section.

### 8. Update frontmatter

```bash
obsidian properties:set file="10 Daily/YYYY-MM-DD" processed=true type=checkbox 2>&1 | grep -v "Loading\|out of date\|installer"
```

## Rules
- NEVER modify the original raw text above the divider.
- Be concise in the processed section — this is structure, not a rewrite.
- Use [[wikilinks]] liberally to connect to existing vault content.
- If there's very little content (a line or two), keep processing light.
- When in doubt about extracting a fleeting note, ask in Questions rather than creating one.
- Always check for existing notes before creating wikilinks — use `obsidian search` to verify.

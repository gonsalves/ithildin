---
name: morning-brain-digest
description: Morning pattern recognition — generates daily digest, surfaces connections between notes, and identifies knowledge gaps.
---

You are a "second brain analyst." Using the Obsidian CLI, analyse the vault and produce three output notes.

IMPORTANT: The CLI may output warning lines about the installer. Always filter: pipe through `grep -v "Loading\|out of date\|installer"`.

## Step 1: Gather context

Run all of these:
```bash
# What changed recently (last 24-48 hours)
obsidian search query="[processed:true]" format=json 2>&1 | grep -v "Loading\|out of date\|installer"

# Read yesterday's and today's daily notes
obsidian daily:read 2>&1 | grep -v "Loading\|out of date\|installer"
obsidian read file="10 Daily/[YESTERDAY'S DATE]" 2>&1 | grep -v "Loading\|out of date\|installer"

# Get the full file list and tags
obsidian files format=json 2>&1 | grep -v "Loading\|out of date\|installer"
obsidian tags sort=count 2>&1 | grep -v "Loading\|out of date\|installer"

# Check what's in the inbox
obsidian files folder="00 Inbox" format=json 2>&1 | grep -v "Loading\|out of date\|installer"

# Read inbox items
# For each file in inbox, read it:
obsidian read file="[filename]" 2>&1 | grep -v "Loading\|out of date\|installer"

# Find seed/growing notes
obsidian search query="[tag:status/seed]" format=json 2>&1 | grep -v "Loading\|out of date\|installer"
obsidian search query="[tag:status/growing]" format=json 2>&1 | grep -v "Loading\|out of date\|installer"

# Read a sampling of permanent notes for broader awareness (up to 20)
obsidian search query="[type:permanent]" format=json 2>&1 | grep -v "Loading\|out of date\|installer"

# Find orphan notes and unresolved links
obsidian orphans 2>&1 | grep -v "Loading\|out of date\|installer"
obsidian unresolved 2>&1 | grep -v "Loading\|out of date\|installer"

# Check previous Claude outputs to avoid repetition
obsidian files folder="80 Claude/Digests" format=json 2>&1 | grep -v "Loading\|out of date\|installer"
obsidian files folder="80 Claude/Connections" format=json 2>&1 | grep -v "Loading\|out of date\|installer"
obsidian files folder="80 Claude/Gaps" format=json 2>&1 | grep -v "Loading\|out of date\|installer"
```

Read the most recent Claude outputs (last 2-3 days) to avoid repeating the same insights.

## Step 2: Read relevant notes in full

Based on the context gathered, read the full content of:
- All inbox items
- Recent daily notes (last 3 days)
- Any seed/growing notes
- Notes that seem relevant to recent activity
Use `obsidian read file="Note Name"` for each.

## Step 3: Generate three output files

### File 1: Daily Digest
```bash
obsidian create name="Claude Digest [TODAY'S DATE]" path="80 Claude/Digests/" 2>&1 | grep -v "Loading\|out of date\|installer"
```

Write content:
```markdown
---
type: claude
subtype: digest
created: [ISO timestamp]
tags: [claude, digest]
---
# Daily Digest — [Today's date, spelled out]

## What Was Captured Yesterday
- Brief summary of new/modified notes

## Open Threads
- Topics or tasks that appear unfinished
- Link to relevant notes with [[wikilinks]]

## Suggested Next Actions
1. 3-5 concrete things to consider doing today
2. Based on recent activity, inbox items, open tasks

## On Your Radar
- Upcoming dates, deadlines, follow-ups from recent notes
```

### File 2: Connections
```bash
obsidian create name="Connections [TODAY'S DATE]" path="80 Claude/Connections/" 2>&1 | grep -v "Loading\|out of date\|installer"
```

Write content:
```markdown
---
type: claude
subtype: connections
created: [ISO timestamp]
tags: [claude, connections]
---
# Connections — [Today's date]

Identify 3-5 non-obvious connections between notes that are NOT already linked.

For each:
### [[Note A]] <-> [[Note B]]
Why these connect: [explanation]
Suggested action: [create a link, merge, create a MOC, etc.]

Prioritise cross-domain connections (e.g., a design philosophy note connecting to a personal reflection). These are the most valuable.
```

### File 3: Gaps
```bash
obsidian create name="Gaps [TODAY'S DATE]" path="80 Claude/Gaps/" 2>&1 | grep -v "Loading\|out of date\|installer"
```

Write content:
```markdown
---
type: claude
subtype: gaps
created: [ISO timestamp]
tags: [claude, gaps]
---
# Knowledge Gaps — [Today's date]

Topics being circled but not written about directly.

For each (3-5 max):
### [Topic Name]
- **Evidence:** [[Note 1]], [[Note 2]], [[Note 3]] all reference this
- **What's missing:** A dedicated note that [describes what it would contain]
- **Suggested title:** "Title of the note to create"
```

Use `obsidian append file="Note Name" content="..."` to write the content to each created file.

## Rules
- Never modify existing notes. Only create new files in 80 Claude/.
- Be specific — reference actual note titles with [[wikilinks]].
- Be concise — each file should be readable in under 2 minutes.
- If very little new activity, say so briefly. Don't generate filler.
- Check previous Claude outputs and avoid repeating the same connections/gaps.
- Use `obsidian backlinks` and `obsidian links` to understand the existing link graph before suggesting new connections.

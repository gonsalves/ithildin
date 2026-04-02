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

### 6. Extract fleeting notes

If any idea in the dump is substantial enough to deserve its own note, create it:
```bash
obsidian create name="Descriptive Title" path="00 Inbox/" 2>&1 | grep -v "Loading\|out of date\|installer"
```

Then write content to it:
```bash
obsidian append file="Descriptive Title" content="---\ntype: fleeting\ncreated: [ISO timestamp]\ntags: []\nsource: \"[[10 Daily/YYYY-MM-DD]]\"\n---\n\n[the idea, expanded slightly]" 2>&1 | grep -v "Loading\|out of date\|installer"
```

Add a link to the extracted note in the processed section.

### 7. Update frontmatter

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

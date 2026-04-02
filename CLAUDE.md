# Second Brain — Claude Code Context

This vault uses a structured "second brain" system. When working in this vault, follow these conventions.

## Folder Structure
- `00 Inbox/` — Everything lands here first. Process during daily review.
- `10 Daily/` — Daily notes (YYYY-MM-DD format). Created automatically.
- `20 Notes/` — Permanent/evergreen notes. Ideas that have been developed.
- `30 Projects/` — Active projects (one subfolder each).
- `40 Areas/` — Ongoing areas of responsibility (work, personal, etc.).
- `50 Resources/` — Reference material, literature notes.
- `60 Writing/` — Drafts, essays, published pieces.
- `70 Reviews/` — Weekly, monthly, annual reviews.
- `80 Claude/` — AI-generated analysis. Subfolders: Digests/, Connections/, Gaps/.
- `90 Archive/` — Completed projects, outdated notes.
- `Templates/` — Obsidian templates. Do not modify directly.
- `Attachments/` — Binary files. Subfolders: images/, pdfs/, audio/, misc/.

## Frontmatter Conventions
Every note MUST have YAML frontmatter with at minimum:
```yaml
---
type: fleeting | permanent | literature | project | meeting | daily | review | claude
created: ISO 8601 timestamp
tags: []
---
```

The `type` field is the most important metadata — it powers search, filtering, and automation.

## Tag Namespaces
- `#status/seed`, `#status/growing`, `#status/evergreen`, `#status/dormant` — note lifecycle
- `#context/work`, `#context/personal`, `#context/side-project` — when/where relevant
- `#topic/*` — emergent, not predefined. Let these grow naturally.
- `#action/read-later`, `#action/follow-up`, `#action/waiting-on` — actionable items

## Obsidian CLI
Use the `obsidian` CLI command for reading and writing vault content. Filter output:
```bash
obsidian <command> 2>&1 | grep -v "Loading\|out of date\|installer"
```

Key commands:
- `obsidian daily:read` — read today's daily note
- `obsidian read file="Note Name"` — read a specific note
- `obsidian search query="keyword" format=json` — search the vault
- `obsidian files format=json` — list all files
- `obsidian tags sort=count` — list all tags
- `obsidian create name="Title" path="00 Inbox/"` — create a note
- `obsidian append file="Title" content="..."` — append to a note
- `obsidian properties:set file="Note" key=value` — set frontmatter
- `obsidian links file="Note"` — outgoing links
- `obsidian backlinks file="Note"` — incoming links
- `obsidian orphans` — notes with no links
- `obsidian unresolved` — broken wikilinks

## Rules
- Use `[[wikilinks]]` for all internal links.
- New notes go to `00 Inbox/` by default.
- Never modify files in `80 Claude/` manually — these are generated.
- Templates use Templater syntax (`<% tp.date.now() %>` for daily notes, `{{date:FORMAT}}` and `{{title}}` for others).
- Capture first, organize later. The inbox is a buffer, not a trap.
- Links between notes are more important than folder placement or tags.

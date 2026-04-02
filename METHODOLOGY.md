# Second Brain Methodology

A complete system for capturing, organising, and developing your knowledge using Obsidian and Claude.

## Philosophy

**Capture first, organise later.** The moment you have a thought is not the moment to decide where it goes. Everything lands in the Inbox. Organisation happens during daily and weekly review, not at the point of capture.

**Links over folders.** Folders give you one place for a note. Links give you many. The connections between your notes are more valuable than where they sit in a hierarchy. When in doubt, add a link.

**Human + AI partnership.** You do the thinking. Claude handles the structure. You dump raw thoughts into daily notes. Claude extracts tasks, surfaces connections, and spots gaps in your knowledge. You decide what to act on.

**The system must serve you, not the other way around.** If maintaining the system takes more time than it saves, something is wrong. Start simple. Add complexity only when you feel the need.

---

## The 6 Systems

### 1. Capture
Get information into your vault with minimal friction. The daily note is your primary capture surface — open it and type. For links, photos, voice notes, and clippings, use Obsidian's share sheet (mobile), web clipper (browser), or Apple Shortcuts. Everything enters `00 Inbox/`.

### 2. Storage
Obsidian is the single source of truth. All notes are markdown files on your filesystem. Attachments (images, PDFs, audio) go in `Attachments/`. Sync across devices with Obsidian Sync, iCloud, or your preferred method.

### 3. Organisation
A PARA-lite folder structure with numbered prefixes for stable sort order. Tags complement folders — they cut across the hierarchy. Maps of Content (MOCs) emerge when you notice 5+ notes clustering around a topic. Don't over-organise. The Inbox is a buffer, not a trap.

### 4. Pattern Recognition (Claude)
A Claude Code scheduled task reads your vault every morning and produces three outputs:
- **Daily Digest** — what you captured, open threads, suggested next actions
- **Connections** — non-obvious links between notes you haven't connected
- **Gaps** — topics you're circling but haven't written about directly

### 5. Synthesis (You)
Weekly and monthly reviews turn raw captures into developed thinking. Review Claude's outputs, create links it suggested, fill gaps that matter, and reflect on what happened. This is where the second brain becomes genuinely useful.

### 6. Writing
When an idea is mature enough, move it from notes into writing. The `60 Writing/` folder supports a draft-to-published workflow. Start from permanent notes and MOCs.

---

## Folder Structure

| Folder | What goes here | When it moves here |
|---|---|---|
| `00 Inbox` | Everything, initially | At capture time |
| `10 Daily` | Daily notes only | Auto-created |
| `20 Notes` | Permanent/evergreen notes | When a fleeting note is refined |
| `30 Projects` | Active project materials | When you start a project |
| `40 Areas` | Ongoing life areas (work, health, finance) | When a topic is ongoing |
| `50 Resources` | Reference material, literature notes | When processing reading/research |
| `60 Writing` | Drafts and published pieces | When you start writing |
| `70 Reviews` | Review notes | During weekly/monthly review |
| `80 Claude` | AI-generated analysis | Auto-created by scheduled tasks |
| `90 Archive` | Done projects, outdated notes | When something is no longer active |
| `Templates` | Note templates | Setup time |
| `Attachments` | Images, PDFs, audio, misc | At capture time |

**Rule of thumb:** If you're unsure where something goes, leave it in Inbox.

---

## Frontmatter

Every note gets YAML frontmatter. The minimum:

```yaml
---
type: fleeting | permanent | literature | project | meeting | daily | review | claude
created: 2026-04-02T14:30:00
tags: []
---
```

The `type` field is the single most important metadata. It powers search, filtering, and Claude's analysis.

---

## Tags

Use nested namespaces, one level deep:

- **Status:** `#status/seed`, `#status/growing`, `#status/evergreen`, `#status/dormant`
- **Context:** `#context/work`, `#context/personal`, `#context/side-project`
- **Topic:** `#topic/*` — let these emerge naturally. Don't predefine a taxonomy.
- **Action:** `#action/read-later`, `#action/follow-up`, `#action/waiting-on`

Keep it to 1-3 tags per note. Less is more.

---

## Templates

Seven templates are provided:

| Template | Use for |
|---|---|
| Daily Note | Your daily dump — unstructured text, Claude processes it later |
| Fleeting Note | Quick captures, raw ideas |
| Permanent Note | Developed ideas with evidence and connections |
| Literature Note | Notes from books, articles, podcasts |
| Meeting Note | Meeting agendas, notes, action items |
| Project Note | Active project tracking |
| Weekly Review | Weekly reflection and inbox processing |

---

## Daily Routine (5-10 minutes)

1. Open today's daily note. Dump whatever's on your mind throughout the day.
2. In the morning, glance at Claude's digest (in `80 Claude/Digests/`).
3. Process `00 Inbox/` — for each note, decide: move it, tag it, or delete it.
4. Answer any questions Claude left in yesterday's processed daily note.

That's it. The system does the rest.

---

## Weekly Review (30-45 minutes)

Use the Weekly Review template. The key steps:

1. **Empty the Inbox** — everything in `00 Inbox/` gets moved or deleted.
2. **Review Claude's outputs** — read the week's digests, connections, and gaps. Create any links that resonate. Fill any gaps that matter.
3. **Reflect** — what happened this week? What did you learn? What's unfinished?
4. **Check active projects** — one sentence on each.
5. **Develop notes** — promote any fleeting notes worth keeping to permanent notes.
6. **Housekeeping** — archive completed projects, update MOCs, tag mature notes.

---

## How Claude Automation Works

Two scheduled tasks run automatically:

### Process Daily Note (9 PM)

Reads your raw daily note and appends a structured section below a divider:
- Extracts tasks, events, ideas, references, people
- Links to existing notes in the vault using `[[wikilinks]]`
- Asks clarifying questions about ambiguous items
- Creates fleeting notes in `00 Inbox/` for substantial ideas
- Never modifies your original text

### Morning Digest (6 AM)

Reads the vault and generates three files in `80 Claude/`:
- **Digest** — summary of recent activity, open threads, suggested actions
- **Connections** — non-obvious links between unconnected notes
- **Gaps** — topics referenced across multiple notes but never directly addressed

Both tasks use the Obsidian CLI to read and write vault content. They require Obsidian to be running on your Mac.

```
You write messy notes
        |
        v
Claude (9 PM) structures them, links them, asks questions
        |
        v
Claude (6 AM) analyses the vault, finds connections, spots gaps
        |
        v
You (morning) review the digest, answer questions, act on suggestions
        |
        v
You (weekly) review, reflect, develop notes, clean up
```

---

## Tips for Getting Started

1. **Start with just the daily note.** Don't try to use all 7 templates on day one. Capture everything in the daily note for the first week.

2. **Don't over-organise.** The Inbox exists so you don't have to decide where things go in the moment. Trust it.

3. **Let tags emerge.** Don't create a taxonomy upfront. As you write, you'll notice natural categories. Add tags when they feel obvious, not before.

4. **Create MOCs when you feel the pull.** When you notice 5+ notes about the same topic and you keep wanting a "home base" for that topic, that's when you create a Map of Content.

5. **Answer Claude's questions.** The daily processing works best as a conversation. When Claude asks "is this related to X?", take 30 seconds to answer. This helps future processing.

6. **The system gets better over time.** Week one, Claude doesn't have much to work with. By month two, the connections and gaps become genuinely insightful. Stick with it.

7. **Modify freely.** This is your system. Change the folder names, adjust the templates, tweak the tag namespaces. The methodology is a starting point, not a rulebook.

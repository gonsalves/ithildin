# Ithildin — Project Handoff

> A complete second brain system for Obsidian + Claude. Named after the moon-writing on the doors of Moria — hidden connections that only appear when you look at them the right way.

## What Exists Today

### The Repo (github.com/gonsalves/ithildin)

An open-source project at `/Users/rahul.gonsalves/Documents/ithildin/` with:

| File | Purpose |
|---|---|
| `setup.sh` | One-command setup. Creates folders, copies templates, merges Obsidian config, installs scheduled tasks. Auto-installs Obsidian/Claude Code/jq if missing. Fully idempotent. |
| `CLAUDE.md` | Gets copied to the user's vault root. Teaches Claude Code about the vault structure and conventions. |
| `METHODOLOGY.md` | The system philosophy and routines — the human-readable guide. |
| `README.md` | Quick start, prerequisites, how it works. |
| `scaffold/templates/` | 7 Obsidian note templates (Daily, Fleeting, Permanent, Literature, Meeting, Project, Weekly Review). |
| `scaffold/obsidian-config/` | 3 JSON config files (app.json, daily-notes.json, core-plugins.json). |
| `tasks/process-daily-note.md` | Scheduled task prompt — structures raw daily notes at 9 PM. |
| `tasks/morning-brain-digest.md` | Scheduled task prompt — generates digest, connections, gaps at 6 AM. |

### Rahul's Personal Vault

At `/Users/rahul.gonsalves/Documents/echocortex/` — the live vault with:
- Full folder structure (00 Inbox through 90 Archive)
- ~195 notes migrated from the old numbered structure (1-PhonePe → 40 Areas/PhonePe, etc.)
- 7 templates in `Templates/`
- Templater, QuickAdd, Dataview community plugins installed
- 3 Claude outputs already generated (Digest, Connections, Gaps for 2026-04-02)
- 2 scheduled tasks running:
  - `process-daily-note` at 9:03 PM daily
  - `morning-brain-digest` at 6:03 AM daily

### Obsidian Settings Configured

- New notes default to `00 Inbox/`
- Attachments default to `Attachments/`
- Daily notes go to `10 Daily/` with `Templates/Daily Note.md` template
- Templater trigger on file creation: ON
- Wikilinks enabled, auto-update links on rename

---

## Architecture

```
User writes messy daily notes throughout the day
         |
         v
process-daily-note (9 PM) — reads via Obsidian CLI
  - Structures the dump (tasks, events, ideas, references, people)
  - Links to existing vault notes with [[wikilinks]]
  - Asks clarifying questions inline
  - Extracts substantial ideas to 00 Inbox/ as fleeting notes
  - Sets processed: true in frontmatter
         |
         v
morning-brain-digest (6 AM) — reads via Obsidian CLI
  - Generates 80 Claude/Digests/Claude Digest YYYY-MM-DD.md
  - Generates 80 Claude/Connections/Connections YYYY-MM-DD.md
  - Generates 80 Claude/Gaps/Gaps YYYY-MM-DD.md
  - Checks previous outputs to avoid repetition
         |
         v
User reviews digest, answers questions, processes inbox
```

Both tasks use the **Obsidian CLI** (`obsidian` command) — not direct filesystem access. Key commands: `daily:read`, `read`, `search`, `create`, `append`, `properties:set`, `tags`, `files`, `backlinks`, `links`, `orphans`, `unresolved`.

CLI quirk: outputs installer warnings that must be filtered with `grep -v "Loading\|out of date\|installer"`.

---

## What's Been Done (Phases Completed)

### Phase 1: Foundation ✅
- Vault folder structure created and existing notes migrated
- Obsidian settings configured
- Core templates created
- Essential plugins installed (Templater, QuickAdd, Dataview)

### Phase 4: Pattern Recognition ✅ (done before Phase 2-3)
- Both scheduled tasks created and tested
- Morning digest test run produced real outputs against the vault
- Daily note processing tested on 2026-04-01 note

### Packaging ✅
- Repo created, tested, pushed to GitHub
- setup.sh is idempotent and auto-installs prerequisites
- All documentation written

---

## What's NOT Done Yet

### Phase 2: Capture Expansion (Day 3-7)
- [ ] Build 4 Apple Shortcuts (Quick Note, Save Link, Voice Capture, Photo Capture)
- [ ] Add Shortcuts to iPhone home screen and lock screen widgets
- [ ] Install Obsidian Web Clipper on Safari (Mac and iOS)
- [ ] Set up Readwise integration (if Rahul uses Readwise)
- [ ] Configure QuickAdd with capture actions and hotkeys on Mac
- [ ] Test each capture path end-to-end

### Phase 3: Organisation (Week 2)
- [ ] Install Periodic Notes, Tag Wrangler, Natural Language Dates plugins
- [ ] Start daily processing routine (5-10 min)
- [ ] Create first Map of Content for most active topic
- [ ] Begin using namespaced tag strategy (#status/, #topic/, #action/)
- [ ] Do first weekly review using the template
- [ ] Process backlog of notes from Phase 1 migration

### Phase 5: Synthesis & Writing (Month 2+)
- [ ] Create Monthly Review template
- [ ] Set up Writing folder workflow (Drafts/, Published/, Ideas/)
- [ ] Pick one topic with 5+ notes and create a MOC
- [ ] Develop one seed note into a permanent note
- [ ] Explore publishing pipeline (Enveloppe, Pandoc) if desired

### Repo Improvements
- [ ] Apple Shortcuts export files in `shortcuts/` directory
- [ ] Linux/Windows support in setup.sh
- [ ] Community plugin auto-detection (check if already installed)
- [ ] Uninstall script
- [ ] Update script (pull new templates/prompts without losing customisation)
- [ ] Ship Templater config file (templater-obsidian/data.json)
- [ ] Consider: should CLAUDE.md also go to `~/.claude/projects/` for the vault path?

### Product/System Ideas Discussed But Not Built
- **Obsidian plugin version** — a true one-click install via Obsidian's community plugin marketplace. Would use `app.vault` and `app.metadataCache` APIs instead of CLI. Deferred in favour of CLI approach for v1.
- **Obsidian Headless** — `npm install -g obsidian-headless` could enable server-side processing without the desktop app. Useful for power users running on a Raspberry Pi or VPS.
- **Vault migration wizard** — Claude reads an existing vault and suggests a migration plan. Currently migration is manual.

---

## Key Design Decisions (and why)

1. **Obsidian CLI over direct filesystem access** — gives us Obsidian's metadata cache, link resolution, and search for free. Requires the desktop app to be running.

2. **BYOK (Bring Your Own Key)** — no backend, no proxy, no accounts. User's API key talks directly to Anthropic. Data stays local.

3. **Daily note as blank dump** — Rahul explicitly wanted zero friction capture. Claude handles structure, not the user.

4. **Processed section below a divider** — original text is never modified. Claude appends below `---`.

5. **Questions inline, not in separate notes** — Rahul preferred seeing Claude's questions right in the daily note.

6. **Two separate scheduled tasks** — processing (evening) and analysis (morning) are decoupled. Either can run independently.

7. **No community plugin auto-installation** — Obsidian requires UI interaction for security. We print instructions instead.

8. **jq for config merging** — safest way to merge JSON without overwriting user settings. Auto-installed if Homebrew is present.

---

## Files That Matter

| What | Path |
|---|---|
| Repo | `/Users/rahul.gonsalves/Documents/ithildin/` |
| Live vault | `/Users/rahul.gonsalves/Documents/echocortex/` |
| Process daily note task | `~/.claude/scheduled-tasks/process-daily-note/SKILL.md` |
| Morning digest task | `~/.claude/scheduled-tasks/morning-brain-digest/SKILL.md` |
| Original system plan | `~/.claude/plans/humble-watching-wombat.md` (1000+ lines) |
| Detailed methodology plan | `~/.claude/plans/humble-watching-wombat-agent-ad5971eb3bce4db9f.md` |
| Claude memory | `~/.claude/projects/-Users-rahul-gonsalves-Documents-exec-acc/memory/` |
| Obsidian config | `/Users/rahul.gonsalves/Documents/echocortex/.obsidian/` |
| GitHub | https://github.com/gonsalves/ithildin |

---

## Rahul's Preferences (from this session)

- Prefers things that just work — technically capable but not interested in fiddling
- Apple ecosystem (Mac, iPhone, iPad), Obsidian Sync for cross-device
- Wants the system to last years — mundane to sacred
- Chose blank daily notes over structured templates (capture first, structure later)
- Wants Claude's questions inline in the daily note
- Open source, not interested in monetisation
- LOTR fan — hence Ithildin

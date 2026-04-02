# Ithildin

*Moon-letters that reveal hidden connections.*

A complete second brain system built on Obsidian + Claude. Capture everything, let AI structure it, surface connections you'd miss.

**One repo. One command. A working system.**

## What You Get

- **12-folder vault structure** based on PARA methodology
- **7 templates** for daily notes, fleeting ideas, literature notes, meetings, projects, permanent notes, and weekly reviews
- **Automated daily note processing** — dump unstructured text all day, Claude structures it at 9 PM
- **Article fetching** — URLs in your daily notes are automatically fetched, summarised, and saved as Literature Notes (with archive.today fallback for paywalls)
- **Morning intelligence digest** — Claude surfaces connections between notes and identifies knowledge gaps at 6 AM
- **CLAUDE.md** — teaches Claude Code how to work with your vault

## Prerequisites

- **macOS** (Linux/Windows support planned)
- An **Anthropic API key** for Claude Code

The setup script will check for and offer to install:
- **[Obsidian](https://obsidian.md)** (via Homebrew or direct download)
- **[Claude Code](https://claude.ai/code)** (via Homebrew or npm)
- **jq** (via Homebrew, for config merging)
- **readability-cli** (via npm, for fetching article text from URLs)

## Quick Start

```bash
git clone https://github.com/gonsalves/ithildin.git
cd ithildin
./setup.sh ~/Documents/Obsidian\ Vault
```

The setup script will:
1. Create the folder structure (19 folders, all idempotent)
2. Copy 7 note templates
3. Configure Obsidian settings (merges with existing config, never overwrites)
4. Install Claude Code scheduled task definitions
5. Copy CLAUDE.md to your vault root

Then follow the printed next steps to install community plugins and activate the scheduled tasks.

## The System

Your second brain has 6 modular systems that work independently:

1. **Capture** — get information in fast (daily notes, share sheet, web clipper)
2. **Storage** — Obsidian vault with consistent structure and metadata
3. **Organisation** — PARA-lite folders, namespaced tags, emergent Maps of Content
4. **Pattern Recognition** — Claude reads the vault daily and surfaces insights
5. **Synthesis** — you review, reflect, and develop ideas (weekly/monthly)
6. **Writing** — turn mature notes into drafts and published pieces

Read the full methodology: [METHODOLOGY.md](METHODOLOGY.md)

## Community Plugins

After running setup, install these three plugins in Obsidian (Settings > Community Plugins > Browse):

| Plugin | Author | Purpose |
|---|---|---|
| **Templater** | SilentVoid13 | Dynamic templates with dates and logic |
| **QuickAdd** | Christian Houmann | Rapid capture with hotkeys |
| **Dataview** | Michael Brenan | Query your notes like a database |

After installing Templater, set:
- Template folder location: `Templates`
- Trigger Templater on new file creation: **ON**

## Scheduled Tasks

Two Claude Code tasks power the AI layer:

| Task | Schedule | What it does |
|---|---|---|
| `process-daily-note` | 9 PM daily | Structures your raw daily dump, extracts tasks, links notes, fetches linked articles, asks questions |
| `morning-brain-digest` | 6 AM daily | Generates a digest, surfaces connections, identifies knowledge gaps |

Activate them in Claude Code:
```
/schedule process-daily-note --cron '0 21 * * *'
/schedule morning-brain-digest --cron '0 6 * * *'
```

Both tasks require Obsidian to be running (for CLI access).

## Customisation

- **Templates** — edit files in `Templates/` to match your style
- **Folder structure** — rename folders, but update CLAUDE.md to match
- **Task schedules** — change the cron expressions to fit your routine
- **Task prompts** — edit `~/.claude/scheduled-tasks/*/SKILL.md` to adjust what Claude does
- **Tags** — the namespace system is a suggestion, not a constraint

## How It Works

```
You write messy daily notes
         |
         v
Claude (9 PM) structures them, links to existing notes, asks questions
         |
         v
Claude (6 AM) reads the vault, finds connections, spots gaps
         |
         v
You (morning) review digest, answer questions, process inbox
         |
         v
You (weekly) reflect, develop notes, archive completed work
```

## Project Structure

```
ithildin/
├── README.md              # This file
├── METHODOLOGY.md         # The full system methodology
├── CLAUDE.md              # Gets copied to your vault root
├── LICENSE                # MIT
├── setup.sh               # One-command setup
├── scaffold/
│   ├── templates/         # 7 Obsidian note templates
│   └── obsidian-config/   # Obsidian settings files
├── tasks/
│   ├── process-daily-note.md    # Evening processing task
│   └── morning-brain-digest.md  # Morning digest task
└── shortcuts/             # Future: Apple Shortcuts
```

## License

MIT

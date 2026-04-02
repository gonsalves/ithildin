#!/bin/bash
set -euo pipefail

# ============================================================
# Ithildin — Setup Script
# ============================================================
# Sets up an Obsidian vault with the Ithildin system:
#   - Folder structure (PARA-lite, 12 top-level folders)
#   - Templates (7 note types)
#   - Obsidian config (default locations, daily notes)
#   - Claude Code scheduled tasks (daily processing + morning digest)
#   - CLAUDE.md for vault-aware AI assistance
#
# Usage: ./setup.sh [vault-path]
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Colors and helpers ---

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${BLUE}[info]${RESET} $1"; }
success() { echo -e "${GREEN}[ok]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[warn]${RESET} $1"; }
error()   { echo -e "${RED}[error]${RESET} $1"; }

confirm() {
  local prompt="${1:-Continue?}"
  read -r -p "$(echo -e "${YELLOW}$prompt [y/N]${RESET} ")" response
  [[ "$response" =~ ^[Yy]$ ]]
}

# --- Step 1: Get vault path ---

echo ""
echo -e "${BOLD}Ithildin Setup${RESET}"
echo "=========================================="
echo ""

if [[ $# -ge 1 ]]; then
  VAULT_PATH="$1"
else
  read -r -p "Enter the full path to your Obsidian vault: " VAULT_PATH
fi

# Expand ~
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

# Remove trailing slash
VAULT_PATH="${VAULT_PATH%/}"

if [[ ! -d "$VAULT_PATH" ]]; then
  error "Directory does not exist: $VAULT_PATH"
  if confirm "Create it?"; then
    mkdir -p "$VAULT_PATH"
    success "Created $VAULT_PATH"
  else
    exit 1
  fi
fi

if [[ ! -d "$VAULT_PATH/.obsidian" ]]; then
  warn "No .obsidian folder found. This may not be an Obsidian vault yet."
  if confirm "Continue anyway? (Obsidian will create .obsidian when you open this folder as a vault)"; then
    mkdir -p "$VAULT_PATH/.obsidian"
  else
    exit 1
  fi
fi

echo ""
info "Vault path: $VAULT_PATH"
echo ""

# --- Step 2: Check and install prerequisites ---

# Find Homebrew (may not be in PATH in non-interactive shells)
find_brew() {
  if command -v brew &>/dev/null; then
    echo "brew"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    echo "/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    echo "/usr/local/bin/brew"
  else
    echo ""
  fi
}

BREW="$(find_brew)"

install_with_brew() {
  local formula="$1"
  local is_cask="${2:-false}"
  if [[ -z "$BREW" ]]; then
    return 1
  fi
  if [[ "$is_cask" == "true" ]]; then
    $BREW install --cask "$formula"
  else
    $BREW install "$formula"
  fi
}

if [[ "$(uname)" != "Darwin" ]]; then
  warn "This script is designed for macOS. Some features may differ on other platforms."
fi

# --- Obsidian ---

if [[ -d "/Applications/Obsidian.app" ]]; then
  success "Obsidian installed"
else
  warn "Obsidian is not installed."
  if confirm "Install Obsidian?"; then
    if [[ -n "$BREW" ]]; then
      info "Installing Obsidian via Homebrew..."
      install_with_brew obsidian true
      success "Obsidian installed"
    else
      info "Downloading Obsidian..."
      DMG_PATH="/tmp/Obsidian.dmg"
      curl -fsSL -o "$DMG_PATH" "https://github.com/obsidianmd/obsidian-releases/releases/latest/download/Obsidian-universal.dmg"
      info "Mounting disk image..."
      MOUNT_POINT="$(hdiutil attach "$DMG_PATH" -nobrowse -quiet | tail -1 | awk '{print $3}')"
      info "Installing to /Applications..."
      cp -R "$MOUNT_POINT/Obsidian.app" /Applications/
      hdiutil detach "$MOUNT_POINT" -quiet
      rm -f "$DMG_PATH"
      success "Obsidian installed to /Applications"
    fi
    echo ""
    warn "IMPORTANT: Open Obsidian once, then enable the CLI:"
    warn "  Settings > General > Enable Command Line Interface"
    echo ""
  fi
fi

# --- Obsidian CLI ---

OBSIDIAN_CLI_OK=false
if command -v obsidian &>/dev/null; then
  success "Obsidian CLI found"
  OBSIDIAN_CLI_OK=true
elif [[ -x "/Applications/Obsidian.app/Contents/MacOS/obsidian" ]]; then
  warn "Obsidian is installed but CLI is not in PATH."
  warn "Enable it: Obsidian > Settings > General > Enable Command Line Interface"
  warn "Or add to your shell profile: export PATH=\"\$PATH:/Applications/Obsidian.app/Contents/MacOS\""
else
  warn "Obsidian CLI not available. Scheduled tasks need it to work."
fi

# --- Claude Code ---

if command -v claude &>/dev/null; then
  success "Claude Code found"
else
  warn "Claude Code not found."
  if confirm "Install Claude Code?"; then
    if [[ -n "$BREW" ]]; then
      info "Installing Claude Code via Homebrew..."
      install_with_brew claude-code true
      success "Claude Code installed"
    else
      info "Installing Claude Code via npm..."
      if command -v npm &>/dev/null; then
        npm install -g @anthropic-ai/claude-code
        success "Claude Code installed"
      else
        error "Neither Homebrew nor npm found. Install Claude Code manually:"
        error "  https://claude.ai/code"
      fi
    fi
    echo ""
    warn "Run 'claude' once to authenticate with your Anthropic API key."
    echo ""
  fi
fi

# --- jq ---

HAS_JQ=false
if command -v jq &>/dev/null; then
  success "jq found"
  HAS_JQ=true
else
  if [[ -n "$BREW" ]]; then
    info "Installing jq for config merging..."
    install_with_brew jq
    success "jq installed"
    HAS_JQ=true
  else
    warn "jq not found and no Homebrew. Config merging will use simple copy instead."
  fi
fi

echo ""

# --- Step 3: Create folder structure ---

info "Creating folder structure..."

FOLDERS=(
  "00 Inbox"
  "10 Daily"
  "20 Notes"
  "30 Projects"
  "40 Areas"
  "50 Resources"
  "60 Writing"
  "70 Reviews"
  "80 Claude"
  "80 Claude/Digests"
  "80 Claude/Connections"
  "80 Claude/Gaps"
  "90 Archive"
  "Templates"
  "Attachments"
  "Attachments/images"
  "Attachments/pdfs"
  "Attachments/audio"
  "Attachments/misc"
)

CREATED=0
EXISTED=0
for folder in "${FOLDERS[@]}"; do
  if [[ -d "$VAULT_PATH/$folder" ]]; then
    EXISTED=$((EXISTED + 1))
  else
    mkdir -p "$VAULT_PATH/$folder"
    CREATED=$((CREATED + 1))
  fi
done

success "Folders: $CREATED created, $EXISTED already existed"

# --- Step 4: Copy templates ---

info "Copying templates..."

TEMPLATES_SRC="$SCRIPT_DIR/scaffold/templates"
TEMPLATES_DEST="$VAULT_PATH/Templates"

for template in "$TEMPLATES_SRC"/*.md; do
  filename="$(basename "$template")"
  dest="$TEMPLATES_DEST/$filename"
  if [[ -f "$dest" ]]; then
    if confirm "Template '$filename' already exists. Overwrite?"; then
      cp "$template" "$dest"
      success "Overwrote: $filename"
    else
      info "Skipped: $filename"
    fi
  else
    cp "$template" "$dest"
    success "Copied: $filename"
  fi
done

# --- Step 5: Configure Obsidian ---

info "Configuring Obsidian settings..."

OBSIDIAN_DIR="$VAULT_PATH/.obsidian"
mkdir -p "$OBSIDIAN_DIR"

merge_json_object() {
  local target="$1"
  local source="$2"
  if [[ -f "$target" ]] && [[ "$HAS_JQ" == "true" ]]; then
    jq -s '.[0] * .[1]' "$target" "$source" > "$target.tmp"
    mv "$target.tmp" "$target"
    success "Merged settings into $(basename "$target")"
  elif [[ -f "$target" ]]; then
    warn "$(basename "$target") exists and jq is not available — skipping merge"
    warn "Please manually add these settings: $(cat "$source")"
  else
    cp "$source" "$target"
    success "Created $(basename "$target")"
  fi
}

merge_json_array() {
  local target="$1"
  local source="$2"
  if [[ -f "$target" ]] && [[ "$HAS_JQ" == "true" ]]; then
    jq -s '.[0] + .[1] | unique' "$target" "$source" > "$target.tmp"
    mv "$target.tmp" "$target"
    success "Merged $(basename "$target") (union of plugins)"
  elif [[ -f "$target" ]]; then
    warn "$(basename "$target") exists and jq is not available — skipping merge"
  else
    cp "$source" "$target"
    success "Created $(basename "$target")"
  fi
}

merge_json_object "$OBSIDIAN_DIR/app.json" "$SCRIPT_DIR/scaffold/obsidian-config/app.json"
merge_json_object "$OBSIDIAN_DIR/daily-notes.json" "$SCRIPT_DIR/scaffold/obsidian-config/daily-notes.json"
merge_json_array "$OBSIDIAN_DIR/core-plugins.json" "$SCRIPT_DIR/scaffold/obsidian-config/core-plugins.json"

# --- Step 6: Copy CLAUDE.md ---

info "Setting up CLAUDE.md..."

CLAUDE_DEST="$VAULT_PATH/CLAUDE.md"
if [[ -f "$CLAUDE_DEST" ]]; then
  if confirm "CLAUDE.md already exists in vault. Overwrite?"; then
    cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DEST"
    success "Overwrote CLAUDE.md"
  else
    info "Skipped CLAUDE.md"
  fi
else
  cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DEST"
  success "Copied CLAUDE.md to vault"
fi

# --- Step 7: Install scheduled tasks ---

info "Installing Claude Code scheduled tasks..."

TASKS_DIR="$HOME/.claude/scheduled-tasks"

install_task() {
  local task_name="$1"
  local task_src="$SCRIPT_DIR/tasks/$task_name.md"
  local dest_dir="$TASKS_DIR/$task_name"

  if [[ ! -f "$task_src" ]]; then
    error "Task file not found: $task_src"
    return 1
  fi

  mkdir -p "$dest_dir"

  if [[ -f "$dest_dir/SKILL.md" ]]; then
    if confirm "Scheduled task '$task_name' already exists. Overwrite?"; then
      cp "$task_src" "$dest_dir/SKILL.md"
      success "Overwrote task: $task_name"
    else
      info "Skipped task: $task_name"
    fi
  else
    cp "$task_src" "$dest_dir/SKILL.md"
    success "Installed task: $task_name"
  fi
}

install_task "process-daily-note"
install_task "morning-brain-digest"

# --- Step 8: Summary ---

echo ""
echo -e "${BOLD}=========================================="
echo -e "  Ithildin setup complete!"
echo -e "==========================================${RESET}"
echo ""
echo -e "Your vault is ready at: ${BOLD}$VAULT_PATH${RESET}"
echo ""
echo -e "${BOLD}NEXT STEPS:${RESET}"
echo ""
echo "1. Open your vault in Obsidian (or restart it if already open)"
echo ""
echo "2. Install these community plugins (Settings > Community Plugins > Browse):"
echo "   - Templater         (by SilentVoid13)        — dynamic templates"
echo "   - QuickAdd          (by Christian Houmann)    — rapid capture"
echo "   - Dataview          (by Michael Brenan)       — query your notes"
echo ""
echo "3. Configure Templater:"
echo "   Settings > Templater > Template folder location: Templates"
echo "   Settings > Templater > Trigger Templater on new file creation: ON"
echo ""
echo "4. Activate the scheduled Claude Code tasks:"
echo "   Open Claude Code and run:"
echo "     /schedule process-daily-note --cron '0 21 * * *'"
echo "     /schedule morning-brain-digest --cron '0 6 * * *'"
echo ""
echo "5. Start capturing! Open today's daily note and dump whatever's on your mind."
echo "   Claude will structure it at 9 PM and deliver a digest at 6 AM."
echo ""
echo "For the full methodology, read: METHODOLOGY.md"
echo "For how Claude understands your vault: $VAULT_PATH/CLAUDE.md"
echo ""

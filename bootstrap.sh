#!/bin/bash

# Agent Framework — Bootstrap Script
# One-liner install and update for Agent Framework.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/chriseay/agent-framework/main/bootstrap.sh | bash -s -- /path/to/project
#
# Or run directly:
#   ./bootstrap.sh /path/to/project

set -e

REPO_URL="https://github.com/chriseay/agent-framework.git"
FRAMEWORK_DIR="$HOME/.agent-framework"

# --- Interactivity detection ---
INTERACTIVE=false
[ -t 0 ] && INTERACTIVE=true

# --- Per-file safe copy (skips or prompts on local edits) ---
SKIPPED_FILES=""
CONFLICTS=""
STALE_FILES=""

safe_copy() {
    local src="$1"
    local dst="$2"
    local label="$3"

    # Derive relative path and base snapshot location
    local relative="${src#"$FRAMEWORK_DIR"/}"
    local base="$TARGET_DIR/.framework-base/$relative"
    mkdir -p "$(dirname "$base")"

    # Case 1: Destination doesn't exist yet (fresh install)
    if [ ! -f "$dst" ]; then
        cp "$src" "$dst"
        cp "$src" "$base"
        return
    fi

    # Case 2: No local edits vs new framework version
    if diff -q "$src" "$dst" > /dev/null 2>&1; then
        cp "$src" "$dst"
        cp "$src" "$base"
        return
    fi

    # Case 3: Local edits exist — determine merge base
    local merge_base=""
    if [ -f "$base" ]; then
        merge_base="$base"                          # subsequent upgrade
    elif [ -f "$PRE_PULL_TMP/$relative" ]; then
        merge_base="$PRE_PULL_TMP/$relative"        # first upgrade (pre-pull snapshot)
    fi

    if [ -n "$merge_base" ]; then
        # Stale base correction: if base is strictly ahead of local with no user
        # additions, the base was set to a newer version than what was actually
        # installed (Phase 28 bug). Reset base to local so the merge is correct.
        local user_adds base_surplus
        user_adds=$(diff "$merge_base" "$dst" 2>/dev/null | grep -c "^>" | tr -d ' ')
        base_surplus=$(diff "$merge_base" "$dst" 2>/dev/null | grep -c "^<" | tr -d ' ')
        if [ "$base_surplus" -gt 0 ]; then
            if [ "$user_adds" -eq 0 ]; then
                # No user edits — reset base to local so merge applies framework cleanly
                cp "$dst" "$merge_base"
            else
                # Base ahead AND local has user edits — no valid common ancestor.
                # Apply framework directly; user must re-check their edits.
                cp "$src" "$dst"
                cp "$src" "$base"
                echo "  Updated (stale base — $user_adds local edit(s) need re-checking): $label"
                STALE_FILES="${STALE_FILES}  - ${label} ($user_adds edit(s))\\n"
                return
            fi
        fi

        # Attempt 3-way merge
        local tmp
        tmp=$(mktemp)
        cp "$dst" "$tmp"
        local merge_exit=0
        git merge-file -L "local" -L "base" -L "framework" \
            "$tmp" "$merge_base" "$src" || merge_exit=$?
        cp "$tmp" "$dst"
        rm -f "$tmp"
        cp "$src" "$base"   # update base to new framework version

        if [ "$merge_exit" -eq 0 ]; then
            echo "  Merged: $label"
        else
            echo "  CONFLICT: $label (contains conflict markers — resolve manually)"
            CONFLICTS="${CONFLICTS}  - ${label}\n"
        fi
        return
    fi

    # Case 4: No merge base available — fall back to safe_copy behaviour
    if [ "$INTERACTIVE" = false ]; then
        echo "  SKIPPED (local edits): $label"
        SKIPPED_FILES="${SKIPPED_FILES}  - ${label}\n"
        cp "$dst" "$base"   # save base so next run can merge
        return
    fi

    echo ""
    echo "Local edits detected: $label"
    diff "$src" "$dst" | head -50
    echo ""
    read -p "Overwrite $label? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$src" "$dst"
        cp "$src" "$base"
        echo "  Overwritten: $label"
    else
        echo "  Skipped: $label"
        SKIPPED_FILES="${SKIPPED_FILES}  - ${label}\n"
        cp "$dst" "$base"   # save base so next run can merge
    fi
}

# --- Main install/upgrade flow ---
# Wrapped in a function so this script can be sourced (e.g. by test/fixtures/
# tooling, to call safe_copy() directly) without running the full install.
main() {

# --- Argument parsing ---
if [ -z "$1" ]; then
    echo "Error: Target project directory is required."
    echo ""
    echo "Usage:"
    echo "  curl -sL https://raw.githubusercontent.com/chriseay/agent-framework/main/bootstrap.sh | bash -s -- /path/to/project"
    echo ""
    echo "Or run directly:"
    echo "  ./bootstrap.sh /path/to/project"
    exit 1
fi

TARGET_DIR="$1"

echo "Agent Framework Bootstrap"
echo "========================="
echo ""

# --- Phase 1: Prerequisites ---
MISSING=""
if ! command -v git &> /dev/null; then
    MISSING="git"
fi
if ! command -v claude &> /dev/null; then
    if [ -n "$MISSING" ]; then
        MISSING="$MISSING, claude (Claude Code CLI)"
    else
        MISSING="claude (Claude Code CLI)"
    fi
fi
if [ -n "$MISSING" ]; then
    echo "Error: Missing required tools: $MISSING"
    echo ""
    echo "Install Claude Code from: https://claude.ai/claude-code"
    exit 1
fi

# --- Phase 2: Clone or update ~/.agent-framework ---

# Snapshot framework files before pull (used as merge base on first upgrade)
PRE_PULL_TMP=$(mktemp -d)
_snapshot_framework_files() {
    local src_dir="$1" dst_dir="$2"
    [ -f "$src_dir/CLAUDE.md" ]          && cp "$src_dir/CLAUDE.md" "$dst_dir/CLAUDE.md"
    [ -f "$src_dir/AGENTS.md" ]          && cp "$src_dir/AGENTS.md" "$dst_dir/AGENTS.md"
    [ -f "$src_dir/claude-dispatch.sh" ] && cp "$src_dir/claude-dispatch.sh" "$dst_dir/claude-dispatch.sh"
    if [ -d "$src_dir/skills" ]; then
        mkdir -p "$dst_dir/skills"
        for f in "$src_dir/skills/"*.md; do
            [ -f "$f" ] && cp "$f" "$dst_dir/skills/$(basename "$f")"
        done
    fi
    if [ -d "$src_dir/.claude/agents" ]; then
        mkdir -p "$dst_dir/.claude/agents"
        for f in "$src_dir/.claude/agents/"*.md; do
            [ -f "$f" ] && cp "$f" "$dst_dir/.claude/agents/$(basename "$f")"
        done
    fi
}

if [ -d "$FRAMEWORK_DIR" ]; then
    if [ -d "$FRAMEWORK_DIR/.git" ]; then
        echo "Updating framework in $FRAMEWORK_DIR..."
        _snapshot_framework_files "$FRAMEWORK_DIR" "$PRE_PULL_TMP"
        if ! git -C "$FRAMEWORK_DIR" pull --ff-only 2>&1; then
            echo ""
            echo "Error: Could not update $FRAMEWORK_DIR (pull --ff-only failed)."
            echo "This usually means local modifications exist. To resolve:"
            echo "  cd $FRAMEWORK_DIR"
            echo "  git stash    # save local changes"
            echo "  git pull"
            echo "  git stash pop  # restore local changes (if needed)"
            exit 1
        fi
    else
        echo "Error: $FRAMEWORK_DIR exists but is not a git repository."
        echo "Remove it and re-run this script:"
        echo "  rm -rf $FRAMEWORK_DIR"
        exit 1
    fi
else
    echo "Cloning framework to $FRAMEWORK_DIR..."
    if ! git clone "$REPO_URL" "$FRAMEWORK_DIR" 2>&1; then
        echo ""
        echo "Error: Failed to clone $REPO_URL"
        exit 1
    fi
fi

echo ""

# --- Phase 3: Plugin registration ---
echo "Registering Claude Code plugin..."
claude plugin remove agent-framework 2>&1 || true
claude plugin marketplace add chriseay/agent-framework 2>&1 || true
claude plugin install agent-framework@agent-framework 2>&1

echo ""

# --- Phase 4: Copy framework files to target ---

# Resolve target to absolute path
mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Safety check
if [ "$TARGET_DIR" = "$FRAMEWORK_DIR" ]; then
    echo "Error: Target directory is the framework clone itself."
    echo "Choose a different project directory."
    exit 1
fi

echo "Target: $TARGET_DIR"
echo ""

# Copy framework files
echo "Copying framework files..."

safe_copy "$FRAMEWORK_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md" "CLAUDE.md"
safe_copy "$FRAMEWORK_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md" "AGENTS.md"

mkdir -p "$TARGET_DIR/.workflow"
if [ ! -f "$TARGET_DIR/.workflow/state.md" ]; then
    cp "$FRAMEWORK_DIR/templates/state.md" "$TARGET_DIR/.workflow/state.md"
fi

mkdir -p "$TARGET_DIR/skills"
for f in "$FRAMEWORK_DIR/skills/"*.md; do
    safe_copy "$f" "$TARGET_DIR/skills/$(basename "$f")" "skills/$(basename "$f")"
done

mkdir -p "$TARGET_DIR/templates/planning"
cp "$FRAMEWORK_DIR/templates/"*.md "$TARGET_DIR/templates/"
cp "$FRAMEWORK_DIR/templates/planning/"*.md "$TARGET_DIR/templates/planning/"
cp "$FRAMEWORK_DIR/templates/gitignore.template" "$TARGET_DIR/templates/gitignore.template"

mkdir -p "$TARGET_DIR/templates/project"
cp "$FRAMEWORK_DIR/templates/project/"*.md "$TARGET_DIR/templates/project/"

# Copy custom agent definitions
mkdir -p "$TARGET_DIR/.claude/agents"
if ls "$FRAMEWORK_DIR/.claude/agents/"*.md > /dev/null 2>&1; then
    for f in "$FRAMEWORK_DIR/.claude/agents/"*.md; do
        safe_copy "$f" "$TARGET_DIR/.claude/agents/$(basename "$f")" ".claude/agents/$(basename "$f")"
    done
fi

# Copy Claude dispatch script
safe_copy "$FRAMEWORK_DIR/claude-dispatch.sh" "$TARGET_DIR/claude-dispatch.sh" "claude-dispatch.sh"
chmod +x "$TARGET_DIR/claude-dispatch.sh"

# Set up .claude/rules/ with project overrides starter (never overwrite existing)
mkdir -p "$TARGET_DIR/.claude/rules"
if [ ! -f "$TARGET_DIR/.claude/rules/project-overrides.md" ]; then
    cp "$FRAMEWORK_DIR/templates/project-overrides.md" "$TARGET_DIR/.claude/rules/project-overrides.md"
fi

# Set up .gitignore
MARKER="# Agent Framework"
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -q "$MARKER" "$TARGET_DIR/.gitignore"; then
        echo "" >> "$TARGET_DIR/.gitignore"
        cat "$FRAMEWORK_DIR/templates/gitignore.template" >> "$TARGET_DIR/.gitignore"
    fi
else
    cp "$FRAMEWORK_DIR/templates/gitignore.template" "$TARGET_DIR/.gitignore"
fi

# Ensure .framework-base/ is gitignored (added separately for existing installs)
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -q "\.framework-base" "$TARGET_DIR/.gitignore"; then
        printf "\n# Agent Framework merge base (local bootstrap artifact)\n.framework-base/\n" \
            >> "$TARGET_DIR/.gitignore"
    fi
fi

# --- Phase 5: Output ---
echo ""
echo "Done! Framework installed."
echo ""
echo "Files added:"
echo "  CLAUDE.md                            Core rules (auto-loaded by Claude Code)"
echo "  AGENTS.md                            Core rules (auto-loaded by Codex CLI)"
echo "  .workflow/state.md                   Position tracker"
echo "  .gitignore                           Git ignore rules"
echo "  skills/                              Workflow commands"
echo "  templates/                           Artifact templates"
echo "  .claude/agents/                      Framework sub-agent definitions"
echo "  .claude/rules/project-overrides.md   Project-specific Claude behaviour (auto-loaded)"
echo "  claude-dispatch.sh                   Claude headless dispatch"
echo ""
echo "Commands available: /new-project, /onboard, /discuss, /research,"
echo "  /plan, /implement, /test, /close-out, /retro, /status, /issues,"
echo "  /pause, /resume, /help"
echo ""
echo "Upgrading an existing project?"
echo "  Re-run this script on your project directory to get new skill files"
echo "  and commands. The plugin is re-registered automatically."
echo ""

if [ -n "$SKIPPED_FILES" ]; then
    echo "Files skipped (local edits preserved):"
    printf '%s' "$SKIPPED_FILES"
    echo ""
    echo "  To update skipped files: migrate your edits to"
    echo "  .claude/rules/project-overrides.md, then re-run bootstrap.sh."
    echo ""
fi

if [ -n "$CONFLICTS" ]; then
    echo "Files with merge conflicts (resolve manually):"
    printf '%s' "$CONFLICTS"
    echo ""
    echo "  Each file contains conflict markers: <<<<<<<, =======, >>>>>>>"
    echo "  1. Open the file and resolve each conflict region."
    echo "  2. Remove all conflict markers."
    echo "  3. Re-run bootstrap.sh to verify the merge is clean."
    echo ""
fi

if [ -n "$STALE_FILES" ]; then
    echo "Files updated from stale base (framework applied; re-check local edits):"
    printf '%s' "$STALE_FILES"
    echo ""
    echo "  These files had a stale .framework-base/ entry AND local edits."
    echo "  The latest framework version has been applied. Review each file"
    echo "  and re-apply any project-specific additions you need."
    echo "  Going forward, migrate custom behaviour to .claude/rules/project-overrides.md"
    echo "  to avoid this situation on future upgrades."
    echo ""
fi

# Detect existing codebase
HAS_CODE=false
for pattern in "*.py" "*.js" "*.ts" "*.swift" "*.go" "*.rs" "*.java" "*.rb" "*.cpp" "*.c" "*.cs"; do
    if compgen -G "$TARGET_DIR/$pattern" > /dev/null 2>&1 || \
       compgen -G "$TARGET_DIR/**/$pattern" > /dev/null 2>&1; then
        HAS_CODE=true
        break
    fi
done

if [ -f "$TARGET_DIR/package.json" ] || \
   [ -f "$TARGET_DIR/Cargo.toml" ] || \
   [ -f "$TARGET_DIR/go.mod" ] || \
   [ -f "$TARGET_DIR/Gemfile" ] || \
   [ -f "$TARGET_DIR/requirements.txt" ] || \
   [ -f "$TARGET_DIR/Podfile" ] || \
   [ -d "$TARGET_DIR/.xcodeproj" ] || \
   compgen -G "$TARGET_DIR/*.xcodeproj" > /dev/null 2>&1; then
    HAS_CODE=true
fi

echo "Next steps:"
echo "  1. Open $TARGET_DIR in Claude Code"

if [ "$HAS_CODE" = true ]; then
    echo "  2. Type /onboard to scan your codebase and set up the workflow"
    echo ""
    echo "  Existing code detected — /onboard will scan your project and"
    echo "  generate PROJECT.md, ROADMAP.md, and README.md from what it finds."
else
    echo "  2. Type /new-project to set up PROJECT.md, ROADMAP.md, and README.md"
    echo ""
    echo "  No existing code detected — /new-project will walk you through"
    echo "  defining your project from scratch."
fi

echo ""
echo "  Type /help at any time to see available commands."

# Codex CLI integration
echo ""
if command -v codex &> /dev/null; then
    echo "Codex CLI detected ($(codex --version 2>/dev/null || echo 'unknown version'))."
    echo "To enable Codex CLI support, add this to ~/.codex/config.toml:"
    echo ""
    echo '  project_doc_fallback_filenames = ["CLAUDE.md"]'
    echo ""
    echo "This lets Codex read CLAUDE.md as a fallback alongside AGENTS.md."
else
    echo "Tip: Install Codex CLI to use it as an alternative agent backend."
    echo "See: https://openai.com/codex"
fi

# Clean up pre-pull temp snapshot
rm -rf "$PRE_PULL_TMP"

}
# --- End main() ---

# Only run main() when executed directly, not when sourced (e.g. by test
# tooling that needs safe_copy() without the full install/plugin flow).
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi

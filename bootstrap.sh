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
if [ -d "$FRAMEWORK_DIR" ]; then
    if [ -d "$FRAMEWORK_DIR/.git" ]; then
        echo "Updating framework in $FRAMEWORK_DIR..."
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

# Overwrite handling
if [ -f "$TARGET_DIR/CLAUDE.md" ] && [ -d "$TARGET_DIR/skills" ]; then
    if [ "$INTERACTIVE" = true ]; then
        echo "Warning: Framework files already exist in this directory."
        read -p "Overwrite? (y/N) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
    else
        echo "Updating existing framework files..."
    fi
fi

# Copy framework files
echo "Copying framework files..."

cp "$FRAMEWORK_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
cp "$FRAMEWORK_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"

mkdir -p "$TARGET_DIR/.workflow"
cp "$FRAMEWORK_DIR/templates/state.md" "$TARGET_DIR/.workflow/state.md"

mkdir -p "$TARGET_DIR/skills"
cp "$FRAMEWORK_DIR/skills/"*.md "$TARGET_DIR/skills/"

mkdir -p "$TARGET_DIR/templates/planning"
cp "$FRAMEWORK_DIR/templates/"*.md "$TARGET_DIR/templates/"
cp "$FRAMEWORK_DIR/templates/planning/"*.md "$TARGET_DIR/templates/planning/"
cp "$FRAMEWORK_DIR/templates/gitignore.template" "$TARGET_DIR/templates/gitignore.template"

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

# --- Phase 5: Output ---
echo ""
echo "Done! Framework installed."
echo ""
echo "Files added:"
echo "  CLAUDE.md              Core rules (auto-loaded by Claude Code)"
echo "  AGENTS.md              Core rules (auto-loaded by Codex CLI)"
echo "  .workflow/state.md     Position tracker"
echo "  .gitignore             Git ignore rules"
echo "  skills/                Workflow commands"
echo "  templates/             Artifact templates"
echo ""
echo "Commands available: /new-project, /onboard, /discuss, /research,"
echo "  /plan, /implement, /test, /close-out, /retro, /status, /issues, /help"
echo ""

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

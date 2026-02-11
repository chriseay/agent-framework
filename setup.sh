#!/bin/bash

# Agent Framework — Setup Script
# Copies the framework files into a target project directory.

set -e

# Determine source directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Determine target directory
if [ -n "$1" ]; then
    TARGET_DIR="$(cd "$1" 2>/dev/null && pwd || echo "$1")"
else
    TARGET_DIR="$(pwd)"
fi

# Safety check — don't copy into the framework repo itself
if [ "$TARGET_DIR" = "$SCRIPT_DIR" ]; then
    echo "Error: Target directory is the framework repo itself."
    echo "Usage: ./setup.sh /path/to/your/project"
    exit 1
fi

echo "Agent Framework Setup"
echo "====================="
echo ""
echo "Target: $TARGET_DIR"
echo ""

# Check if framework files already exist
if [ -f "$TARGET_DIR/CLAUDE.md" ] && [ -d "$TARGET_DIR/skills" ]; then
    echo "Warning: Framework files already exist in this directory."
    read -p "Overwrite? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Copy framework files
echo "Copying framework files..."

cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
cp "$SCRIPT_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"

mkdir -p "$TARGET_DIR/.workflow"
cp "$SCRIPT_DIR/.workflow/state.md" "$TARGET_DIR/.workflow/state.md"

mkdir -p "$TARGET_DIR/skills"
cp "$SCRIPT_DIR/skills/"*.md "$TARGET_DIR/skills/"

mkdir -p "$TARGET_DIR/templates/planning"
cp "$SCRIPT_DIR/templates/"*.md "$TARGET_DIR/templates/"
cp "$SCRIPT_DIR/templates/planning/"*.md "$TARGET_DIR/templates/planning/"
cp "$SCRIPT_DIR/templates/gitignore.template" "$TARGET_DIR/templates/gitignore.template"

# Set up .gitignore
MARKER="# Agent Framework"
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -q "$MARKER" "$TARGET_DIR/.gitignore"; then
        echo "" >> "$TARGET_DIR/.gitignore"
        cat "$SCRIPT_DIR/templates/gitignore.template" >> "$TARGET_DIR/.gitignore"
    fi
else
    cp "$SCRIPT_DIR/templates/gitignore.template" "$TARGET_DIR/.gitignore"
fi

# Detect existing codebase
echo ""
HAS_CODE=false
for pattern in "*.py" "*.js" "*.ts" "*.swift" "*.go" "*.rs" "*.java" "*.rb" "*.cpp" "*.c" "*.cs"; do
    if compgen -G "$TARGET_DIR/$pattern" > /dev/null 2>&1 || \
       compgen -G "$TARGET_DIR/**/$pattern" > /dev/null 2>&1; then
        HAS_CODE=true
        break
    fi
done

# Also check for common project indicators
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

echo "Done! Framework files installed."
echo ""
echo "Files added:"
echo "  CLAUDE.md              Core rules (auto-loaded by Claude Code)"
echo "  AGENTS.md              Core rules (auto-loaded by Codex CLI)"
echo "  .workflow/state.md     Position tracker"
echo "  .gitignore             Git ignore rules"
echo "  skills/                Workflow commands"
echo "  templates/             Artifact templates"
echo ""
echo "Next steps:"
echo "  1. Open this directory in Claude Code or Codex CLI"

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

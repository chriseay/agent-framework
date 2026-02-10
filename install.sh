#!/bin/bash

# Agent Framework — Install Script
# Registers the marketplace and installs the plugin into Claude Code.

set -e

echo "Agent Framework — Plugin Install"
echo "================================="
echo ""

# Check if claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "Error: Claude Code CLI not found."
    echo "Install it from: https://claude.ai/claude-code"
    exit 1
fi

# Add this repo as a marketplace
echo "Adding marketplace..."
claude plugin marketplace add chriseay/agent-framework 2>&1 || {
    echo "Marketplace may already be added. Continuing..."
}

echo ""

# Install the plugin
echo "Installing agent-framework plugin..."
claude plugin install agent-framework@agent-framework 2>&1

echo ""
echo "Done! Plugin installed."
echo ""
echo "Commands available: /new-project, /onboard, /discuss, /research,"
echo "  /plan, /implement, /test, /close-out, /retro, /status, /issues, /help"
echo ""
echo "Next: run ./setup.sh /path/to/your/project to copy framework files."
echo ""

# Codex CLI integration
if command -v codex &> /dev/null; then
    echo "Codex CLI detected ($(codex --version 2>/dev/null || echo 'unknown version'))."
    echo "To enable Codex CLI support, add this to ~/.codex/config.toml:"
    echo ""
    echo '  project_doc_fallback_filenames = ["CLAUDE.md"]'
    echo ""
    echo "This lets Codex read CLAUDE.md as a fallback alongside AGENTS.md."
    echo "setup.sh will copy both AGENTS.md and CLAUDE.md to your project."
else
    echo "Tip: Install Codex CLI to use it as an alternative agent backend."
    echo "See: https://openai.com/codex"
fi

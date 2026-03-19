#!/bin/bash

# Agent Framework — Claude Headless Dispatch Script
# Dispatches a task to Claude Code CLI for non-interactive execution.
# Usage: ./claude-dispatch.sh "task description" [--dir /path] [--model model-id]

set -e

# Defaults
DIR="$(pwd)"
MODEL="claude-haiku-4-5-20251001"
TASK=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            DIR="$2"
            shift 2
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        -*)
            echo "Unknown flag: $1" >&2
            echo "Usage: ./claude-dispatch.sh \"task description\" [--dir /path] [--model model-id]" >&2
            exit 1
            ;;
        *)
            if [ -z "$TASK" ]; then
                TASK="$1"
            else
                echo "Error: Multiple task descriptions provided." >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$TASK" ]; then
    echo "Error: No task description provided." >&2
    echo "Usage: ./claude-dispatch.sh \"task description\" [--dir /path] [--model model-id]" >&2
    exit 1
fi

# Check claude is installed
if ! command -v claude &> /dev/null; then
    echo "Error: Claude Code CLI not found. Install it from: https://claude.ai/claude-code" >&2
    exit 1
fi

# Build the prompt with safety preamble
PROMPT="Do NOT modify .workflow/state.md or any files in planning/. Only modify the files directly relevant to the task.

Task: $TASK"

# Dispatch via claude -p (non-interactive mode)
echo "Dispatching to Claude Code CLI..." >&2
if claude -p \
    --permission-mode bypassPermissions \
    --model "$MODEL" \
    --disable-slash-commands \
    --no-session-persistence \
    --max-turns 10 \
    --add-dir "$DIR" \
    "$PROMPT"; then
    echo "Dispatch complete." >&2
else
    EXIT_CODE=$?
    echo "Error: Claude dispatch exited with code $EXIT_CODE" >&2
    exit $EXIT_CODE
fi

#!/bin/bash

# Agent Framework — Codex Dispatch Script
# Dispatches a task to Codex CLI for non-interactive execution.
# Usage: ./codex-dispatch.sh "task description" [--dir /path] [--model model-name]

set -e

# Defaults
DIR="$(pwd)"
MODEL=""
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
            echo "Usage: ./codex-dispatch.sh \"task description\" [--dir /path] [--model model-name]" >&2
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
    echo "Usage: ./codex-dispatch.sh \"task description\" [--dir /path] [--model model-name]" >&2
    exit 1
fi

# Check codex is installed
if ! command -v codex &> /dev/null; then
    echo "Error: Codex CLI not found. Install it from: https://openai.com/codex" >&2
    exit 1
fi

# Build the prompt with safety preamble
PROMPT="IMPORTANT: Do NOT modify .workflow/state.md or any files in planning/. Only modify the files directly relevant to the task.

Task: $TASK"

# Build codex exec command
CMD=(codex exec --full-auto -C "$DIR")

if [ -n "$MODEL" ]; then
    CMD+=(-m "$MODEL")
fi

RESULT_FILE="/tmp/codex-dispatch-result-$$.md"
CMD+=(-o "$RESULT_FILE")
CMD+=("$PROMPT")

# Run codex
echo "Dispatching to Codex CLI..." >&2
if "${CMD[@]}"; then
    if [ -f "$RESULT_FILE" ]; then
        cat "$RESULT_FILE"
        rm -f "$RESULT_FILE"
    else
        echo "(No output file generated)" >&2
    fi
else
    EXIT_CODE=$?
    echo "Error: Codex exited with code $EXIT_CODE" >&2
    rm -f "$RESULT_FILE"
    exit $EXIT_CODE
fi

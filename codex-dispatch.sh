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

# Resolve a timeout command — macOS has no `timeout` by default (it's a
# GNU coreutils tool). Fall back to `gtimeout` (Homebrew coreutils), or run
# without a timeout wrapper and warn if neither is available.
TIMEOUT_CMD=""
if command -v timeout &> /dev/null; then
    TIMEOUT_CMD="timeout"
elif command -v gtimeout &> /dev/null; then
    TIMEOUT_CMD="gtimeout"
else
    echo "Warning: no 'timeout' or 'gtimeout' command found — running without a timeout." >&2
    echo "Install GNU coreutils (e.g. 'brew install coreutils') to enable the 120s timeout." >&2
fi

# Check for known-broken versions
CODEX_VERSION=$(codex --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if [ "$CODEX_VERSION" = "0.115.0" ]; then
    echo "Warning: Codex v0.115.0 has an approval-mode regression (issue #15074)." >&2
    echo "Full-auto dispatch may stall waiting for approvals." >&2
    echo "Consider upgrading: codex update" >&2
fi

# Build the prompt with safety preamble
PROMPT="Do NOT modify .workflow/state.md or any files in planning/. Only modify the files directly relevant to the task.

Task: $TASK"

# Run from /tmp to avoid loading AGENTS.md (which triggers workflow rules
# and blocks non-interactive execution). Grant write access to the project
# directory via --add-dir.
CMD=(codex exec --full-auto -C /tmp --add-dir "$DIR" --skip-git-repo-check)

if [ -n "$MODEL" ]; then
    CMD+=(-m "$MODEL")
fi

RESULT_FILE="/tmp/codex-dispatch-result-$$.md"
CMD+=(-o "$RESULT_FILE")
CMD+=("$PROMPT")

# Run codex
echo "Dispatching to Codex CLI..." >&2
if [ -n "$TIMEOUT_CMD" ]; then
    RUN_RESULT=0
    "$TIMEOUT_CMD" 120 "${CMD[@]}" || RUN_RESULT=$?
else
    RUN_RESULT=0
    "${CMD[@]}" || RUN_RESULT=$?
fi

if [ "$RUN_RESULT" -eq 0 ]; then
    if [ -f "$RESULT_FILE" ]; then
        cat "$RESULT_FILE"
        rm -f "$RESULT_FILE"
    else
        echo "(No output file generated)" >&2
    fi
else
    EXIT_CODE=$RUN_RESULT
    echo "Error: Codex exited with code $EXIT_CODE" >&2
    if [ "$EXIT_CODE" -eq 124 ] && [ -n "$TIMEOUT_CMD" ]; then
        echo "Error: Codex dispatch timed out after 120 seconds." >&2
    fi
    rm -f "$RESULT_FILE"
    exit $EXIT_CODE
fi

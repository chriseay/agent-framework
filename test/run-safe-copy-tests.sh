#!/bin/bash
# Smoke-tests bootstrap.sh's safe_copy() function against the three core
# scenarios, using synthetic fixtures — no real project is touched.
#
# Usage: test/run-safe-copy-tests.sh
# Exits non-zero if any scenario doesn't behave as expected.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_SCRIPT="$REPO_ROOT/test/fixtures/make-fixture.sh"
REL_PATH="project/example-framework-file.md"
FAILURES=0

# Source bootstrap.sh for its safe_copy() function only — main() doesn't
# run because this file is sourced, not executed (see bootstrap.sh's
# source guard).
# shellcheck source=/dev/null
source "$REPO_ROOT/bootstrap.sh"

assert() {
    local description="$1"
    local condition="$2"
    if [ "$condition" = "true" ]; then
        echo "  PASS: $description"
    else
        echo "  FAIL: $description"
        FAILURES=$((FAILURES + 1))
    fi
}

run_scenario() {
    local scenario="$1"
    echo ""
    echo "=== Scenario: $scenario ==="

    local scratch fake_framework_dir
    scratch=$(mktemp -d)
    fake_framework_dir=$(mktemp -d)
    TARGET_DIR="$scratch"
    FRAMEWORK_DIR="$fake_framework_dir"
    PRE_PULL_TMP=$(mktemp -d)
    SKIPPED_FILES=""
    CONFLICTS=""
    STALE_FILES=""

    local framework_content
    framework_content=$("$FIXTURE_SCRIPT" "$scenario" "$TARGET_DIR" "$REL_PATH")

    # $src must live under $FRAMEWORK_DIR — safe_copy() derives the
    # .framework-base/ relative path by stripping this prefix, matching how
    # bootstrap.sh's real call sites always pass paths under $FRAMEWORK_DIR.
    local src="$FRAMEWORK_DIR/$REL_PATH"
    mkdir -p "$(dirname "$src")"
    printf '%s\n' "$framework_content" > "$src"

    local dst="$TARGET_DIR/$REL_PATH"
    safe_copy "$src" "$dst" "$REL_PATH"

    case "$scenario" in
        fresh-install)
            [ -f "$dst" ] && diff -q "$src" "$dst" > /dev/null 2>&1 && result=true || result=false
            assert "dst created and matches framework content" "$result"
            [ -f "$TARGET_DIR/.framework-base/$REL_PATH" ] && result=true || result=false
            assert "base snapshot created" "$result"
            ;;
        clean-upgrade)
            diff -q "$src" "$dst" > /dev/null 2>&1 && result=true || result=false
            assert "dst silently matches framework content (no-op update)" "$result"
            [ -z "$SKIPPED_FILES" ] && [ -z "$CONFLICTS" ] && [ -z "$STALE_FILES" ] && result=true || result=false
            assert "no skip/conflict/stale entries recorded" "$result"
            ;;
        collision-upgrade)
            grep -q "pre-existing project content" "$dst" && result=true || result=false
            assert "dst NOT overwritten — pre-existing content preserved" "$result"
            [ -n "$SKIPPED_FILES" ] && result=true || result=false
            assert "collision recorded in SKIPPED_FILES" "$result"
            [ -f "$TARGET_DIR/.framework-base/$REL_PATH" ] && result=true || result=false
            assert "base snapshot created from dst (for future merges)" "$result"
            ;;
    esac

    rm -rf "$scratch" "$fake_framework_dir" "$PRE_PULL_TMP"
}

run_scenario fresh-install
run_scenario clean-upgrade
run_scenario collision-upgrade

echo ""
if [ "$FAILURES" -eq 0 ]; then
    echo "All safe_copy() scenario checks passed."
    exit 0
else
    echo "$FAILURES check(s) failed."
    exit 1
fi

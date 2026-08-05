#!/bin/bash
# Generates a synthetic project directory reproducing one of safe_copy()'s
# three core scenarios, for testing bootstrap.sh's merge logic without
# touching any real project.
#
# Usage: make-fixture.sh <scenario> <target-dir> <relative-file-path>
#
# Scenarios (map directly to safe_copy()'s internal cases in bootstrap.sh):
#   fresh-install      - no existing file at all (safe_copy Case 1)
#   clean-upgrade      - file + .framework-base/ both already match the
#                        framework's current content, no local edits
#                        (safe_copy Case 2 — silent no-op update)
#   collision-upgrade  - a real project file exists at this path, but no
#                        .framework-base/ entry exists yet — the framework
#                        is shipping a file of this name for the first time
#                        (safe_copy Case 4 — must not silently overwrite)
#
# Any relative-file-path works — this isn't hardcoded to any one framework
# file, so it can test collisions for future additions the same way.

set -euo pipefail

SCENARIO="${1:?Usage: make-fixture.sh <scenario> <target-dir> <relative-file-path>}"
TARGET_DIR="${2:?Usage: make-fixture.sh <scenario> <target-dir> <relative-file-path>}"
REL_PATH="${3:?Usage: make-fixture.sh <scenario> <target-dir> <relative-file-path>}"

FRAMEWORK_CONTENT="fixture: current framework content for ${REL_PATH}"
EXISTING_CONTENT="fixture: pre-existing project content for ${REL_PATH} (never touched by framework)"

mkdir -p "$TARGET_DIR"
mkdir -p "$(dirname "$TARGET_DIR/$REL_PATH")"

case "$SCENARIO" in
    fresh-install)
        # No file, no base — safe_copy Case 1 fires.
        rm -f "$TARGET_DIR/$REL_PATH"
        rm -f "$TARGET_DIR/.framework-base/$REL_PATH"
        ;;
    clean-upgrade)
        # File and base both already equal the framework's current content.
        mkdir -p "$(dirname "$TARGET_DIR/.framework-base/$REL_PATH")"
        printf '%s\n' "$FRAMEWORK_CONTENT" > "$TARGET_DIR/$REL_PATH"
        printf '%s\n' "$FRAMEWORK_CONTENT" > "$TARGET_DIR/.framework-base/$REL_PATH"
        ;;
    collision-upgrade)
        # Real project content exists; framework has never shipped this
        # file before, so no .framework-base/ entry exists.
        printf '%s\n' "$EXISTING_CONTENT" > "$TARGET_DIR/$REL_PATH"
        rm -f "$TARGET_DIR/.framework-base/$REL_PATH"
        ;;
    *)
        echo "Unknown scenario: $SCENARIO" >&2
        echo "Valid scenarios: fresh-install, clean-upgrade, collision-upgrade" >&2
        exit 1
        ;;
esac

echo "$FRAMEWORK_CONTENT"

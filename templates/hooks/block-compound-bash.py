#!/usr/bin/env python3
"""PreToolUse hook (Bash): block obviously compound/chained shell commands
before they reach a permission prompt.

Origin: project/bash-permission-rules.md documents that Claude Code's Bash
permission checker matches whole command patterns, so any compound/chained
command (semicolon-separated statements, &&-chained sequences, sed/awk piped
into another command, heredocs, find -exec) always triggers a manual
confirmation dialog regardless of whether each individual piece is
allowlisted. That rule was documented and restated many times across this
project's history and kept recurring anyway. This hook converts it from a
prose rule into enforcement: it blocks the tool call outright, before the
user ever sees a prompt, so the agent self-corrects.

Best-effort by design: quote-stripping is heuristic, not a full shell
parser. False negatives are acceptable (Claude Code's own permission system
is the backstop); false positives on legitimate quoted content (a semicolon
inside a commit message, a URL query string) are the thing to avoid.
"""
import json
import re
import sys


def strip_quotes(s: str) -> str:
    """Replace the contents of single/double-quoted spans with spaces,
    so punctuation inside a quoted string (e.g. a commit message) doesn't
    trigger a false positive."""
    out = []
    i, n = 0, len(s)
    while i < n:
        c = s[i]
        if c in ("'", '"'):
            quote = c
            i += 1
            while i < n and s[i] != quote:
                if quote == '"' and s[i] == "\\" and i + 1 < n:
                    i += 2
                    continue
                i += 1
            i += 1  # skip closing quote
            out.append(" ")
        else:
            out.append(c)
            i += 1
    return "".join(out)


def find_reasons(command: str) -> list[str]:
    stripped = strip_quotes(command)
    reasons = []
    if ";" in stripped:
        reasons.append("contains a `;` statement separator")
    if "&&" in stripped:
        reasons.append("contains a `&&` chain")
    if "<<" in stripped:
        reasons.append("contains a heredoc (`<<`)")
    if re.search(r"-exec\b", stripped):
        reasons.append("contains `find -exec`")
    if re.search(r"\|\s*sed\b", stripped):
        reasons.append("pipes into `sed`")
    if re.search(r"\|\s*awk\b", stripped):
        reasons.append("pipes into `awk`")
    return reasons


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)  # fail open — never block on a parse error

    command = data.get("tool_input", {}).get("command", "")
    if not command:
        sys.exit(0)

    reasons = find_reasons(command)
    if not reasons:
        sys.exit(0)

    reason_text = (
        "Blocked: compound/chained Bash command (" + "; ".join(reasons) + "). "
        "Split this into separate single, simple Bash calls instead of chaining "
        "them — see project/bash-permission-rules.md. If this is a false "
        "positive (punctuation only inside a quoted string), rephrase the "
        "quoting or run the pieces separately."
    )
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason_text,
        }
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()

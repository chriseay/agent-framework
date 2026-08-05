<!-- FRAMEWORK-OWNED FILE — maintained by Agent Framework, not the project. Unlike other project/ subdocuments, this one is authored and updated upstream; local edits will be treated as customizations by safe_copy's diff/3-way-merge logic on future bootstrap.sh runs, same as any other framework file. -->

# Bash Permission-Prompt Rules

Claude Code's Bash permission checker matches **whole command patterns** against an allowlist. A command that isn't a single, simple, already-allowlisted shape triggers a manual confirmation dialog — regardless of whether every individual piece of it (`grep`, `curl`, `python3`, ...) would be allowed on its own. The fix is almost always the same: decompose into individual, simple, literal commands instead of combining logic into one clever invocation.

This applies to the main session and every dispatched subagent equally.

## Universal rules

**Always double-quote file paths, never backslash-escape spaces** (e.g. `"My Project"` not `My\ Project`). If the repo root or any path you touch contains a space, Claude Code's Bash permission checker forces a manual confirmation on any command using escaped whitespace instead of quotes — regardless of allowlist settings.

**Don't prefix a command with `cd "<repo root>" &&` if the working directory is already correct.** The Bash tool's working directory persists between calls within a session — once you've `cd`'d into a directory (or if a command has already run there with no explicit `cd` at all), later commands don't need it repeated. A redundant `cd ... && ...` combined with any output redirection (`2>/dev/null`, `> file`, etc.) trips a separate, specific Claude Code security check ("cd with output redirection — manual approval required to prevent path resolution bypass") regardless of allowlist settings, even though the individual pieces are otherwise harmless. Only `cd` when the directory has actually changed or is genuinely uncertain.

## Named instances of the root principle

Five concrete patterns that all trace back to the same cause — the permission checker evaluates a command's whole leading pattern, and combining pieces defeats any single safe-prefix rule even when each piece is individually allowed.

### Compound multi-statement blocks

No `TOKEN=... ; URL=... ; RESULT=$(...) ; if [ ... ]; then ... fi` blocks, no `while`/`sleep` polling loops with inline `python3 -c` JSON parsing. A block that opens with variable assignments and control-flow doesn't match any single safe-prefix rule, so it always triggers a manual confirmation even when every individual piece is separately allowed. Run each step as its own single, simple Bash invocation and interpret the plain-text output yourself — don't wrap it in shell logic.

### Shell-variable token extraction

No `TOKEN=$(grep ...)` followed by later commands referencing `$TOKEN`. Bash tool calls don't persist shell state between invocations, so a variable-assignment step would have to repeat in every single command, turning each check into a compound multi-statement block (see above) that triggers a manual permission prompt even though the underlying command (`curl`, etc.) is separately allowlisted. Substitute literal values (read once via the `Read` tool, or from a project reference doc) directly into each command instead of deriving them via a shell variable.

### Helper scripts

No `cat > file << EOF` heredocs, no `chmod +x`, no `bash <script>`. A dynamically-written script's contents are invisible to the permission system and can never be pre-approved — write + chmod + execute is three separate prompts, even when the exact same check is achievable with a plain, already-allowlisted command like `grep`.

### `find -exec`

No `find . -name "*.yaml" -exec wc -l {} \;`. `-exec` runs an arbitrary command per matched file and can never be auto-allowed by any `find` prefix rule, regardless of how harmless the exec'd command is. Enumerate files with plain `ls` first, then run the actual check (e.g. `wc -l "<FILE>"`) as a separate, individual command per file — more tool calls, but each one is a plain command that's already safely allowlisted.

### `sed` — any use, not just `-i`

The permission checker flags `sed` itself as requiring approval — it doesn't distinguish `-n` (read-only print) from `-i` (in-place edit). A single plain `sed -n '10,20p' file` may slip through, but the moment it's piped with anything else (`sed ... | grep ...`, `grep ... | sed -n '1p;$p'`), it becomes a compound command and reliably triggers a manual prompt, even though every stage is individually read-only.

**For editing a script you already wrote** (adjusting a constant, widening a threshold, fixing a selector): use the `Edit` tool instead of `sed -i`. It's a single targeted change, doesn't chain into a compound `cd ... && sed ... && grep ...` command, and won't trigger a manual permission prompt. If the change is large enough that `Edit` feels awkward, rewrite the whole script fresh with `Write` rather than patching it in the shell.

**For read-only log/file extraction** (the more common case in diagnostics agents): avoid `sed` entirely, even `-n`. Use `grep -A<N> -B<N>` for context around a match, `grep -o` for extraction, `head`/`tail` for line ranges, or the `Read` tool's `offset`/`limit` parameters (no permission prompt at all — `Read` never prompts). Reserve `sed` for cases genuinely uncovered by those, and keep it as a single un-piped invocation if so.

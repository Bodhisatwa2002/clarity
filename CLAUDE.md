# CLAUDE.md — Clarity

All project rules live in **AGENTS.md** (shared by every coding agent) and are
imported here so Claude Code and other tools follow exactly the same rules.
Edit AGENTS.md, not this file, when a rule changes.

@AGENTS.md

## Claude Code specifics

- Prefix shell commands with `export PATH="/opt/homebrew/bin:$PATH" &&` — each
  Bash call starts a fresh shell.
- Before the first edit in a task, check `git branch --show-current`. If it's
  `main`, create a `<type>/<kebab-name>` branch first (AGENTS.md §7).
- Commit only when the user asks; use Conventional Commit messages. Don't push
  or open PRs without explicit approval.
- Don't run `git stash`, `git reset --hard` or `git checkout -- .` on the user's
  working tree to set up experiments — test hooks and scripts in a copy in the
  scratchpad directory.
- For long product questions, read `docs/feature-brief.pdf` with the Read tool's `pages` parameter.

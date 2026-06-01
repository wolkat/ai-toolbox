---
description: Scan all repos under the configured root for unfinished work (uncommitted, stashed, code TODOs, stale branches, backlog files, unchecked checkboxes, status-tracked plans) and emit a grouped markdown report.
---

# /todo - List unfinished work across repos

Inventory every repo under the configured scan root for things that are
unfinished, left off, or pending review. Output is a single grouped markdown
report.

## Quick Start

The command delegates to a bash script:

```bash
todo-scan
```

With no arguments it scans `$HOME/git/projects` and `$HOME/.github` (depth 3),
using a 90-day stale-branch threshold.

## Output

Seven sections, each rendered as a markdown table (or `(empty across all
repos)` if nothing matched):

1. **Uncommitted git state** - modified, added, untracked, conflicted
2. **Stashed work** - count + age of oldest stash
3. **Code TODOs / FIXMEs** - TODO/FIXME/XXX/HACK markers in source files
4. **Stale branches (>Nd)** - branches with no commits in N days, default excluded
5. **Backlog files detected** - CHECKLIST/TODO/PLAN/BACKLOG/ROADMAP/STATUS.md
6. **Unchecked checkboxes** - `- [ ]` lines inside backlog files only
7. **Status-tracked plans** - markdown tables with `Status` column (planned/created)

## Flags

| Flag | Purpose | Default |
|---|---|---|
| `--root <path>` | Scan root directory | `~/git` |
| `--include-dir <list>` | Comma-separated subdirs of ROOT to scan | `projects,.github` |
| `--repo <name>` | Limit to specific repo(s) | all |
| `--source <n>` | Run only source N (1-7) | all |
| `--stale <days>` | Stale-branch threshold | 90 |
| `--max-depth <n>` | Repo discovery depth below each include-dir | 3 |
| `--write <path>` | Write report to file | stdout |
| `--quiet` | Suppress progress on stderr | off |

## Common Patterns

```bash
# Full report for all projects
todo-scan

# Just the uncommitted state
todo-scan --source 1

# Tighter stale threshold, save to docs/
todo-scan --stale 30 --write docs/todo-$(date +%Y-%m-%d).md

# Focus on one repo
todo-scan --repo lifebinder

# Only check checkboxes and status-tracked plans (no git noise)
todo-scan --source 6,7
```

## Interpreting the Report

- **Empty uncommitted + full checkboxes**: the project is clean but has
  planned work. Triage by reading the backlog.
- **Stale branches**: candidates for deletion after review.
- **Status-tracked plans**: filter by `Status` column = `planned` or `created`.
  Items in `validated`/`fixed`/`done` are excluded automatically.
- **Code TODOs**: includes matches in comments and string literals. Treat as
  candidates, not authoritative.

## Your Task

1. Run `todo-scan` (with flags if the user asked for specifics)
2. Present the report
3. If the user asks for interpretation, group by repo and surface the
   highest-signal section (usually backlog files + status-tracked plans)
4. Offer to open specific files or take action on a subset

## Key Questions for User

If the scope is unclear, ask:

1. "All repos or one in particular?"
2. "Save to a file, or display here?"
3. "Any specific data source you want to focus on?"

## Dependencies

- `todo-scan` must be on `$PATH` (symlinked at `~/.local/bin/todo-scan` to
  `projects/ai-toolbox/scripts/todo-scan.sh`).
- `git` 2.x for `status --porcelain`, `stash list`, `for-each-ref`.
- `find` (BSD or GNU) for repo discovery and file scanning.
- `grep` with `-E` for regex matching.
- `awk` for table rendering.
- macOS bash 3.2 compatibility: no `mapfile`, no `${var,,}`, no associative
  arrays. Use `tr '[:upper:]' '[:lower:]'` for case folding.

## Notes

- The scan is read-only; it never modifies files or git state.
- Exits 0 always; per-repo errors are logged on stderr but do not abort.
- Backlog file detection is path-aware to avoid noise: `_bmad-output/`,
  `docs/`, `docs/learnings/`. PR templates and standards docs are excluded
  from the checkbox count.
- Stale-branch detection excludes the configured default branches
  (`main`, `master`, `develop`, `trunk`) and the repo's current HEAD.

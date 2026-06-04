---
description: Scan workspace repos for unfinished work, stale branches, uncommitted changes, and audit cross-repo state.
agent: cross-repo-coordinator
---

# /audit — Cross-Repo Workspace Audit

Scan, audit, and synchronize state across workspace repositories.

## Quick Start

```bash
/audit                                        # Full workspace audit
/audit --focus uncommitted                     # Focus on uncommitted changes
/audit --focus stale-branches                  # Focus on stale branches
/audit --focus todos                           # Focus on TODO/FIXME markers
/audit --repo lifebinder                       # Audit a specific repo
/audit --retro                                 # Run a retrospective analysis
```

## Your Task

1. **Invoke the `cross-repo-coordinator` agent** to load the full behavioral rules
2. **Read `dirmap.yml` or `AGENTS.md`** first for workspace structure
3. **Scan repos** for unfinished work (TODOs, unchecked items, stale branches)
4. **Audit git state** (uncommitted changes, dirty trees, stash inventory)
5. **Cross-reference findings** with supermemory for known patterns
6. **Output a grouped markdown report** organized by repository
7. **For retro sessions**: extract session patterns, apply 5 Whys, write corrective actions

## Todo Scanning

This command includes todo scanning as part of its audit. For focused todo scanning, use `/todo` instead.

- TODO/FIXME/HACK markers in source files
- Unchecked checkboxes in backlog files
- Stale branches (no commits in 30+ days)
- Uncommitted changes

## Key Rules

- Always read dirmap.yml or AGENTS.md first
- `git -C <path> rev-parse` must succeed before any write
- Consult supermemory before web fetch
- Output grouped markdown to stdout — never write files (read-only agent)
- Never spawn sub-agents
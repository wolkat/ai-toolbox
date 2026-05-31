# Permissions

## Edit Mode

```json
"edit": "ask"
```

File edits always require approval.

## Bash Allowlist

Auto-approved commands (no prompt):

| Category | Commands |
|----------|----------|
| Version control | `git *` (all git commands) |
| Package mgmt | `npm *` |
| File ops | `mkdir *`, `cp *`, `mv *`, `stow *`, `ls *` |
| Read-only | `file`, `readlink`, `head`, `tail`, `test`, `which`, `curl -sI` |
| Git recovery | `git rebase --continue`, `--abort`, `--skip` |

Fallthrough: `"*": "ask"` — everything else prompts.

## Adding new patterns

When expanding the allowlist, keep new entries read-only or idempotent.
Destructive operations (delete, overwrite) should always require approval.

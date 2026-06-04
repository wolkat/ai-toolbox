---
description: Install, validate, debug, or cleanup OpenCode plugins, skills, and agents.
agent: infra-maintainer
---

# /infra — OpenCode Infrastructure Management

Manage the lifecycle of OpenCode plugins, skills, and agents.

## Quick Start

```bash
/infra                                        # Interactive: choose what to manage
/infra install opencode-notify                # Install a plugin
/infra validate                               # Validate current configuration
/infra debug plugin-load-failure              # Debug a load failure
/infra cleanup                                # Clean up orphaned state
/infra audit skill my-skill                   # Audit a specific skill
```

## Your Task

1. **Invoke the `infra-maintainer` agent** to load the full behavioral rules
2. **Run plugin-audit or skill-audit** before any install to check for conflicts
3. **Verify compiled `.js` entry points exist** — never reference `.ts` source files
4. **If debugging**: check `~/.local/share/opencode/log/` for error details
5. **Validate JSON** after modifying `opencode.json`
6. **Clean up orphaned state** (stale symlinks, broken entries)
7. **Report results** and any follow-up steps (e.g., "restart opencode")

## Key Rules

- Never use symlinks for skills — use copies
- Always audit before installing
- Check logs on any load failure
- Define acceptance criteria before cleanup tasks
- Validate JSON after any opencode.json change
- Never spawn sub-agents
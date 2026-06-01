---
description: Create or modify OpenCode agent definitions based on session archetype patterns. Reads docs/learnings/ for pattern data, validates against opencode.json schema, and proposes agents with minimal permissions.
---

# /agent-forge — Create Agent Definitions

Create or modify OpenCode agent definitions based on session usage patterns
and archetype analysis.

## Quick Start

```bash
/agent-forge                    # Interactive: pick an archetype to create
/agent-forge review             # Create the review archetype directly
/agent-forge scaffold           # Create the scaffold archetype directly
/agent-forge infra-maintainer   # Create the infra-maintainer archetype directly
/agent-forge cross-repo-coordinator  # Create the coordinator archetype directly
/agent-forge tool-builder       # Create the tool-builder archetype directly
/agent-forge list               # List existing agents in opencode.json
/agent-forge validate           # Validate all agent definitions in opencode.json
```

## Available Archetypes

Five archetypes identified from 235 session analysis (June 2026):

| Archetype | Purpose | Key Permission | Edit |
|-----------|---------|----------------|------|
| `infra-maintainer` | Plugin/skill lifecycle management | full | allow |
| `review` | Adversarial code review, read-only on source | minimal | **deny** |
| `scaffold` | Feature scaffolding following conventions | full | allow |
| `cross-repo-coordinator` | Cross-repo scanning, read-heavy audit | minimal | **deny** |
| `tool-builder` | CLI/script development | full | allow |

## Your Task

1. **Invoke the `agent-forge` skill** to load the full workflow
2. **Read the pattern analysis** at `projects/ai-toolbox/docs/learnings/session-pattern-analysis-2026-06.md`
3. **Read current agents** from `~/.config/opencode/opencode.json`
4. **If an archetype name is provided**: propose that specific agent
5. **If no argument**: list the 5 archetypes and ask which to create
6. **After user confirmation**: write the agent entry to `opencode.json`
7. **Remind user**: restart OpenCode for changes to take effect

## Validation Checklist

Before writing any agent:

- [ ] No duplicate agent name exists in `opencode.json`
- [ ] Description is under 200 characters
- [ ] `mode: "subagent"` is set
- [ ] `task: "deny"` is set (prevent uncontrolled subagent spawning)
- [ ] Permissions are minimal: deny by default, allow only what's needed
- [ ] JSON is valid after modification (run `python3 -c "import json..."`)
- [ ] User has confirmed the proposed definition

## Key Principles

- **Deny by default**: Each agent gets only the permissions it needs
- **No subagent spawning**: `task: "deny"` prevents 12h+ timeout failures
- **Read local only**: `webfetch: "deny"` and `websearch: "deny"` — patterns come from local docs
- **One agent at a time**: Confirm each agent before writing; never batch-write all 5
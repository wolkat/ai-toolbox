---
description: Create or modify OpenCode agent definitions based on session archetype patterns.
agent: agent-forge
---

# /forge — Create Agent Definitions

Create or modify OpenCode agent definitions based on session usage patterns and archetype analysis.

## Quick Start

```bash
/forge                                         # Interactive: pick an archetype to create
/forge review                                  # Create the review archetype directly
/forge scaffold                                # Create the scaffold archetype
/forge infra-maintainer                        # Create the infra-maintainer archetype
/forge cross-repo-coordinator                  # Create the coordinator archetype
/forge tool-builder                             # Create the tool-builder archetype
/forge list                                    # List existing agents in opencode.json
/forge validate                                # Validate all agent definitions
```

## Available Archetypes

| Archetype | Purpose | Key Permission | Edit |
|-----------|---------|----------------|------|
| `infra-maintainer` | Plugin/skill lifecycle management | full | allow |
| `review` | Adversarial code review, read-only on source | minimal | **deny** |
| `scaffold` | Feature scaffolding following conventions | full | allow |
| `cross-repo-coordinator` | Cross-repo scanning, read-heavy audit | minimal | **deny** |
| `tool-builder` | CLI/script development | full | allow |

## Your Task

1. **Invoke the `agent-forge`** skill to load the full workflow
2. **Read the pattern analysis** at `projects/ai-toolbox/docs/learnings/session-pattern-analysis-2026-06.md`
3. **Read current agents** from `~/.config/opencode/opencode.json`
4. **If an archetype name is provided**: propose that specific agent
5. **If no argument**: list the 5 archetypes and ask which to create
6. **After user confirmation**: write the agent entry to `opencode.json` and create the `.md` prompt file
7. **Validate JSON** after modification
8. **Remind user**: restart OpenCode for changes to take effect

## Validation Checklist

Before writing any agent:

- [ ] No duplicate agent name exists in `opencode.json`
- [ ] Description is under 200 characters
- [ ] `mode: "subagent"` is set
- [ ] `task: "deny"` is set (prevent uncontrolled subagent spawning)
- [ ] Permissions are minimal: deny by default, allow only what's needed
- [ ] JSON is valid after modification
- [ ] User has confirmed the proposed definition

## Key Principles

- Deny by default — each agent gets only the permissions it needs
- No subagent spawning — `task: "deny"` prevents 12h+ timeout failures
- Read local only — `webfetch: "deny"` and `websearch: "deny"`
- One agent at a time — confirm each agent before writing
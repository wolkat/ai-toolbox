# Agents & Skills

## Agent Configuration

```json
"agent": {
  "review":   { "mode": "subagent" },
  "refactor": { "mode": "subagent" },
  "explore":  { "disable": true },
  "general":  { "disable": true }
}
```

- Two active subagents: `review` (code review), `refactor` (refactoring).
- `explore` and `general` disabled.
- `oh-my-openagent` plugin provides the agent orchestration layer.

## Skills & Commands

| Directory | Purpose |
|-----------|---------|
| `~/.config/opencode/skills/` | Skill definitions (SKILL.md + README.md) |
| `~/.config/opencode/command/` | Slash command definitions (`.md`) |

Current skills: `clonedeps`, `codemap`, `plugin-audit`, `simplify`,
`skill-audit`, `exa-search`.

Skill format convention:

```markdown
---
name: <name>
description: <under 40 words>
---

## When to Use
...

## Workflow
...

## Best Practices
...
```

The `opencode-skill-hush` plugin suppresses verbose skill output and command
template display in the TUI. It is path-based, compiled to `dist/index.js`.

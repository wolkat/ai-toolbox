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

Current skills in `~/.config/opencode/skills/`:

- Real dirs: `clonedeps`, `codemap`, `simplify`, `exa-search`
- Symlinks to `ai-toolbox/opencode/skills/`: `plugin-audit`, `retro`, `skill-audit`

BMAD/GDS/WDS skills live at `~/.agents-disabled/skills/` (renamed from
`~/.agents/skills/` to hide them from the TUI `/` picker). See
[Hiding Skills from the `/` Picker](#hiding-skills-from-the--picker).

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

## Skill Discovery Paths

OpenCode discovers `SKILL.md` files in:

| Scope | Paths |
|-------|-------|
| Project | `.opencode/skills/`, `.claude/skills/`, `.agents/skills/` |
| Global  | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` |

Project paths walk up from cwd to the git worktree. `SKILL.md` requires YAML
frontmatter with `name` (matches dir, lowercase, 1-64 chars) and `description`
(1-1024 chars). Unknown frontmatter fields are ignored.

## Hiding Skills from the `/` Picker

`permission.skill.deny` in `opencode.json` hides skills from the agent's
`<available_skills>` tool description (LLM cannot load them), but the TUI `/`
slash-command picker reads skills from disk and lists them regardless of
permissions.

To actually hide a skill group from the `/` picker, move/rename its discovery
path directory. Example: BMAD/GDS/WDS skills (117 entries) were hidden by
renaming `~/.agents/` → `~/.agents-disabled/`. Restore with
`mv ~/.agents-disabled ~/.agents`, then restart the session.

Alternatives:

- Per-agent `tools.skill: false` in `opencode.json` (hides ALL skills, not a subset).
- Per-skill `permission.skill.<name>: "deny"` (hides from agent only, not picker).

# Agents & Skills

## Agent Configuration

Active agents in `opencode.json`:

| Agent | Mode | Purpose | Edit | Key Restriction |
|-------|------|---------|------|-----------------|
| `review` | subagent | Adversarial code review, read-only on source | deny | task: deny |
| `refactor` | subagent | Code refactoring | allow | - |
| `todo` | subagent | Scan repos for unfinished work | deny | question: deny |
| `agent-forge` | subagent | Create agent definitions from patterns | allow | task: deny |
| `infra-maintainer` | subagent | Plugin/skill/agent lifecycle management | allow | task: deny |
| `scaffold` | subagent | Feature scaffolding following conventions | allow | task: deny |
| `cross-repo-coordinator` | subagent | Cross-repo audit & hygiene | deny | write: deny, task: deny |
| `tool-builder` | subagent | CLI/script development | allow | task: deny |

Disabled: `explore`, `general`.

`oh-my-openagent` plugin provides the orchestration layer (Sisyphus, Oracle, Librarian, etc.).

### Archetype Agents (June 2026)

Five archetype agents derived from session pattern analysis (235 sessions).
Each has minimal permissions — deny by default, allow only what's needed.

**`infra-maintainer`** — Plugin/skill install-validate-debug-cleanup cycle.
Top pain point: .ts vs compiled .js path resolution. Never symlinks skills.

**`review`** — Adversarial code review. Findings go to `docs/learnings/`, never to source.
For codebases <2000 LOC, prefer direct file reads over sub-agents.

**`scaffold`** — Reads 3+ neighboring files before writing any new file.
Mimics existing patterns, updates plan checkboxes after completion.

**`cross-repo-coordinator`** — Read-heavy scanner/auditor. No write permissions.
Outputs grouped markdown to stdout. Uses `git -C <path> rev-parse` before any git op.

**`tool-builder`** — Scripts must have -h/--help, target bash 3.2, be non-interactive.
Stores outputs in `docs/learnings/`, never in XDG or ~/git root.

**`agent-forge`** — Creates agent definitions by reading session patterns from
`docs/learnings/`, validates against opencode.json schema, and proposes agents
with minimal permissions. Invoked via `/agent-forge`.

See [Session Pattern Analysis](../learnings/session-pattern-analysis-2026-06.md) for full data.

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

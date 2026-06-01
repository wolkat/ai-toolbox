---
name: agent-forge
description: Creates OpenCode agent definitions and skill configs. Reads session patterns from docs/learnings/, analyzes opencode.json schema, and proposes/writes new agent entries with minimal permissions.
---

# Agent Forge Skill

Creates OpenCode agent definitions by reading archetype patterns from session analysis documents and writing validated entries into `opencode.json`.

## When to Use

- User requests a new agent ("create an agent for X", "add a review agent", "I need a scaffolding agent")
- User invokes `/agent-forge` command
- User asks to implement one of the archetype agents from the session pattern analysis
- User wants to review or modify existing agent configurations

## Workflow

### Step 1: Read Archetype Patterns

Read the session pattern analysis file at:
```
projects/ai-toolbox/docs/learnings/session-pattern-analysis-2026-06.md
```

This file contains 5 archetype definitions with:
- Task archetype name and description
- Common actions ordered by frequency
- Recurring pain points
- Required skills/tools
- Proposed agent config (JSON)

### Step 2: Identify Which Archetype

Match the user's request to one of the 5 archetypes:

| Archetype | Matches |
|-----------|---------|
| `infra-maintainer` | Plugin install/debug, skill cleanup, agent registration, path fixes |
| `review` | Code review, adversarial testing, blind/edge-case hunting, multi-model verification |
| `scaffold` | Creating new files/components/routes following patterns, code generation |
| `cross-repo-coordinator` | Scanning repos for todos, git status audits, retro/learnings, cross-project sync |
| `tool-builder` | CLI scripts, shell config, key management, --help flags, bash compatibility |

### Step 3: Validate Against OpenCode Schema

Read `~/.config/opencode/opencode.json` to understand the current agent configuration.

**Valid agent names:** any string matching `[a-z][a-z0-9-]*` (lowercase, hyphens allowed).

**Required fields per agent:**
- `description`: string, under 200 chars
- `mode`: `"subagent"` (all agent-forge agents are subagents)

**Optional fields:**
- `permission`: object with keys from `read`, `glob`, `grep`, `bash`, `edit`, `write`, `question`, `todowrite`, `task`, `webfetch`, `websearch`, `memory`
  - Values: `"allow"`, `"deny"`, or a bash allowlist pattern
- `model`: object with `id` and `providerID`

### Step 4: Check for Conflicts

Before writing, verify:
1. No agent with the same name already exists in `opencode.json`
2. The permission set is minimal (deny by default, allow only what's needed)
3. `task: "deny"` is set unless the user explicitly requests subagent spawning
4. Description is clear and under 200 chars

### Step 5: Propose the Agent

Present the proposed agent definition to the user with:

```
## Proposed Agent: <name>

**Description:** <description>
**Mode:** subagent

**Permissions:**
| Permission | Value | Rationale |
|------------|-------|-----------|
| read       | allow | Read source files |
| ...        | ...   | ...      |

**Rules:**
1. <rule from archetype>
2. <rule from archetype>

**Skills:** <comma-separated list from archetype>

Confirm? (y/n)
```

### Step 6: Write to opencode.json

After user confirmation:
1. Read the current `opencode.json`
2. Add the new agent entry under the `agent` key
3. Write the updated file
4. Inform the user to restart OpenCode for changes to take effect
5. Optionally create a corresponding skill directory if skills are referenced

### Step 7: Create Skill Directory (if needed)

If the archetype references skills that don't exist yet, offer to create minimal skill scaffolds:

```
projects/ai-toolbox/opencode/skills/<skill-name>/SKILL.md
```

Each SKILL.md should follow the format:
```markdown
---
name: <skill-name>
description: <under 40 words>
---

# <Skill Name>

## When to Use
...

## Workflow
...
```

## Permission Design Principles

1. **Deny by default**: Only allow what the agent actually needs
2. **task: deny**: Prevents uncontrolled subagent spawning (top pain point)
3. **webfetch/websearch: deny**: Agent-forge reads local files only
4. **edit: deny for review agents**: Review findings go to reports, not source
5. **write: deny for scanner agents**: Cross-repo-coordinator outputs to stdout
6. **bash: allow**: Needed for git operations, sqlite3 queries, linting

## Archetype Permission Matrix

| Archetype | read | glob | grep | bash | edit | write | question | todowrite | task | memory |
|-----------|------|------|------|------|------|-------|----------|-----------|------|--------|
| infra-maintainer | allow | allow | allow | allow | allow | allow | allow | allow | deny | - |
| review | allow | allow | allow | allow | deny | allow | allow | allow | deny | allow |
| scaffold | allow | allow | allow | allow | allow | allow | allow | allow | deny | - |
| cross-repo-coordinator | allow | allow | allow | allow | deny | deny | allow | allow | deny | - |
| tool-builder | allow | allow | allow | allow | allow | allow | allow | allow | deny | - |

## Best Practices

- Always read `opencode.json` before modifying it — never assume its current state
- Preserve existing agent entries; only add new ones or modify confirmed changes
- Test the JSON is valid before writing (use `python3 -c "import json; json.load(open(path))"`)
- Group related permission changes together
- Document the rationale for each permission choice
- For retro/analysis agents, point them at `~/.local/share/opencode/opencode.db` for session data
- For scanner agents, use `git -C <path> rev-parse` to verify repo boundaries before any git operation
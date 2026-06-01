# Skill Standards

Quality criteria for AI-toolbox skills, commands, and plugins.

## Why Standards Exist

- **Consistency** — AI agents know what to expect
- **Discoverability** — Users can quickly understand capabilities
- **Maintainability** — Clear structure makes updates easier
- **Agent usability** — Frontmatter descriptions drive skill selection

---

## YAML Frontmatter Rules

### Required Fields

| Field | Format | Constraints |
|-------|--------|-------------|
| `name` | kebab-case | Must match directory name exactly |
| `description` | sentence case | Max 40 words. Purpose + trigger only |

### Description Quality

**Bad** — embeds workflow, too long:
```yaml
description: Cross-check new OpenCode plugins against existing configuration before installation. Analyze hooks, commands, model interactions, and present risks, overlaps, conflicts, and benefits. Wait for user confirmation before proceeding with installation and post-install steps.
# 58 words — includes implementation details
```

**Good** — concise, purpose + trigger:
```yaml
description: Analyze new OpenCode plugins for conflicts with existing configuration before installation. Triggers when user requests plugin install or compatibility check.
# 24 words — clear and scannable
```

### Prohibited in Description
- Implementation steps ("Step 1: read config...")
- Behavioral instructions ("Wait for user confirmation...")
- Detailed lists of what it checks
- Length > 40 words

---

## SKILL.md Structure (Agent-Facing)

Required sections in order:

```markdown
---
name: skill-name
description: Concise purpose and trigger condition.
---

# Title

## When to Use
- Trigger condition 1
- Trigger condition 2

## Workflow
### Step 1: ...
### Step 2: ...

## Best Practices
1. ...
2. ...
```

Optional sections:
- `## Reference` — Command tables, option lists
- `## Examples` — Input/output pairs
- `## Common Issues` — Known problems and workarounds

Rules:
- No user-facing explanations (those go in README.md)
- Use imperative mood for steps ("Read config", not "Reads config")
- Include concrete examples, not abstract descriptions

---

## README.md Structure (User-Facing)

Required sections:

```markdown
# Title

One-paragraph overview of what this does.

## Usage

How a user triggers it. 3-4 step flow.

## What It Does

- Bullet list of capabilities
- Each starts with a verb

## Example

> "User input"

→ Step 1 → Step 2 → Result

See [SKILL.md](./SKILL.md) for full implementation details.
```

Rules:
- Must link to SKILL.md
- Must NOT duplicate workflow steps from SKILL.md
- Must NOT include implementation details
- Keep under 50 lines

---

## Consistency Checklist

Before committing any skill:

- [ ] `name` in frontmatter == directory name
- [ ] `description` < 40 words, no workflow details
- [ ] SKILL.md has "When to Use" section
- [ ] SKILL.md has "Workflow" or "Implementation" section
- [ ] README.md exists and links to SKILL.md
- [ ] README.md has "Usage" and "Example" sections
- [ ] No duplicate content between README and SKILL
- [ ] All code examples are tested/valid
- [ ] File uses sentence case for headings
- [ ] Copilot instruction files have `applyTo` frontmatter

---

## Plugin Standards

Plugins (`.js` files in `opencode/plugins/`) follow similar rules:

```javascript
/**
 * Plugin name and one-line description.
 *
 * Detailed description of what it does and when it triggers.
 */

export default async ({ client, project, directory }) => {
  return {
    'hook.name': async (input) => {
      // Implementation
    }
  };
};
```

Rules:
- JSDoc header with name + description
- Default export async function
- Return object with hook handlers
- Use optional chaining for input access (`input?.field?.property`)

---

## Command Standards

Commands (`.md` files in `opencode/commands/`) are user-facing triggers:

```markdown
---
description: What this command does and when to use it.
---

# /command-name

## What It Does
- Bullet list

## Usage
1. Step one
2. Step two

## Example
> User types `/command-name ...`

→ Result
```

Rules:
- Filename matches command name (e.g., `retro.md` for `/retro`)
- Description in frontmatter < 40 words
- Include concrete example with user input

---

## Copilot Instruction Files

Copilot instruction files (stowed to ~/.copilot/) provide Copilot CLI with global and path-scoped instructions. Add the following conventions when authoring skills that include Copilot instructions:

- Location & stow: place files under `copilot/` in the project; the stow package maps to `~/.copilot/` on install.
- Global file: `copilot-instructions.md` is the lightweight global pointer (stowed to `~/.copilot/copilot-instructions.md`). Keep it minimal and use it to reference path-scoped instruction files and cross-read locations (e.g., `~/.codex/memories/`).
- Path-scoped files: place under `copilot/instructions/` and name them `*.instructions.md`. Include YAML frontmatter (example: `applyTo: "**"`) and a concise workflow. These files are read by Copilot CLI for contextual behavior.
- Command generation: instruction files MUST NOT attempt to write files automatically. Instead, include example shell commands that users can run (e.g., `mkdir -p ~/.copilot/memories && cat > ~/.copilot/memories/save-$(date +%F_%H%M).md <<'EOF' ... EOF`).
- Filenames: use the `.instructions.md` suffix to distinguish instruction files from SKILL.md and README.md.
- Documentation: SKILL.md and README.md should reference any instruction files and the expected stow installation.

## Related

- [AGENTS.md](./AGENTS.md) — Project conventions and commit rules
- [Makefile](./Makefile) — Stow workflow for installing configs

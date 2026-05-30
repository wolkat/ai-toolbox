# Codex Skills

Codex CLI skills using the `SKILL.md` format.

## Structure

```
codex/skills/
├── README.md           # This file
└── {skill-name}/
    └── SKILL.md        # Skill definition (required)
```

## Installation

Skills are stowed to `~/.codex/skills/` via the Makefile:

```bash
make install-codex    # symlink codex/ skills to ~/.codex/
```

Or manually:

```bash
cp -r codex/skills/{skill-name} ~/.codex/skills/
```

## Adding Skills

1. Create a directory under `codex/skills/{skill-name}/`
2. Add `SKILL.md` with YAML frontmatter (`name`, `description`)
3. Follow standards in [SKILL_STANDARDS.md](../SKILL_STANDARDS.md)
4. Run `make restow-codex` to update symlinks

## Codex Skill vs OpenCode Skill

| Aspect | Codex Skill | OpenCode Skill |
|--------|-------------|----------------|
| Location | `~/.codex/skills/` | `~/.config/opencode/skills/` |
| Invocation | Natural language or `$skill-name` | `/skill-name` slash command |
| Tool APIs | Shell commands, file patches | `task()`, `todowrite()`, `supermemory` |
| Progressive disclosure | Metadata visible, SKILL.md on trigger | Same |

Skills in `.agents/skills/` (BMAD) are agent-agnostic and work in both.
Skills here are Codex-specific — they use Codex tool APIs or conventions.

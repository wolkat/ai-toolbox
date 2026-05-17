# ai-toolbox

This repo contains configs for AI coding agents (OpenCode, Claude Code, etc.).

## Directory Purpose

| Directory | Purpose |
|-----------|---------|
| `opencode/skills/` | OpenCode skills (invoke with `skill({ name: "..." })`) |
| `opencode/commands/` | OpenCode slash commands (use with `/command-name`) |
| `opencode/agents/` | Custom OpenCode agents |
| `opencode/plugins/` | OpenCode plugin files |
| `claude/skills/` | Claude Code skills |
| `claude/commands/` | Claude Code commands |
| `scripts/` | Shell scripts for automation |
| `hooks/` | Git/tool hooks |
| `templates/` | Templates for new skills/agents |

## Quick Reference

### OpenCode Skills Location
Global: `~/.config/opencode/skills/`
Project: `.opencode/skills/`

### OpenCode Commands Location
Global: `~/.config/opencode/command/`
Project: `.opencode/command/`

### Claude Code Skills Location
Global: `~/.claude/skills/`
Project: `.claude/skills/`

## Maintenance

To update skills from this repo to your local config:

```bash
# Update OpenCode skills
cp -r ai-toolbox/opencode/skills/* ~/.config/opencode/skills/

# Update OpenCode commands
cp ai-toolbox/opencode/commands/*.md ~/.config/opencode/command/
```
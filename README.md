# ai-toolbox

Collection of configs, skills, commands, and tools for AI coding agents.

## Structure

```
ai-toolbox/
├── opencode/           # OpenCode configs
│   ├── skills/          # SKILL.md files
│   ├── commands/        # Slash commands
│   ├── agents/         # Custom agents
│   └── plugins/        # Plugin files
├── claude/             # Claude Code configs
│   ├── skills/          # SKILL.md files
│   ├── commands/        # Slash commands
│   └── agents/         # Agent definitions
├── scripts/            # Shared scripts
├── hooks/              # Git hooks, tool hooks
└── templates/          # Reusable templates
```

## Installation

### OpenCode

Copy skills and commands to OpenCode config:

```bash
# Skills
cp -r opencode/skills/* ~/.config/opencode/skills/

# Commands
cp opencode/commands/*.md ~/.config/opencode/command/
```

### Claude Code

```bash
# Skills
cp -r claude/skills/* ~/.claude/skills/

# Commands
cp claude/commands/*.md ~/.claude/commands/
```

## Included

### OpenCode Skills

- **cloudflare** - Cloudflare platform skill (Workers, D1, R2, etc.)
- **plugin-audit** - Plugin installation cross-check
- **skill-audit** - Skill installation cross-check
- **clonedeps** - Clone dependency source code
- **codemap** - Generate codebase maps
- **simplify** - Simplify code for clarity

### OpenCode Commands

- `/cloudflare` - Cloudflare skill orchestrator
- `/supermemory-init` - Initialize supermemory
- `/supermemory-login` - Login to supermemory
- `/supermemory-logout` - Logout from supermemory

## Contributing

Add your own skills, commands, or configs to the appropriate directory and submit a PR.

## License

MIT
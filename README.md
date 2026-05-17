# ai-toolbox

Collection of locally-created configs, skills, commands, and tools for AI coding agents.

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

### OpenCode (via stow)

```bash
cd ~/git/ai-toolbox
make install    # symlink local items to ~/.config/opencode/
make restow     # refresh symlinks after adding new directories
make status     # check symlink state
```

Requires [GNU stow](https://www.gnu.org/software/stow/): `brew install stow`

### Manual (without stow)

```bash
# Skills
cp -r opencode/skills/* ~/.config/opencode/skills/

# Commands
cp opencode/commands/*.md ~/.config/opencode/command/

# Plugins
cp opencode/plugins/*.js ~/.config/opencode/plugins/
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

- **plugin-audit** — Cross-check plugins before installation
- **skill-audit** — Cross-check skills before installation
- **retro** — Session retrospective with 5 Whys and KPI tracking

### OpenCode Commands

- `/retro` — Run session retrospective
- `/save` — Save session learnings to supermemory

### OpenCode Plugins

- **agent-logger** — Log agent activations to console

## Contributing

Add your own skills, commands, or configs to the appropriate directory and submit a PR.

See [SKILL_STANDARDS.md](./SKILL_STANDARDS.md) for quality criteria.

## License

MIT

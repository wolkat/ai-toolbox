# ai-toolbox

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

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
├── codex/              # Codex CLI configs
│   ├── skills/          # SKILL.md files
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

### Codex CLI (via stow)

```bash
cd ~/git/ai-toolbox
make install-codex    # symlink codex items to ~/.codex/
make restow           # refresh symlinks after adding new directories
make status           # check symlink state
```

### Codex CLI (manual)

```bash
# Global AGENTS.md
cp codex/AGENTS.md ~/.codex/AGENTS.md

# Skills
cp -r codex/skills/* ~/.codex/skills/

# Project-level skills (in any repo)
cp -r codex/skills/* .agents/skills/
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

### Codex CLI

- **AGENTS.md** — Global instructions for Codex sessions (`~/.codex/AGENTS.md`)
- **skills/** — Skill definitions for natural-language activation via `$skill-name`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community standards.

## Security

Report vulnerabilities via [SECURITY.md](SECURITY.md).

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

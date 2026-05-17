# Plugin Audit

Cross-check new OpenCode plugins against your existing configuration before installation.

## Usage

When you want to install a plugin:
1. Request install (e.g., "install opencode-xyz")
2. Skill reads your current config
3. Presents audit report with risks and benefits
4. Asks for confirmation before proceeding

## What It Checks

- **Hook overlap** — conflicts with existing plugins using same hooks
- **Command collisions** — duplicate slash command names
- **Model dependencies** — plugins requiring specific models or providers
- **Post-install steps** — additional config files or CLI commands needed

## Example

> "Install opencode-scheduler"

→ Audit report showing no conflicts → confirm → install → verify

See [SKILL.md](./SKILL.md) for full implementation details.

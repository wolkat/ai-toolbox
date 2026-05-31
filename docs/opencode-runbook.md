# OpenCode Configuration Runbook

Guidelines and troubleshooting for `~/.config/opencode/` setup. Discovered
through real incidents — add new topics when you find new patterns.

## Topics

| Guide | Covers |
|-------|--------|
| [Config Files](opencode/config.md) | File locations, provider/model, `tui.json` sync |
| [Plugins](opencode/plugins.md) | Adding, path conventions, fresh sessions, troubleshooting |
| [Permissions](opencode/permissions.md) | Bash allowlist, edit mode, adding new patterns |
| [MCP Servers](opencode/mcp.md) | Exa MCP config, auth, session detection |
| [Agents & Skills](opencode/agents-skills.md) | Subagents, skills, commands, format conventions |

## Discoveries Log

Major incidents that informed these guidelines:

- **2026-05-31** — Plugin reference used `src/index.ts` instead of
  `dist/index.js`; OpenCode cannot load raw `.ts`. See `docs/opencode/plugins.md`.
- **2026-05-??** — Stale `package-lock.json` from `npm install` silently broke
  OpenCode's background installer. See `docs/opencode/plugins.md`.

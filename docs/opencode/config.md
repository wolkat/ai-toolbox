# Config Files

## File Locations

| File | Purpose |
|------|---------|
| `~/.config/opencode/opencode.json` | Global config (plugins, provider, permissions, MCP, agents) |
| `~/.config/opencode/tui.json` | TUI layout, theme, sidebar agents |
| `~/git/.opencode/opencode.json` | Project-local overrides |

Backups (auto-created before migrations):
`opencode.json.bak`, `opencode.json.tui-migration.bak`.

## Provider & Model

```json
"provider": {
  "opencode": {
    "model": "minimax-m2.5-free"
  }
}
```

The model in `opencode.json` sets the default provider, but the **system
prompt** at session start declares the actual model in use. The
`Co-authored-by` line in commit messages must reflect the system prompt
model, not the one in `opencode.json`.

## Config File Sync

The `plugin` array must match between `opencode.json` and `tui.json`:

```bash
grep '"plugin"' ~/.config/opencode/opencode.json
grep '"plugin"' ~/.config/opencode/tui.json
```

Mismatched arrays cause the wrong agents to show in the TUI sidebar. If that
happens, sync `tui.json` to match `opencode.json`.

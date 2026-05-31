# MCP Servers

Currently one remote MCP server:

```json
"mcp": {
  "exa": {
    "type": "remote",
    "url": "https://mcp.exa.ai/mcp?tools=web_search_exa,web_fetch_exa,web_search_advanced_exa",
    "enabled": true,
    "headers": {
      "x-api-key": "<key>"
    }
  }
}
```

- Auth via API key in headers (free tier available without key).
- MCP rate limits are server-side — check dashboard.exa.ai for usage.
- New MCP servers require a fresh OpenCode session to be detected.
- Skills wrapping MCP tools: `~/.config/opencode/skills/exa-search/SKILL.md`

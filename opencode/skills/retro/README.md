# Retro - Session Retrospective Skill

## Overview
Analyzes OpenCode sessions to extract learnings, measure reasoning quality, and track improvement over time.

## Usage

### Trigger
```
/retro
```

### Input
- Describe what happened in the session (or let skill scan logs)
- List tasks attempted, what worked, what didn't
- Note any corrections you made during session

### Output
- Structured retrospective report (Markdown)
- JSON file in `~/.local/share/opencode/retro/` with metrics
- Auto-added to supermemory for searchable context

---

## Metrics Tracked

| KPI | Description | Target |
|-----|-------------|--------|
| First-try correctness | % of solutions correct on first attempt | ↑ higher |
| Fix iterations | Avg attempts needed to reach correct solution | ↓ lower |
| Root cause depth | How deep 5 Whys analysis goes | deeper = better |
| Reasoning accuracy | Self-assessment of reasoning quality | 1-5 scale |
| Recurring issues | Same root cause appearing across sessions | ↓ lower |

---

## Data Flow

```
Session → /retro → Report (Markdown)
                → JSON → ~/.local/share/opencode/retro/{timestamp}.json
                → Supermemory (searchable)
```

### Trend Graph (Manual)

```
First-try correctness (last 10 sessions)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
100% |▓▓▓▓▓▓▓▓
 80% |▓▓▓▓▓▓▓▓▓▓▓▓▓▓
 60% |▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
 40% |▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
 20% |▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  0% └──────────────────────────────
       S1  S2  S3  S4  S5  S6  S7

Fix iterations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3.0 |▓▓
2.5 |▓▓▓▓
2.0 |▓▓▓▓▓▓
1.5 |▓▓▓▓▓▓▓▓▓▓▓▓▓
1.0 |▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

Run `/retro` periodically → compare outputs → track trends manually.

## Example

> User types `/retro`

→ Skill loads → asks about session tasks → analyzes → generates report → saves to `~/.local/share/opencode/retro/` → adds summary to supermemory

See [SKILL.md](./SKILL.md) for full implementation details.

---

## Corrective Actions

Each retro identifies actions. These are NOT auto-executed - you decide what to implement.

Example backlog format:
```
## Backlog
- [ ] Add type check to plugin-audit
- [ ] Create file op verification step
- [ ] Document common root causes
```

### Pre-Execution Validation (Recommended)

Before executing tool calls, verify:
1. **Path format** — Read/Edit/Write require absolute paths (`/Users/...` not `~/.`)
2. **Command separation** — Unrelated bash commands belong in separate tool calls
3. **Interactive safety** — All bash commands must be non-interactive (no TTY, no prompts)

---

## Data Location

| Type | Location | Notes |
|------|----------|-------|
| JSON reports | `~/.local/share/opencode/retro/` | XDG Data Directory; set `$XDG_DATA_HOME` to override |
| Searchable context | Supermemory (global scope) | |
| Raw logs | `~/.local/share/opencode/log/` | |

---

## Integration with ai-toolbox

This skill is part of ai-toolbox. To update to local config:

```bash
# If using stow
cd ~/git/ai-toolbox && make restow

# Or manual copy
cp -r ~/git/ai-toolbox/opencode/skills/retro ~/.config/opencode/skills/
```
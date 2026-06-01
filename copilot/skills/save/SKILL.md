---
name: save
description: Generate shell commands to save Copilot session memories to ~/.copilot/memories. Triggers when user requests to save learnings or end of productive session.
---

# Save Session Learnings (Copilot CLI)

Generate shell commands for users to persist session learnings to the Copilot memories store.

## When to Use

- User requests to save learnings explicitly ("save this session", "remember this")
- End of a productive session with new discoveries
- After resolving a significant error or configuration issue
- When new workflow patterns are discovered
- Before ending a session with important context for future sessions

## Workflow

### Step 1: Analyze the Session

Scan recent conversation for distinct learnable events:

- Agent or model configuration changes
- Plugin or skill installations
- Error solutions and workarounds
- New workflow patterns or commands
- Project-specific discoveries

### Step 2: Extract Learnings

For each distinct insight:

- Determine the appropriate category (agent-config, plugin-install, workflow, error-solution, model-config)
- Format content with date: `(YYYY-MM-DD)` at start
- Keep content focused and scannable

### Step 3: Generate Shell Command

Generate a shell command that the user can run to persist the memory. The command must:

- Include `mkdir -p ~/.copilot/memories` to ensure the directory exists
- Use timestamp format `YYYY-MM-DD_HHMM` per AGENTS.md convention
- Write to `~/.copilot/memories/save-{timestamp}.md`
- Follow the same markdown structure as Codex: Date, Learnings (by category), Tags

Example command:

```bash
mkdir -p ~/.copilot/memories && cat > ~/.copilot/memories/save-$(date +%Y-%m-%d_%H%M).md <<'EOF'
# Session Memory

## Date
YYYY-MM-DD

## Learnings

### Category: [category-name]

- [Learning 1]
- [Learning 2]

## Tags
- [tag1]
- [tag2]
EOF
```

### Step 4: Report Summary

Report to the user:

- Number of learnings to save
- Categories covered
- The generated shell command for review and execution

## Best Practices

1. **Shell command generation only** — Copilot CLI cannot write files automatically. Always generate a shell command for user review and execution.
2. **Cross-read from Codex** — Also check `~/.codex/memories/` for relevant context from Codex sessions.
3. **Minimal memory files** — Keep generated memory files small and focused.
4. **Provide summary** — Include a brief summary at top of the generated content.
5. **Periodic suggestion** — Suggest saving at end of productive sessions or during long sessions with significant discoveries.

## Reference

This skill is part of the Copilot CLI instruction system:

- Global instructions: `~/.copilot/copilot-instructions.md` (stowed from `copilot/copilot-instructions.md`)
- Path-scoped instructions: `~/.copilot/instructions/save.instructions.md` (stowed from `copilot/instructions/save.instructions.md`)
- Sibling implementation: `codex/skills/save/SKILL.md` (Codex save skill)

## Examples

> User: "save this session"

→ Analyze session → Extract learnings → Generate shell command → Present for approval

> User: "remember what we learned about stow"

→ Extract stow-related learnings → Generate focused shell command → Present for approval

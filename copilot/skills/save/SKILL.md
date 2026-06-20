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

### Step 3: Classify & Promote to AGENTS.md

For each learning, determine if it belongs in AGENTS.md:

**Promote to AGENTS.md if:**
- Applies across multiple projects/repos
- Is a convention, standard, or best practice
- Has reusable code examples
- Would prevent a recurring agent mistake

**Save to memory file only if:**
- Project-specific discovery
- Ephemeral session context
- Agent/model configuration changes
- One-time error solutions

**For each proposed AGENTS.md addition:**
- **Deduplicate** — Read existing AGENTS.md, search for similar rules. Merge/amend if already covered.
- **Size guard** — If AGENTS.md exceeds 200 lines, propose pruning before adding. Suggest moving detailed sections to `docs/` with a brief reference.
- **Quality gate** — Each rule must pass: "If I remove this, will the agent make a mistake?" If no, it belongs in memory file only.
- **Confirmation** — Present proposed changes with line impact. Get explicit user approval before editing AGENTS.md.

### Step 4: Generate Shell Command

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

### Step 5: Review AGENTS.md Health

After saving, run a health check:

- **Line count** — warn if over 200 lines, hard warn at 300+
- **Byte count** — warn if over 20 KB, hard warn at 30 KB (approaching 32 KB Codex cap)
- **Section size** — flag any section over 50 lines (move details to `docs/` or a skill)
- **Stale rule scan** — flag rules that agents consistently follow without instruction (candidates for pruning)
- **Source audit** — flag rules without a clear reason for existing
- **Report** — print health summary to user

### Step 6: Report Summary

Report to the user:

- Number of learnings to save
- Rules promoted to AGENTS.md (with approval status)
- AGENTS.md health status
- Categories covered
- The generated shell command for review and execution

## Best Practices

1. **Shell command generation only** — Copilot CLI cannot write files automatically. Always generate a shell command for user review and execution.
2. **Cross-read from Codex** — Also check `~/.codex/memories/` for relevant context from Codex sessions.
3. **Minimal memory files** — Keep generated memory files small and focused.
4. **Provide summary** — Include a brief summary at top of the generated content.
5. **Periodic suggestion** — Suggest saving at end of productive sessions or during long sessions with significant discoveries.

## AGENTS.md Size Management Guidelines

- **Target**: under 200 lines per file, each section under 50 lines
- **Progressive disclosure**: brief rule in AGENTS.md, details in skills or `docs/`
- **Prune quarterly**: remove rules agents follow correctly without instruction
- **Source tracking**: every rule should have a reason for existing
- **Acid test**: if removing the rule wouldn't cause an agent mistake, it doesn't belong

## Reference

This skill is part of the Copilot CLI instruction system:

- Global instructions: `~/.copilot/copilot-instructions.md` (stowed from `copilot/copilot-instructions.md`)
- Path-scoped instructions: `~/.copilot/instructions/save.instructions.md` (stowed from `copilot/instructions/save.instructions.md`)
- Sibling implementation: `codex/skills/save/SKILL.md` (Codex save skill)

## Examples

> User: "save this session"

-> Analyze session -> Extract learnings -> Classify for AGENTS.md -> Generate shell command -> Present for approval

> User: "remember what we learned about stow"

-> Extract stow-related learnings -> Classify for AGENTS.md -> Generate focused shell command -> Present for approval

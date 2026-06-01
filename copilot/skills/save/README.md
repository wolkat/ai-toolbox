# Copilot Save Skill

Save session learnings to the Copilot memories store by generating shell commands for user approval.

## Usage

1. Install the copilot stow package: `cd ai-toolbox && make install-copilot`
2. Start a Copilot CLI session
3. Ask Copilot to save learnings: "save this session" or "remember this"
4. Review the generated shell command
5. Execute the command to persist the memory

## What It Does

- Analyzes current session for learnable events
- Categorizes insights (agent-config, plugin-install, workflow, error-solution, model-config)
- Generates shell commands to write memory files to `~/.copilot/memories/`
- Cross-reads from `~/.codex/memories/` for shared context from Codex sessions

## Example

> "save this session"

→ Analyze session → Extract learnings → Generate shell command:

```bash
mkdir -p ~/.copilot/memories && cat > ~/.copilot/memories/save-2026-05-30_1815.md <<'EOF'
# Session Memory

## Date
2026-05-30

## Learnings

### Category: workflow

- Created copilot stow package for ai-toolbox
- Copilot CLI instruction files use applyTo frontmatter

## Tags
- copilot
- stow
EOF
```

See [SKILL.md](./SKILL.md) for full implementation details.

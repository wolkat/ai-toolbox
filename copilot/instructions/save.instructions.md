---
applyTo: "**"
---

# Save skill (Copilot instructions)

Workflow:
1. Analyze current session and summarize learnings.
2. Categorize items (agent-config, plugin-install, workflow, error-solution, model-config).
3. Produce a shell command that the user can run to persist the memory (example: `mkdir -p ~/.copilot/memories && cat > ~/.copilot/memories/save-$(date +%F_%H%M).md <<'EOF'\n{CONTENT}\nEOF`).
4. Present the generated shell command and a short summary to the user for approval.

Notes:
- Do NOT write files automatically. Always output a shell command for user to review and run.
- Ensure `mkdir -p ~/.copilot/memories` appears in generated commands.
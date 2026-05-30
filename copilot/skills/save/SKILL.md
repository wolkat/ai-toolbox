---
name: copilot-save
version: 0.1.0
summary: "Generate shell commands to save Copilot session memories to ~/.copilot/memories"
---

# When to use
Use when a user wants to persist session learnings or notable events into the Copilot memories store.

# Workflow
1. Extract salient items from the session.
2. Create a short summary and suggested filename (YYYY-MM-DD_HHMM).
3. Emit a single shell command that will create the memories directory and write the file when executed by the user.

# Best practices
- Keep generated memory files small and focused.
- Provide a brief summary at top of the generated content.
- Do not attempt to run commands; present them for user review.

# Copilot global instructions

This repository provides Copilot CLI instruction files under the `copilot/` stow package.

Cross-read: ~/.codex/memories/

See `instructions/save.instructions.md` for the "save" skill (path-scoped instructions).

Notes:
- Files in this package are intended to be stowed to ~/.copilot/
- Copilot CLI cannot auto-write files; skill steps generate shell commands for user approval.
- Set `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` to discover modular instruction files in this package.
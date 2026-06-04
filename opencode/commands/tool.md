---
description: Build CLI tools and shell scripts with -h/--help support, bash 3.2 compatibility, and non-interactive execution.
agent: tool-builder
---

# /tool — CLI Tool and Script Builder

Build robust, portable, non-interactive CLI tools and shell scripts.

## Quick Start

```bash
/tool                                          # Interactive: describe tool to build
/tool Create a backup script for dotfiles       # Build a specific tool
/tool --portable Create a sync script          # Ensure bash 3.2 compatibility
/tool --test Create a deployment script         # Build and test
```

## Your Task

1. **Invoke the `tool-builder` agent** to load the full behavioral rules
2. **Read existing scripts** in the project to understand conventions (arg parsing, error handling, output format)
3. **Define the tool's interface** (arguments, flags, subcommands, help text)
4. **Implement** with portable bash 3.2 constructs
5. **Add `-h`/`--help`** with usage, description, arguments, and at least one example
6. **Validate** with `bash -n` and `shellcheck`
7. **Test** non-interactive execution
8. **Document** in `docs/learnings/` if the tool produces analytical outputs

## Mandatory Requirements

Every script produced by this agent MUST:

1. Support `-h` and `--help` flags that print usage, description, arguments, and examples
2. Target bash 3.2 (macOS) — no associative arrays, no process substitution `<()`, no `mapfile`
3. Be non-interactive — use `--yes`, `--force`, `CI=true`, `--non-interactive` flags
4. Exit with code 0 on success, non-zero on failure
5. Send data to stdout, prompts/errors to stderr

## Key Rules

- All commands must be non-interactive
- Test with `bash -n` and `shellcheck` before completion
- Prefer parameters/subcommands over interactive prompts
- Store tech outputs in `docs/learnings/`, not XDG or `~/git` root
- Never spawn sub-agents
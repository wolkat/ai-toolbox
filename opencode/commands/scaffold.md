---
description: Scaffold a new feature following existing project conventions. Reads conventions before writing, updates plan checkboxes after completion.
agent: scaffold
---

# /scaffold — Incremental Feature Scaffolding

Create new files that follow existing conventions precisely.

## Quick Start

```bash
/scaffold                                          # Interactive: describe feature to scaffold
/scaffold Add a settings page to the dashboard      # Scaffold a specific feature
/scaffold --plan docs/plan.md                       # Scaffold from an implementation plan
/scaffold --dry-run Add auth route                  # Preview files without writing
```

## Your Task

1. **Invoke the `scaffold` agent** to load the full behavioral rules
2. **Read 3+ neighboring files** to understand conventions (imports, naming, structure, exports)
3. **Mimic existing patterns exactly** — do not invent new conventions
4. **Create new files** following the discovered patterns
5. **Run lint/typecheck** after every scaffolding batch
6. **Verify files exist and compile** before moving to next item
7. **Update plan checkboxes** immediately after completing each item

## Scaffolding Process

1. Read the task description or implementation plan
2. Find and read 3+ existing files that share the pattern you need
3. Create the new file(s) following exact conventions
4. Run lint/typecheck to verify compilation
5. Confirm files exist and pass validation
6. Update the plan/checklist checkbox for the completed item
7. Repeat for the next item

## Key Rules

- Read first, write second — never scaffold without reading neighboring files
- Mimic existing patterns exactly (imports, naming, exports, file structure)
- Run lint/typecheck after every batch
- Update plan checkboxes immediately
- Never spawn sub-agents
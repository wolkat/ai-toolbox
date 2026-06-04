---
description: Run adversarial code review on specified files or directories. Read-only on source, findings output to docs/learnings/.
agent: review
---

# /review — Adversarial Code Review

Find real defects, never deflect. Read-only on source code.

## Quick Start

```bash
/review                          # Review recently changed files
/review src/api/auth.ts          # Review a specific file
/review src/utils/               # Review a directory
/review --focus security          # Focus on security issues
/review --focus performance       # Focus on performance issues
```

## Your Task

1. **Invoke the `review` agent** to load the full behavioral rules
2. **Query supermemory** for project standards and conventions first
3. **Read the target files thoroughly** (for codebases under 2000 LOC, use direct file reads — no sub-agents)
4. **Search/grep** for anti-patterns, edge cases, and security issues
5. **Cross-reference** code against spec, plan, and documentation
6. **Write findings** to `docs/learnings/` as a structured markdown report
7. **Update plan checkboxes** if reviewing tracked items

## Focus Areas

| Focus Flag | What to Look For |
|-------------|-----------------|
| `security` | Injection, auth bypass, secret exposure, input validation |
| `performance` | N+1 queries, unnecessary re-renders, memory leaks, blocking I/O |
| `correctness` | Off-by-one, null/undefined, race conditions, missing error handling |
| `maintainability` | Dead code, god functions, inconsistent naming, missing types |

## Output Format

Save findings to `docs/learnings/review-YYYY-MM-DD.md`:

```markdown
# Code Review: [scope]

**Date:** YYYY-MM-DD
**Files:** [list]
**Focus:** [security/performance/correctness/maintainability/all]

## Findings

### [CRITICAL] Title
- **File:** path:line
- **Issue:** description
- **Fix:** suggested fix

### [MEDIUM] Title
...

### [LOW] Title
...

## Summary
- X critical, Y medium, Z low findings
- Overall assessment
```

## Key Rules

- Read-only on source code — never edit files being reviewed
- Own every finding — no deflection, no "this might be fine"
- For codebases under 2000 LOC: direct file reads, no sub-agents
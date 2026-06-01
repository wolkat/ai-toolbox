# Session Pattern Analysis — June 2026

Generated: 2026-06-02 from 235 OpenCode sessions (May 16 – June 2, 2026).

## Overview

| Metric | Value |
|--------|-------|
| Total sessions | 235 |
| Date range | 2026-05-16 – 2026-06-02 |
| Total cost | ~$103 USD |
| Total input tokens | ~35.6M |
| Total output tokens | ~1.9M |
| Unique agents used | 13 |
| Unique models used | 21 |

## Agent Usage Summary

| Agent | Sessions | Cost | Input K | Output K | Avg Cost/Session |
|-------|----------|------|---------|----------|------------------|
| Sisyphus - ultraworker | 30 | $41.69 | 14,308 | 669 | $1.78 |
| build | 47 | $21.21 | 13,630 | 836 | $0.45 |
| Sisyphus-Junior | 40 | $3.78 | 2,019 | 204 | $0.09 |
| Atlas - Plan Executor | 2 | $5.56 | 877 | 88 | $2.78 |
| plan | 6 | $0.80 | 1,716 | 77 | $0.13 |
| review | 9 | $0.94 | 294 | 34 | $0.10 |
| Metis - Plan Consultant | 6 | $0.38 | 135 | 10 | $0.06 |
| explore | 56 | $0.30 | 148 | 84 | $0.005 |
| oracle | 18 | $0.39 | 153 | 5 | $0.02 |
| Momus - Plan Critic | 2 | $0.28 | 114 | 4 | $0.14 |
| librarian | 14 | $0.20 | 0.2 | 40 | $0.01 |
| todo | 5 | $0.16 | 87 | 2 | $0.03 |

## Model Usage Summary

| Model | Sessions | Primary Agent | Notes |
|-------|----------|---------------|-------|
| glm-5.1 | 51 | build, Sisyphus, oracle | Primary driver model |
| qwen3.5-plus | 38 | explore, librarian | Subagent workhorse |
| kimi-k2.6 | 32 | build, Sisyphus-Junior | Heavy implementation |
| minimax-m2.7 | 27 | Sisyphus-Junior, explore | Implementation subagent |
| minimax-m2.5-free | 17 | build, Sisyphus | Early experimentation |
| deepseek-v4-flash-free | 11 | build, Sisyphus | Long-context sessions |
| gemini-3.1-pro-preview | 9 | oracle, review | High-reasoning verification |
| gpt-5.5 | 5 | oracle | Verification subagent |
| mimo-v2.5-pro | 5 | review | Code review subagent |
| qwen3.7-max | 4 | Sisyphus, Atlas | Planning executor |
| minimax-m3 | 4 | build | Medium sessions |

## Top 15 Sessions by Message Count

| Messages | Title | Agent | Model |
|----------|-------|-------|-------|
| 448 | Minimax M2.5 free model plugin compatibility | build | kimi-k2.6 |
| 398 | New session (init-learn) | Sisyphus | minimax-m2.5-free |
| 357 | LifeBinder project next steps priority | Sisyphus | glm-5.1 |
| 316 | Session learnings review | plan | minimax-m2.5-free |
| 206 | Validating agent-logger plugin (fork #1) | build | kimi-k2.6 |
| 189 | Multi-project documentation and fixes | build | mimo-v2.5-pro |
| 183 | New session (Sisyphus) | Sisyphus | deepseek-v4-flash-free |
| 176 | Pinging all agents | build | minimax-m2.5-free |
| 170 | New session (kimi build) | build | kimi-k2.6 |
| 167 | Save skill for Copilot CLI | Sisyphus | qwen3.7-max |
| 144 | Red case emergency prep checklist | Sisyphus | glm-5.1 |
| 143 | Hidden files not showing in terminal | build | minimax-m2.5-free |
| 135 | BMAD Method installation setup | Sisyphus | glm-5.1 |
| 132 | Terminal tool usage dependency tracking | Atlas | qwen3.7-max |
| 123 | Validating agent-logger plugin | build | kimi-k2.6 |

## 5 Identified Archetypes

### Archetype 1: `infra-maintainer` (Plugin/Skills Lifecycle)

**Sessions:** 30+ | **Percent of total:** ~13%

Recurring pattern: install → validate → debug → cleanup for OpenCode plugins, skills, and agents.

**Common actions (by frequency):**
1. Debug plugin load failures (check logs, verify paths, trace errors)
2. Validate plugin compatibility (audit, test fork, check conflicts)
3. Fix path/resolution issues (compiled .js vs .ts source, symlinks vs copies)
4. Manage skill/agent registration (visibility, config entries)
5. Clean up corrupted/orphaned state (remove stale plugins, fix broken symlinks)

**Pain points:**
- Path resolution (.ts vs compiled .js) — #1 repeated mistake
- Symlink vs copy ambiguity for skills
- Silent plugin load failures with minimal logging
- Same validation task re-attempted without acceptance criteria

**Required skills:** plugin-audit, skill-audit, customize-opencode

**Proposed config:**
```json
{
  "infra-maintainer": {
    "description": "Plugin, skill, and agent lifecycle management. Installs, validates, debugs, and cleans up OpenCode infrastructure.",
    "mode": "subagent",
    "permission": {
      "read": "allow", "glob": "allow", "grep": "allow", "bash": "allow",
      "edit": "allow", "write": "allow", "question": "allow", "todowrite": "allow",
      "task": "deny", "webfetch": "deny", "websearch": "deny"
    }
  }
}
```

**Rules:**
- Always verify compiled .js entry points exist before referencing plugins
- Run plugin-audit/skill-audit before any install
- Never use symlinks for skills — use copies
- Check `~/.local/share/opencode/log/` on any load failure
- Define acceptance criteria before cleanup tasks

---

### Archetype 2: `review` (Adversarial Quality Assurance)

**Sessions:** 65+ (56 explore + 9 review) | **Percent of total:** ~28%

Recurring pattern: multi-perspective code review (blind, edge-case, compliance, multi-model, multi-persona debate).

**Common actions (by frequency):**
1. Read/digest source files
2. Search/grep for anti-patterns & edge cases
3. Cross-reference code against spec/plan/docs
4. Compare findings across multiple agents/models
5. Write review reports/findings
6. Check test coverage & run linters
7. Verify compliance with documented standards
8. Debate alternatives via multi-persona

**Pain points:**
- Background agents timeout (12h+ on free-tier models)
- Plan checkboxes never updated after review
- Deflection on criticism (agent rationalizes instead of owning defects)
- Subagents overused on small codebases (<2000 LOC)
- Memory/docs not checked first

**Required skills:** exa-search, codemap, simplify

**Proposed config:**
```json
{
  "review": {
    "description": "Adversarial code review. Find real defects, never deflect. Output to docs/learnings/ only. Read-only on source code.",
    "mode": "subagent",
    "permission": {
      "read": "allow", "glob": "allow", "grep": "allow", "bash": "allow",
      "write": "allow", "question": "allow", "memory": "allow", "todowrite": "allow",
      "edit": "deny", "task": "deny", "webfetch": "deny", "websearch": "deny"
    }
  }
}
```

**Rules:**
- Read-only on source code — findings go to reports only
- For codebases <2000 LOC: direct file reads, no sub-agents
- Always query supermemory for project standards first
- Own every finding — no deflection or rationalization
- Update plan checkboxes when reviewing tracked items

---

### Archetype 3: `scaffold` (Incremental Feature Scaffolding)

**Sessions:** 30+ | **Percent of total:** ~13%

Recurring pattern: create route/component/script files following existing conventions.

**Common actions (by frequency):**
1. Read 3+ neighboring files to understand conventions
2. Create new file mimicking existing patterns (imports, naming, structure)
3. Run lint/typecheck after scaffolding
4. Verify file exists and compiles
5. Update plan/implementation checklist

**Pain points:**
- Writing before reading conventions (wrong imports, wrong structure)
- Plan checkboxes never updated after implementation
- No verification loop after scaffolding

**Required skills:** customize-opencode, clonedeps, codemap

**Proposed config:**
```json
{
  "scaffold": {
    "description": "Incremental feature scaffolding. Reads conventions before writing. Updates plan checkboxes after completion.",
    "mode": "subagent",
    "permission": {
      "read": "allow", "glob": "allow", "grep": "allow", "bash": "allow",
      "edit": "allow", "write": "allow", "question": "allow", "todowrite": "allow",
      "task": "deny", "webfetch": "deny", "websearch": "deny"
    }
  }
}
```

**Rules:**
- Read 3+ neighboring files before writing any new file
- Mimic existing patterns exactly — imports, naming, structure
- Run lint/typecheck after every scaffolding batch
- Update plan checkboxes immediately after completing items
- Verify file exists and compiles before moving to next item

---

### Archetype 4: `cross-repo-coordinator` (Workspace/Repo Hygiene)

**Sessions:** 20+ | **Percent of total:** ~9%

Recurring pattern: scan-repos, audit, sync, retro across multiple repositories.

**Common actions (by frequency):**
1. Scan repos for unfinished work (todos, unchecked items, stale branches)
2. Git state audit (uncommitted changes, dirty trees, stash inventory)
3. Retro/learnings extraction (analyze sessions, capture corrective actions)
4. Repo reorganization (move, rename, remove repos)
5. Cross-project doc/tooling sync

**Pain points:**
- Writing to wrong directory (~/git/ root instead of projects/subdir)
- No git-boundary check before commits
- Scan results not actionable (lists but no auto-triage)
- Memory not consulted first

**Required skills:** graphify, exa-search, memory

**Proposed config:**
```json
{
  "cross-repo-coordinator": {
    "description": "Scans, audits, and synchronizes state across workspace repositories. Read-heavy with targeted write escalation. Enforces git boundaries and memory-first lookups.",
    "mode": "subagent",
    "permission": {
      "read": "allow", "glob": "allow", "grep": "allow", "bash": "allow",
      "question": "allow", "todowrite": "allow",
      "edit": "deny", "write": "deny", "task": "deny"
    }
  }
}
```

**Rules:**
- Always read dirmap.yml or AGENTS.md first for workspace structure
- `git -C <path> rev-parse` must succeed before any write
- Consult supermemory before web fetch for known topics
- Output grouped markdown report to stdout, not files
- For retro sessions: parse opencode.db for patterns, apply 5 Whys

---

### Archetype 5: `tool-builder` (CLI/Tooling Development)

**Sessions:** 16+ | **Percent of total:** ~7%

Recurring pattern: build scripts, CLI tools, shell config, key management.

**Common actions (by frequency):**
1. Create shell scripts with argument parsing
2. Add --help flags and documentation
3. Test bash 3.2 (macOS) compatibility
4. Configure shell aliases/environment
5. Manage API keys and authentication

**Pain points:**
- Scripts missing --help flags
- Bash 3.2 (macOS) compatibility not tested
- Interactive prompts hang in non-interactive shells
- Same tooling patterns rebuilt across sessions

**Required skills:** shell-strategy, customize-opencode, clonedeps

**Proposed config:**
```json
{
  "tool-builder": {
    "description": "CLI/tooling development. Scripts must support -h/--help, target bash 3.2, all commands non-interactive.",
    "mode": "subagent",
    "permission": {
      "read": "allow", "glob": "allow", "grep": "allow", "bash": "allow",
      "edit": "allow", "write": "allow", "question": "allow", "todowrite": "allow",
      "task": "deny", "webfetch": "deny", "websearch": "deny"
    }
  }
}
```

**Rules:**
- Every script MUST support -h and --help flags
- Target bash 3.2 (macOS) — no associative arrays, no process substitution
- All commands non-interactive (use --yes, --force, CI=true)
- Test scripts with `bash -n` and `shellcheck` before completion
- Prefer parameters/subcommands over interactive prompts
- Store tech outputs in docs/learnings/, not XDG or ~/git root

## Existing Agents (Keep + Refine)

| Agent | Sessions | Role | Recommendation |
|-------|----------|------|---------------|
| explore | 56 | Research/search | Keep, add graphify skill |
| librarian | 14 | Web search + docs | Keep, add exa-search |
| oracle | 18 | Multi-model verification | Keep, restrict to verify-only |
| todo | 5 | Unfinished work scanner | Merge into `cross-repo-coordinator` |
| Metis | 6 | Plan review | Keep, add review rules |
| Momus | 2 | Plan criticism | Keep, add adversarial rules |
| Sisyphus-Junior | 40 | Task execution sub | Keep, reassign some categories |

## Cross-Cutting Observations

### Token Budget Imbalance
~83% of token budget spent on tasks suitable for fast-tier agents (`infra-maintainer`, `cross-repo-coordinator`, `scaffold`, `tool-builder`). High-reasoning budget should be reserved for `review` and `Metis`/`Momus`.

### Subagent Timeout Pattern
Background agents timeout after 12+ hours on free-tier models. Memory entry added. Recommendation: cancel after 145s if no progress output.

### Git Boundary Failures
Repeated writes to ~/git/ root instead of projects/subdir. Root cause: agent not checking `git -C <path> rev-parse` before writes. Fix: add to all agent rule sets.

### Plan Checkbox Debt
Implementation plans accumulate unchecked items (lifebinder: 103 unchecked). Review agents should update checkboxes as they verify items.

### Shell Compatibility Gaps
Scripts built in sessions fail on macOS bash 3.2 (associative arrays, process substitution, `mapfile`). The `shell-strategy` skill exists but is not automatically applied to `tool-builder` sessions.
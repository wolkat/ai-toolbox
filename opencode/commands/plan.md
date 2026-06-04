---
description: Structured planning with completeness verification. Constructs a Layer Completion Matrix, runs Spec-Traceability checks, and performs Same-Name-Different-Layer audits before implementation begins.
---

# /plan — Structured Planning with Completeness Rules

Plan any multi-layer change using three verification rules that catch gaps before implementation starts.

## Quick Start

```bash
/plan                                        # Interactive: describe what you're planning
/plan Deploy 3 new agents with config         # Plan a specific task
/plan --matrix-only Add skills to agents     # Run only the Layer Completion Matrix
/plan --trace-only Wire up model preferences  # Run only the Spec-Traceability Check
/plan --audit-only Add command files          # Run only the Same-Name Audit
```

## The Three Rules

These rules prevent the most common planning failures in multi-layer deployments:

### Rule 1: Layer Completion Matrix

Before implementation, construct a matrix with every entity across every layer. Each cell must be explicitly verified.

```
Entity          | JSON config | Prompt .md | Slash command | Skills wired | Model tier
----------------|-------------|------------|---------------|-------------|------------
agent-name      |     ?       |     ?      |       ?       |      ?      |     ?
```

- Every `?` must become `✓` or `✗` before implementation starts
- A row of mixed `✓` and `✗` = incomplete entity
- A column with many `✗` = incomplete layer

### Rule 2: Spec-Traceability Check

Every specification item must trace to a concrete deliverable with a verification command.

Format: `PLAN_ITEM → DELIVERABLE → VERIFICATION`

```
"review needs skills: exa-search, codemap, simplify"
  → review.md gets "## Required Skills" section listing all three
  → grep -c "exa-search\|codemap\|simplify" review.md == 3
```

- Extract every prescriptive statement from the spec (must/shall/requires)
- Write the specific file/section that will contain it
- Write a verification command (grep, file existence, JSON validation)

### Rule 3: Same-Name-Different-Layer Audit

When artifacts share a name across directories, verify each one exists at every required layer, not just one.

Example that failed: `agent-forge` existed in `commands/` but not in `agent/`. The command file masked the missing prompt file.

Verification: for each entity name, `ls` all directories where a file with that name should exist.

## Your Task

1. **Describe the plan** — What entities are being created or modified? What layers are involved?
2. **Build the Layer Completion Matrix** — List every entity × every layer. Mark current state (✓ exists, ✗ missing, ? unknown).
3. **Run Spec-Traceability** — For each spec requirement, write the deliverable and verification command.
4. **Run Same-Name Audit** — For each entity name, check all directories where files should exist.
5. **Present the matrix** — Show the user the full matrix with all gaps highlighted.
6. **Get confirmation** — Do not start implementation until the user confirms the plan addresses all gaps.
7. **After implementation** — Re-run verification commands to confirm every cell is now ✓.

## Matrix Layers (Common)

For OpenCode agent infrastructure, the standard layers are:

| Layer | Location | Purpose |
|-------|----------|---------|
| JSON config | `~/.config/opencode/opencode.json` → `agent` key | Permissions, mode, description |
| Prompt file | `~/.config/opencode/agent/<name>.md` | Behavioral rules, required skills, model prefs |
| Slash command | `projects/ai-toolbox/opencode/commands/<name>.md` | User-facing command template |
| Global command | `~/.config/opencode/command/<name>.md` | Copy of command for global availability |
| Command reg | `opencode.json` → `command` key | Registration mapping command to agent |
| Skills section | Inside `<name>.md` → `## Required Skills` | Which skills the agent should invoke |
| Model section | Inside `<name>.md` → `## Model Preference` | Which model tier to use |

Not all layers apply to every plan. Skip layers that don't apply but document which ones were skipped and why.

## Verification Script

After implementation, run this to verify completeness:

```bash
for agent in $(python3 -c "import json; d=json.load(open('$HOME/.config/opencode/opencode.json')); print(' '.join(a for a in d.get('agent',{}) if 'disable' not in d['agent'][a]))"); do
  echo "=== $agent ==="
  python3 -c "import json; d=json.load(open('$HOME/.config/opencode/opencode.json')); print('  JSON config:', 'permission' in d['agent']['$agent'])"
  test -f "$HOME/.config/opencode/agent/$agent.md" && echo "  Prompt file: ✓" || echo "  Prompt file: ✗"
  grep -c "Required Skills" "$HOME/.config/opencode/agent/$agent.md" 2>/dev/null | xargs -I{} echo "  Skills wired: {}" || echo "  Skills wired: ✗"
  grep -c "Model Preference" "$HOME/.config/opencode/agent/$agent.md" 2>/dev/null | xargs -I{} echo "  Model pref: {}" || echo "  Model pref: ✗"
done
```
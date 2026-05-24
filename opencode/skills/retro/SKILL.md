---
name: retro
description: Session retrospective skill - analyze OpenCode sessions to extract learnings, measure reasoning quality, and track improvement over time using 5 Whys method and structured KPIs.
---

# Retro Skill

Analyze OpenCode sessions to extract learnings, measure reasoning quality, and drive continuous improvement.

## When to Use

- User types `/retro` at session end
- User wants to analyze what went wrong in a session
- User wants to track performance trends over time
- Session had multiple iterations/fixes to get to correct solution

## Data Sources

### Primary Sources
1. **User input** - User describes what happened, tasks attempted, what worked/failed
2. **Session logs** - `~/.local/share/opencode/log/` - tool calls, errors, timing
3. **Supermemory** - Previous sessions, patterns, recurring issues

### What to Extract
- Tasks completed during session
- Tasks that required fixes/iterations
- What the correct solution was
- How many attempts to reach correct solution
- Any user corrections made during session

## Data Directory Setup

Before saving retro reports, ensure the data directory exists:

```bash
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/retro"
mkdir -p "$DATADIR"
```

All retro outputs (Markdown + JSON) are saved to `~/.local/share/opencode/retro/` by default. Set `$XDG_DATA_HOME` env var to override.

## Workflow

### Step 0.5: Design Verification (CRITICAL)

Before implementation starts, review requirements against the plan:
- Are all expected outputs defined? (e.g., chat display, markdown file, JSON file)
- Is the data storage path verified?
- Are all dependencies handled?
- Does the plan meet ALL user requirements?

**If missing any requirement, do not proceed to implementation.** Add to implementation plan first.

### Step 0.6: Pre-Execution Validation (From Retro Learnings)

Before any tool call execution, verify these constraints (based on recurring session issues):

1. **Path format check** — Read/Edit/Write tools require absolute paths
   - ❌ `~/.config/...` — tilde does NOT expand
   - ✅ `/Users/katops/.config/...` — absolute path
   
2. **Command separation check** — Bash tool: one concern per call
   - ❌ `echo "header" && grep pattern file` — combining unrelated commands
   - ✅ Separate `echo` and `grep` into individual tool calls
   
3. **Interactive safety check** — All bash commands must be non-interactive
   - No `vim`, `less`, `man`, interactive `git` commands
   - Use `-y`, `--yes`, `--non-interactive`, `-f` flags where available

Ask user for:
- What tasks were attempted?
- What worked on first try?
- What required fixes? (what was wrong → how was it fixed)
- Any user corrections or clarifications during session?

If logs available:
- Read `~/.local/share/opencode/log/` for tool call history
- Identify error patterns, repeated operations

### Step 1.5: Auto-Read Session Logs (Optional)

To automatically identify session tasks:

1. **Read recent log files:**
   - `~/.local/share/opencode/log/`
   - Focus on last modified files (last 30 min)
   - Look for .log, .json files

2. **Extract from logs:**
   - Tool calls (bash, edit, write, read, grep, glob)
   - Errors and warnings
   - File paths modified
   - Any "failed", "error", "retry" patterns

3. **Group into tasks:**
   - Sequence of related operations = 1 task
   - Mark which succeeded/failed based on subsequent corrections
   - Identify user corrections: look for "that's wrong", "not correct", etc.

4. **Present to user:**
   "I found these operations from session logs. Is this accurate?"

### Step 2: Analyze Each Task

For each task, determine:
| Field | Question |
|-------|----------|
| Task | What was attempted? |
| Result | Success / Failed / Partial |
| First attempt | Was it correct? If not, what was wrong? |
| Fixes needed | How many iterations to reach correct? |
| Root cause | Why was first attempt wrong? |

### Step 3: 5 Whys Analysis

For each failed/incorrect first attempt, apply 5 Whys:

```
1. Why was it wrong? → [Immediate cause]
2. Why did model choose that? → [Reasoning flaw]
3. Why was that reasoning attractive? → [Cognitive bias]
4. Why wasn't correct path considered? → [Constraint gap]
5. Why didn't constraint catch it? → [Systemic issue]
```

Example:
- Why wrong? Used wrong timestamp
- Why that choice? Confused HHMM vs HH:MM format
- Why attractive? Quick solution, assumed format
- Why not considered? No explicit validation mentioned
- Why not caught? No pre-execution check step

### Step 4: Rate Reasoning

Rate each dimension 1-5:

| Dimension | 1 | 2 | 3 | 4 | 5 |
|-----------|---|---|---|---|---|
| **Initial accuracy** | Always wrong | Often wrong | Sometimes right | Usually right | Always right |
| **Constraint checking** | Ignores constraints | Misses key constraints | Checks some | Checks most | Checks all |
| **Root cause depth** | Stops at surface | Identifies one level | Digs somewhat | Digs deep | System-level understanding |
| **Self-correction** | Never fixes | Rarely fixes | Sometimes fixes | Usually fixes | Always gets it right |
| **Pattern recognition** | No recall | Isolated recall | Some patterns | Good patterns | Strong cross-session patterns |

### Step 5: Identify Corrective Actions

From analysis, derive:
- **Immediate** - Quick fix for this session
- **Process** - Add to workflow (e.g., "verify before execute")
- **Systemic** - Long-term improvement (e.g., "add type checking to skill audit")
- **Learning** - Add to supermemory for future reference

### Step 6: Generate Outputs

#### A. Display Report

Show structured retrospective to user in chat:

```markdown
## Retro: {timestamp}

### Summary
- Tasks: {N} | Success: {N%} | Fixes: {N} | First-try: {N%}

### Tasks Analyzed
| Task | Result | Fixes | Root Cause |
|------|--------|-------|------------|
| Fix supermemory | Failed → Fixed | 2 | Wrong config format |
| Rename file | Correct | 0 | - |

### Reasoning Rating
| Dimension | Score | Notes |
|-----------|-------|-------|
| Initial accuracy | 3/5 | ... |
| Constraint checking | 4/5 | ... |
| Root cause depth | 2/5 | ... |
| Self-correction | 3/5 | ... |
| Pattern recognition | 3/5 | ... |

### 5 Whys Examples
1. **Issue**: Wrong timestamp format
   - Why 1: Used HHMM instead of HH:MM
   - Why 2: Assumed format without checking
   - Why 3: Pattern from previous task
   - Why 4: No explicit validation step
   - Why 5: Time pressure, skipped verification

### Corrective Actions
- [ ] Add format validation before file operations
- [ ] Document timestamp format in AGENTS.md
- [ ] Note: "variable scope confusion" recurring - investigate pattern

### Trends (from previous)
- First-try correctness: {prev}% → {current}%
- Fix iterations: {prev} → {current}
- Recurring issues: {list}

### Supermemory Add
Will add summary to supermemory with tags: retro, session-analysis
```

#### B. Save Markdown

Save to: `~/.local/share/opencode/retro/{timestamp}.md`

> **Note:** Uses XDG Data Directory. Set `$XDG_DATA_HOME` to override, or defaults to `~/.local/share/`.

Create a structured markdown file with all analysis results:
- Summary metrics
- Task breakdown table
- Reasoning ratings
- 5 Whys examples
- Corrective actions
- Recurring issues
- Trends

#### C. Save JSON

Create file: `~/.local/share/opencode/retro/{timestamp}.json`

```json
{
  "timestamp": "2026-05-17_1954",
  "summary": {
    "tasks": 5,
    "success": 4,
    "failed": 1,
    "fixes_required": 3,
    "first_try_correct": 60
  },
  "tasks": [
    {
      "description": "Fix supermemory plugin",
      "result": "failed_then_fixed",
      "fixes": 2,
      "root_cause": "Wrong config format - @latest suffix"
    }
  ],
  "reasoning": {
    "initial_accuracy": 3,
    "constraint_checking": 4,
    "root_cause_depth": 2,
    "self_correction": 3,
    "pattern_recognition": 3
  },
  "five_whys": [
    {
      "issue": "Wrong timestamp format",
      "chain": ["Used HHMM", "Assumed format", "Pattern from before", "No validation", "Time pressure"]
    }
  ],
  "corrective_actions": [
    {"action": "Add format validation", "type": "process"},
    {"action": "Document timestamp format", "type": "learning"}
  ],
  "recurring_issues": ["variable scope confusion"]
}
```

#### D. Save to Supermemory

Add to supermemory (scope: user, type: learned-pattern):

#### E. Calculate Trends

When 2+ previous retros exist:

1. **Read previous JSON files:**
   - Scan `~/.local/share/opencode/retro/` directory for `*.json` files
   - Exclude current timestamp
   - Sort by timestamp (oldest first)

2. **Calculate metrics for last N sessions:**
   - Default N = 5
   - Avg first_try_correct %
   - Avg fixes_required
   - Reasoning average (all 5 dimensions)

3. **Generate trend output:**
```
Trends (last N sessions):
- First-try: {prev}% → {current}% ({direction})
- Fixes: {prev} → {current} ({direction})
- Reasoning: {prev} → {current} ({direction})
```

4. **Include in markdown report** under "Trends" section

5. **Note recurring issues** across sessions:
   - Look for same root causes appearing
   - Note patterns in corrective actions not implemented

---

Add to supermemory (scope: user, type: learned-pattern):

```markdown
Retro {timestamp}: Tasks={N}, First-try={N}%, Fixes={N}, Reasoning={avg}/5. Root causes: {list}. Corrective: {list}. Recurring: {list}
```

## Best Practices

1. **Run at session end** - Best data when session is fresh
2. **Be specific** - "wrong file" is less useful than "wrong variable name"
3. **Count accurately** - Fixes = how many attempts after first failure
4. **Deep 5 Whys** - Stop at "I was tired" is not useful; get to systemic
5. **Track recurring** - Note patterns across sessions for supermemory
6. **Review trends** - Compare outputs weekly to see improvement
7. **Act on actions** - Don't just note corrective actions, implement them

## Querying Past Retros

To find patterns:

```bash
# In supermemory
supermemory search "retro" scope:user limit:10
```

Look for:
- Same root cause appearing multiple times
- Reasoning dimensions consistently low
- Corrective actions never implemented
- Improvement or degradation over time

## Integration with Stow

If using stow to manage ai-toolbox:

```bash
cd ~/git/ai-toolbox
make restow  # updates ~/.config/opencode/skills/retro
```

Or manual:
```bash
cp -r ~/git/ai-toolbox/opencode/skills/retro ~/.config/opencode/skills/
```
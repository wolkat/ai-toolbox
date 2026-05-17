---
description: Run session retrospective using the retro skill - analyze what was done, measure reasoning quality, identify root causes using 5 Whys, and track improvement trends.
---

# Session Retrospective

Analyze the current session to extract learnings, measure reasoning quality, and identify improvement areas.

## Data Directory

```bash
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/retro"
mkdir -p "$DATADIR"
```

Retro reports saved to `~/.local/share/opencode/retro/` (or `$XDG_DATA_HOME/opencode/retro/` if set).

## What to Analyze

### 1. Session Tasks
- What tasks were attempted?
- What worked on first try?
- What required fixes/iterations?
- What was the correct solution?

### 2. User Interactions
- Any corrections you made during session?
- Explicit feedback given?
- Questions asked vs answers provided?

### 3. Tool Usage
- Any errors encountered?
- Repeated operations?
- Unnecessary steps?

## Implementation Steps

### Step 0: Get Timestamp (CRITICAL)
Execute: `date +%Y-%m-%d_%H%M`
- Use this exact timestamp for all filenames
- Do NOT use session start time or context time

### Step 0.5: Ensure Data Directory
```bash
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/retro"
mkdir -p "$DATADIR"
```

### Step 1: Load Retro Skill
Call the skill to get the analysis framework:
```
skill({ name: "retro" })
```

### Step 2: Gather Context
Ask user to describe:
- What tasks were attempted?
- Which succeeded on first try?
- Which needed fixes? (what was wrong → how fixed)
- Any user corrections or clarifications during session?

### Step 2.5: Auto-Read Session Logs (Optional)
If user wants automated analysis:
- Read `~/.local/share/opencode/log/` recent files
- Extract tool calls, errors, file operations
- Group into tasks and present to user for verification

### Step 3: Run Analysis
Follow the retro skill workflow:
- Analyze each task (result, fixes, root cause)
- Apply 5 Whys to failed first attempts
- Rate reasoning dimensions
- Identify corrective actions

### Step 4: Generate Outputs

#### A. Display Report
Present structured retrospective to user with:
- Summary metrics (tasks, success rate, fixes, first-try %)
- Task breakdown table
- Reasoning rating (5 dimensions, 1-5 scale)
- 5 Whys examples
- Corrective actions list
- Trends (if 2+ previous retros exist)

#### B. Save Markdown
Save to `~/.local/share/opencode/retro/{timestamp}.md`

#### C. Save JSON
Save to `~/.local/share/opencode/retro/{timestamp}.json`

#### D. Save to Supermemory
Add summary to supermemory:
```
supermemory(mode: "add", content: "Retro {timestamp}: Tasks={N}, First-try={N}%, Fixes={N}, Reasoning={avg}/5. Root causes: {list}. Corrective: {list}.", type: "learned-pattern", scope: "user")
```

### Step 5: Present to User
- Show the markdown report
- Ask if corrective actions should be added to backlog
- Note any recurring patterns
- Suggest reviewing trends periodically

## Key Questions for User

If session data is unclear, ask:
1. "What was the main task you wanted to accomplish?"
2. "Did anything require multiple attempts?"
3. "Did you correct anything I did?"
4. "What's one thing I could do better next time?"

## Your Task

1. Get current timestamp via `date +%Y-%m-%d_%H%M` (Step 0)
2. Call `skill({ name: "retro" })` to load the analysis framework
3. Ask user about session tasks and outcomes
4. Optionally auto-read session logs (Step 2.5)
5. Apply 5 Whys to any failed first attempts
6. Rate reasoning dimensions
7. Calculate trends if 2+ previous retros exist
8. Generate markdown report (Display to user)
9. Save Markdown to ~/.local/share/opencode/retro/{timestamp}.md
10. Save JSON to ~/.local/share/opencode/retro/{timestamp}.json
11. Add summary to supermemory
12. Present results and ask about corrective actions
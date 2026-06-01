---
description: Run session retrospective using the retro skill - analyze what was done, measure reasoning quality, identify root causes using 5 Whys, and track improvement trends.
---

# Session Retrospective

Analyze the current session to extract learnings, measure reasoning quality, and identify improvement areas.

## Output Location

**Default**: `~/git/docs/learnings/` (project-tracked)

**Fallback**: `~/.local/share/opencode/retro/` (XDG data dir, personal)

If unclear, ask: "Save retro to docs/learnings/ (project-tracked) or XDG (personal)?"
Default to `docs/learnings/`.

## Data Sources

1. **User input** - what happened, what worked/failed
2. **Session logs** - `~/.local/share/opencode/log/`
3. **Supermemory** - previous sessions, patterns
4. **opencode.db** - `~/.local/share/opencode/opencode.db` (SQLite, source of truth)
   - Tables: `session`, `message`, `part` with `json_extract(data, '$.type')` for tool calls

## Implementation Steps

### Step 0: Get Timestamp (CRITICAL)
Execute `date +%Y-%m-%d_%H%M` at the moment of creation. Use this exact timestamp for all filenames. Do NOT use session start time or context time.

### Step 0.5: Ensure Output Directory Exists
```bash
OUT_DIR="$HOME/git/docs/learnings"
mkdir -p "$OUT_DIR"
# Or fallback to XDG:
# OUT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/retro"
# mkdir -p "$OUT_DIR"
```

### Step 1: Load Retro Skill
Call the skill to get the analysis framework:
```
skill({ name: "retro" })
```

### Step 2: Gather Context
Ask user about:
- What tasks were attempted?
- Which succeeded on first try?
- Which needed fixes? (what was wrong → how fixed)
- Any user corrections or clarifications during session?

Or auto-read from opencode.db:
```bash
sqlite3 ~/.local/share/opencode/opencode.db "
  SELECT id, title FROM session
  WHERE time_created > <since>
  ORDER BY time_created DESC
"
```

### Step 2.5: Auto-Read Session Logs (Optional)
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
Present structured retrospective in chat.

#### B. Save Markdown
Save to: `$OUT_DIR/{timestamp}.md`

#### C. Save JSON
Save to: `$OUT_DIR/{timestamp}.json`

#### D. Update Corrective Actions Backlog
For each new corrective action identified:
1. Read `~/git/docs/learnings/corrective-actions-backlog.md`
2. Match against existing open actions
3. If match: append reoccurrence with date + session_id
4. If new: assign CA-### ID and add

#### E. Update Retrospectived Sessions Log
Add new session_ids to `~/git/docs/learnings/retrospectived-sessions.md` to prevent double-counting.

#### F. Update INDEX.md (if using docs/learnings/)
Add link under "Session Retrospectives" section.

#### G. Save to Supermemory
```
supermemory(mode: "add", content: "Retro {timestamp}: Tasks={N}, First-try={N}%, Fixes={N}, Reasoning={avg}/5. Root causes: {list}. Corrective: {list}.", type: "learned-pattern", scope: "user")
```

### Step 5: Present to User
- Show the markdown report
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
2. Ensure output directory exists (Step 0.5)
3. Call `skill({ name: "retro" })` to load the analysis framework
4. Ask user about session tasks and outcomes (or auto-read from opencode.db)
5. Optionally auto-read session logs (Step 2.5)
6. Apply 5 Whys to any failed first attempts
7. Rate reasoning dimensions
8. Calculate trends if 2+ previous retros exist
9. Generate markdown report
10. Save Markdown to `$OUT_DIR/{timestamp}.md`
11. Save JSON to `$OUT_DIR/{timestamp}.json`
12. Update corrective-actions-backlog (Step 4.D)
13. Update retrospectived-sessions (Step 4.E)
14. Update INDEX.md (Step 4.F, if applicable)
15. Add summary to supermemory
16. Present results and ask about corrective actions

---
name: retro
description: Session retrospective skill - analyze OpenCode sessions to extract learnings, measure reasoning quality, and track improvement over time using 5 Whys method and structured KPIs.
triggers: ["/retro", "retro", "retrospective"]
---

# Retro Skill

Analyze OpenCode sessions to extract learnings, measure reasoning quality, and drive continuous improvement.

## When to Use

- User types `/retro` at session end
- User wants to analyze what went wrong in a session
- User wants to track performance trends over time
- Session had multiple iterations/fixes to get to correct solution
- User runs `/retro for last 2 weeks` (covers multiple sessions in batch)
- Recurring issues need reoccurrences logged in backlog

## Data Sources

### Primary Sources
1. **User input** - User describes what happened, tasks attempted, what worked/failed
2. **Session logs** - `~/.local/share/opencode/log/` - tool calls, errors, timing
3. **Supermemory** - Previous sessions, patterns, recurring issues
4. **opencode.db** - `~/.local/share/opencode/opencode.db` (SQLite, source of truth)
   - Tables: `session`, `message`, `part` (with `json_extract(data, '$.type')` for tool calls)
   - Use sqlite3 CLI; query by `session_id`, `time_created`, `agent`, `model`
   - Source of truth for tool counts, errors, agent switches (CA-022)
   - Example: `sqlite3 ~/.local/share/opencode/opencode.db "SELECT id, title FROM session ORDER BY time_created DESC LIMIT 10"`

### What to Extract
- Tasks completed during session
- Tasks that required fixes/iterations
- What the correct solution was
- How many attempts to reach correct solution
- Any user corrections made during session

## Output Location

**Default**: `~/git/docs/learnings/` (project-tracked, in version control)

**Fallback**: `~/.local/share/opencode/retro/` (XDG data dir, personal)

**Rule**: `docs/learnings/` is preferred for retros tied to a project/repo. XDG is preferred for personal/meta retros with no project.

**Decision logic** (per CA-002):
- If working directory has `docs/learnings/` (or in any parent): use it
- If user explicitly says "XDG" or "personal": use XDG
- Otherwise: ask via question tool

## Related Tracking Files

These MUST be updated as part of Step 6:

- `~/git/docs/learnings/corrective-actions-backlog.md` (35 actions, 8 recurring)
- `~/git/docs/learnings/corrective-actions-backlog.json` (tooling)
- `~/git/docs/learnings/retrospectived-sessions.md` (prevents double-counting)
- `~/git/docs/learnings/retrospectived-sessions.json` (tooling)

## Workflow

### Step 0: Determine Output Location

If unclear, ask: "Save retro to docs/learnings/ (project-tracked) or XDG data dir (personal)?"
Default to `docs/learnings/`.

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

4. **Memory-first rule** (CA-003) — When prompt contains "memory" or "docs", query supermemory FIRST
   ```bash
   supermemory mode=search query="<topic>" scope=user
   ```

5. **Repo boundary check** (CA-004) — Before any write/commit
   ```bash
   git -C <parent_dir> rev-parse --git-dir
   ```
   If null: parent is not a git repo, do not commit there.

6. **macOS bash 3.2 compat** (CA-005) — Use here-strings, while-read loops, no `declare -A`
   ```bash
   if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
       echo "WARN: bash 3.2 detected; avoid associative arrays"
   fi
   ```

7. **AGENTS.md conventions** (CA-021) — Before generating scripts, read AGENTS.md for project-specific rules
   - All scripts need `--help` and `-h` flags
   - Use absolute paths in tool calls
   - One concern per bash tool call

Ask user for:
- What tasks were attempted?
- What worked on first try?
- What required fixes? (what was wrong → how was it fixed)
- Any user corrections or clarifications during session?

### Step 1.5: Auto-Read Session Logs and DB (Optional)

To automatically identify session tasks:

1. **Read recent log files:**
   - `~/.local/share/opencode/log/`
   - Focus on last modified files (last 30 min)
   - Look for .log, .json files

2. **Query opencode.db for authoritative data:**
   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db "
     SELECT id, title, time_created, agent, model
     FROM session
     WHERE time_created > <since_timestamp>
     ORDER BY time_created DESC
   "
   ```
   - Count tool calls: `json_extract(data, '$.tool')` grouped by tool
   - Find errors: `json_extract(data, '$.state.status')='error'`
   - Read user prompts: `json_extract(data, '$.text')` from `part` table joined on `message`

3. **Extract from logs:**
   - Tool calls (bash, edit, write, read, grep, glob)
   - Errors and warnings
   - File paths modified
   - Any "failed", "error", "retry" patterns

4. **Group into tasks:**
   - Sequence of related operations = 1 task
   - Mark which succeeded/failed based on subsequent corrections
   - Identify user corrections: look for "that's wrong", "not correct", etc.

5. **Present to user:**
   "I found these operations from session logs and DB. Is this accurate?"

### Step 1.6: Check Retrospectived Sessions Log

Read `~/git/docs/learnings/retrospectived-sessions.md` (or fallback XDG path).
- Skip sessions already covered by past retros
- Note the new session_ids that will be added in Step 6

### Step 1.7: Find New Sessions to Retro

1. Compare opencode.db sessions against `retrospectived-sessions.md`
2. Surface to user: "Found N new sessions since last retro. Cover all or specific ones?"
3. For batch retro of last 2 weeks: query sessions in the time window, deduplicate against log

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

For each new corrective action:
1. Check `corrective-actions-backlog.md` for existing open action with similar description
2. If match found: append to its `reoccurrences[]` array with date + session_id
3. If no match: assign new CA-### ID and add new entry

### Step 6: Generate Outputs

#### A. Display Report

Show structured retrospective to user in chat.

#### B. Save Markdown

Save to: `{output_dir}/{timestamp}.md` where output_dir was determined in Step 0.

#### C. Save JSON

Save to: `{output_dir}/{timestamp}.json`

#### D. Save to Supermemory

Add to supermemory (scope: user, type: learned-pattern).

#### E. Update Corrective Actions Backlog

1. Read `~/git/docs/learnings/corrective-actions-backlog.md` (or fallback path)
2. For each corrective action from this retro:
   - If matches existing open action: append reoccurrence with `{date: YYYY-MM-DD, session_id: <current>}`
   - If new: add new entry with `id: CA-###` and `first_seen: today`
3. Save the updated backlog

#### F. Update Retrospectived Sessions Log

1. Read `~/git/docs/learnings/retrospectived-sessions.md`
2. For each new session_id covered by this retro, add an entry
3. Include: session_id, retro_file, retro_date, session_start, title, model, scope
4. For cross-session retros: list `covers_session_ids` array

#### G. Update INDEX.md

If retro file was added to `docs/learnings/` (not XDG fallback):
1. Read `~/git/docs/INDEX.md`
2. Add link under "Session Retrospectives" section
3. Update "Last Updated" date

#### H. Calculate Trends

When 2+ previous retros exist:

1. **Read previous JSON files** from `~/git/docs/learnings/retros-*.json` and XDG
2. **Calculate metrics for last N sessions:** N=5
   - Avg first_try_correct %
   - Avg fixes_required
   - Reasoning average (all 5 dimensions)
3. **Generate trend output** with direction (up/down/stable)
4. **Include in markdown report** under "Trends" section
5. **Note recurring issues** across sessions from backlog

### Step 7: Present to User

- Show the markdown report
- Ask if corrective actions should be added to backlog (auto-done in Step 6.E)
- Note any recurring patterns
- Suggest reviewing trends periodically

## Best Practices

1. **Run at session end** - Best data when session is fresh
2. **Be specific** - "wrong file" is less useful than "wrong variable name"
3. **Count accurately** - Fixes = how many attempts after first failure
4. **Deep 5 Whys** - Stop at "I was tired" is not useful; get to systemic
5. **Track recurring** - Note patterns across sessions for supermemory
6. **Review trends** - Compare outputs weekly to see improvement
7. **Act on actions** - Don't just note corrective actions, implement them
8. **Use sqlite3 over logs** - opencode.db is authoritative; logs are secondary (CA-022)
9. **Default to docs/learnings/** - Project-tracked is preferred for retros tied to code work
10. **Update backlog AND sessions log** - Three-file coupling prevents drift

## Querying Past Retros

To find patterns:

```bash
# In supermemory
supermemory search "retro" scope:user limit:10

# In docs/learnings
grep -l "first_try_correct" ~/git/docs/learnings/retro-*.json
```

Look for:
- Same root cause appearing multiple times (check backlog `reoccurrences`)
- Reasoning dimensions consistently low
- Corrective actions never implemented
- Improvement or degradation over time

## Integration with Stow

Source: `~/git/projects/ai-toolbox/opencode/skills/retro/`
Installed: `~/.config/opencode/skills/retro/` (via stow symlink)

To update after editing the source:

```bash
cd ~/git/projects/ai-toolbox
make restow-opencode
```

Pre-update validation (recommended before editing):

```bash
~/git/projects/ai-toolbox/scripts/precheck-skill-update.sh --with-db retro \
    ~/git/projects/ai-toolbox/opencode/skills/retro/SKILL.md
```

The precheck script runs 11 read-only checks (PRE-1 through PRE-11) and refuses to proceed on FAIL. Useful when modifying any OpenCode skill.

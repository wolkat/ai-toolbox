@AGENTS.md

## Approach

- Read existing files before writing. Don't re-read unless changed.
- Thorough in reasoning, concise in output.
- Skip files over 100KB unless required.
- No sycophantic openers or closing fluff.
- No emojis or em-dashes.
- Do not guess APIs, versions, flags, commit SHAs, or package names. Verify by reading code or docs before asserting.
- When prompt mentions "memory" or "docs", query supermemory before any other action.
- When criticized, acknowledge immediately. No deflection.
- When user asks for generic output, ask which section before dumping everything.

## Writing Style

- **Data first, interpretation second**: Present logs/timestamps/counts before analysis. Never lead with conclusions.
- **Prove by contrast**: Show broken state and working state side by side rather than asserting.
- **Cut redundancy**: If a table shows the number, don't restate it in prose.
- **Strip internal vocabulary for external audiences**: No CA-ids, S-session labels, or backlog references in public-facing writing.
- **Quantify claims always**: "5x ECONNREFUSED in 90s" not "several connection errors".
- **No preamble, no closing summary**: Start with the first fact. End after the last fact.
- **Tiered detail by audience**: Internal docs get 5-Whys, CA-ids, session IDs. External docs get repro steps, log excerpts, environment tables.

## MEMORY.md Awareness

`MEMORY.md` files at repo roots are per-session artifacts (written by OpenCode at session start), not project source. Do not treat them as canonical documentation.

## Subagent Delegation

IMPORTANT: Prefer subagents over main-context work whenever possible. Offload research, exploration, and parallel analysis to keep context window clean. Each subagent runs in its own context -- verbose output stays out of main conversation.

### When to Delegate

**Use subagents when:**
- Task produces verbose output (search results, logs, file contents) you won't reference again
- Work is self-contained and can return a summary
- Research/exploration that would flood main context
- 3+ independent tasks that can run in parallel

**Stay in main context when:**
- Task needs continuity with prior conversation context (use /fork instead)
- Quick targeted change (under 2 files, under 5 minutes)
- Task requires user approval at multiple steps (subagents can't ask questions)

### Routing Rules

**Parallel dispatch** (all must be true):
- 3+ independent tasks or independent domains
- No shared files between tasks
- Clear file boundaries with no overlap

**Sequential dispatch** (any triggers):
- Tasks have dependencies (B needs output from A)
- Shared files or state (merge conflict risk)
- Unclear scope (need to understand before proceeding)

**Background dispatch**:
- Research or analysis not blocking current work
- Results not needed for immediate next step

### Agent Selection

| Task | Agent | Notes |
|------|-------|-------|
| Find code, locate files | `Explore` | Read-only, fast. Specify breadth: quick/medium/very thorough |
| Small edits (1-2 files) | `cavecrew-builder` | Refuses 3+ file scope |
| Code location queries | `cavecrew-investigator` | Read-only. Returns file:line table |
| Diff/branch/file review | `cavecrew-reviewer` | Severity-tagged findings, no praise |
| Planning 3+ file changes | `Plan` | Returns step-by-step implementation plan |
| General multi-step tasks | `general-purpose` | Catch-all for complex delegation |
| Full app implementation | `apex` | Senior principal engineer mode |
| Continue with full context | `fork` | Shares parent context and prompt cache (cheaper than fresh agent) |

### Prompting Subagents

Brief each subagent like a stranger joining mid-project:
- Include file paths, error messages, constraints, decisions already made
- Delegation prompt = subagent's entire context (nothing else crosses boundary)
- Name expected output format ("return a file:line table", "return JSON with fields X, Y")
- For parallel dispatch: say "these can run in parallel" explicitly

### Custom Agents

Stored in `.claude/agents/` (project) or `~/.claude/agents/` (user). Markdown files with YAML frontmatter.

Key frontmatter fields: `name`, `description` (required), `tools`, `model`, `effort`, `isolation`, `skills`, `maxTurns`, `background`, `hooks`.

Write `description` as a routing rule: describe exact phrases and situations that trigger delegation. Add "Use proactively" to auto-delegate without user asking.

### Anti-patterns

- No same-file parallel edits (merge conflicts)
- No over-fragmentation (1 agent per micro-task wastes setup tokens)
- Combine related micro-tasks into one agent
- Keep approval-gated edits in parent context (subagents cannot ask user questions)
- Background subagents auto-deny permission prompts -- use for read-only work only

## Session Start Protocol

**At start of each session in ~/git/:**

```bash
# Load essential docs (~800 tokens)
.claude/COMMON_MISTAKES.md      # Read FIRST
.claude/QUICK_START.md          # Essential commands
.claude/ARCHITECTURE_MAP.md     # File locations
```

**At task completion:**
- Create completion doc in `.claude/completions/YYYY-MM-DD-task-name.md`

**Never auto-load:** `.claude/completions/`, `.claude/sessions/`, `docs/archive/`

## OpenCode Notes

- Path-based plugins must ref compiled `.js` entry (`dist/index.js`), not TypeScript
- Read-only scanner agents: minimal perms (`read, glob, grep, list, bash, todowrite`), with `edit:deny` and `question:deny`
- Valid agent names: `build`, `plan`, `refactor`, `review`. "general" not valid.
- Terminal manager: cmux (not tmux) -- use `cmux open <path>`

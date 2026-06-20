---
description: Save session learnings to supermemory with auto-summarization
---

# Save Session Learnings

Analyze the current session for key learnings and save them to supermemory automatically.

## What to Extract and Save

### 1. Agent Configuration Changes
- New agents added or configured
- Model changes (e.g., minimax-m2.5-free, deepseek-v4-flash-free)
- Agent mode changes (plan/build)
- Tag as: `agent-config`

### 2. Plugin Installations/Changes
- New plugins installed via bun/npm
- Plugin configurations modified
- Installer commands used
- Tag as: `plugin-install`

### 3. Workflow Learnings
- New commands or slash commands created
- Workflow patterns discovered
- Tool usage insights
- Tag as: `workflow`

### 4. Error Solutions
- Problems encountered and fixed
- Configuration issues resolved
- Workarounds discovered
- Tag as: `error-fix`

### 5. Model Comparisons
- Benchmark results (SWE-Bench, coding, math)
- Pricing differences
- Performance insights
- Tag as: `model-config`

## Implementation Steps

1. **Analyze session** - Look at recent conversation for key events:
   - Agent/model changes
   - Plugin installations
   - Error resolutions
   - New workflows

2. **Extract learnings** - For each distinct insight:
   - Determine appropriate type: `learned-pattern`, `project-config`, `error-solution`, `preference`
   - Include date in content (format: YYYY-MM-DD)
   - Use scope: `user` (global, cross-project)

3. **Classify & promote to AGENTS.md** - For each learning, determine if it belongs in AGENTS.md:

   **Promote to AGENTS.md if:**
   - Applies across multiple projects/repos
   - Is a convention, standard, or best practice
   - Has reusable code examples
   - Would prevent a recurring agent mistake

   **Save to supermemory only if:**
   - Project-specific discovery
   - Ephemeral session context
   - Agent/model configuration changes
   - One-time error solutions

   **For each proposed AGENTS.md addition:**
   - **Deduplicate** — Read existing AGENTS.md, search for similar rules. Merge/amend if already covered.
   - **Size guard** — If AGENTS.md exceeds 200 lines, propose pruning before adding. Suggest moving detailed sections to `docs/` with a brief reference.
   - **Quality gate** — Each rule must pass: "If I remove this, will the agent make a mistake?" If no, it belongs in supermemory only.
   - **Confirmation** — Present proposed changes with line impact. Get explicit user approval before editing AGENTS.md.

4. **Save to supermemory** - Call supermemory tool for each:
   ```
   supermemory(mode: "add", content: "...", type: "...", scope: "user")
   ```

5. **Review AGENTS.md health** - After saving, run a health check:
   - **Line count** — warn if over 200 lines, hard warn at 300+
   - **Byte count** — warn if over 20 KB, hard warn at 30 KB (approaching 32 KB Codex cap)
   - **Section size** — flag any section over 50 lines (move details to `docs/` or a skill)
   - **Stale rule scan** — flag rules that agents consistently follow without instruction (candidates for pruning)
   - **Source audit** — flag rules without a clear reason for existing
   - **Report** — print health summary to user

## AGENTS.md Size Management Guidelines

- **Target**: under 200 lines per file, each section under 50 lines
- **Progressive disclosure**: brief rule in AGENTS.md, details in skills or `docs/`
- **Prune quarterly**: remove rules agents follow correctly without instruction
- **Source tracking**: every rule should have a reason for existing
- **Acid test**: if removing the rule wouldn't cause an agent mistake, it doesn't belong

## Key Date Format

Include date as: `(YYYY-MM-DD)` at start of content or in tags.

## Your Task

1. Scan recent session messages for learnable events
2. For each distinct learning, classify as general rule or specific memory
3. For general rules, propose AGENTS.md additions with deduplication check and size guard
4. Get explicit approval before editing AGENTS.md
5. Save remaining learnings to supermemory with appropriate type
6. Run AGENTS.md health check and report status
7. Report summary: memories saved, rules promoted, AGENTS.md health

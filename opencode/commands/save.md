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

3. **Save to supermemory** - Call supermemory tool for each:
   ```
   supermemory(mode: "add", content: "...", type: "...", scope: "user")
   ```

4. **Summarize** - Report what was saved:
   - Number of memories saved
   - Categories covered
   - Ask if user wants to add anything specific

## Key Date Format

Include date as: `(YYYY-MM-DD)` at start of content or in tags.

## Your Task

1. Scan recent session messages for learnable events
2. For each distinct learning, call supermemory with appropriate type
3. Use scope: "user" for global knowledge
4. Include date in each memory
5. Report summary of what was saved
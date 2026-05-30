---
name: save
description: Save session learnings to Codex memory with auto-summarization. Triggers when user requests to save learnings or end of productive session.
---

# Save Session Learnings

Analyze the current session for key learnings and save them to the Codex memory system.

## When to Use

- User requests to save learnings explicitly ("save this session", "remember this")
- End of a productive session with new discoveries
- After resolving a significant error or configuration issue
- When new workflow patterns are discovered
- Before ending a session with important context for future sessions

## Workflow

### Step 1: Analyze the Session

Scan recent conversation for distinct learnable events:

- Agent or model configuration changes
- Plugin or skill installations
- Error solutions and workarounds
- New workflow patterns or commands
- Project-specific discoveries

### Step 2: Extract Learnings

For each distinct insight:

- Determine the appropriate category from the list below
- Format content with date: `(YYYY-MM-DD)` at start
- Keep content focused and scannable

### Step 3: Write Memory File

Write a structured markdown file to `~/.codex/memories/save-{timestamp}.md`.

Use the current timestamp from `date +%Y-%m-%d_%H%M`.

File structure:

```markdown
# Session Memory

## Date
YYYY-MM-DD

## Learnings

### Category: [category-name]

- [Learning1]
- [Learning 2]

## Tags
- [tag1]
- [tag2]
```

### Step 4: Report Summary

Report to the user:

- Number of learnings saved
- Categories covered
- File location: `~/.codex/memories/save-{timestamp}.md`

## What to extract and save

### 1. Agent Configuration Changes
- New agents added or configured
- Model changes
- Tag as: `agent-config`

### 2. Plugin or Skill Installations
- New plugins or skills installed
- Installation commands used
- Tag as: `plugin-install`

### 3. Workflow Discoveries
- New commands or slash commands created
- Workflow patterns discovered
- Tool usage insights
- Tag as: `workflow`

### 4. Error Solutions
- Problems encountered and fixed
- Configuration issues resolved
- Workarounds discovered
- Tag as: `error-solution`

### 5. Model Configuration
- Model comparisons or benchmarks
- Performance insights
- Tag as: `model-config`

## Key Date Format

Include date as: `(YYYY-MM-DD)` at start of content or in tags.

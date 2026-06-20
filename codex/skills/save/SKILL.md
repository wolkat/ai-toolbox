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

### Step 3: Classify & Promote to AGENTS.md

For each learning, determine if it belongs in AGENTS.md:

**Promote to AGENTS.md if:**
- Applies across multiple projects/repos
- Is a convention, standard, or best practice
- Has reusable code examples
- Would prevent a recurring agent mistake

**Save to memory file only if:**
- Project-specific discovery
- Ephemeral session context
- Agent/model configuration changes
- One-time error solutions

**For each proposed AGENTS.md addition:**
- **Deduplicate** — Read existing AGENTS.md, search for similar rules. Merge/amend if already covered.
- **Size guard** — If AGENTS.md exceeds 200 lines, propose pruning before adding. Suggest moving detailed sections to `docs/` with a brief reference.
- **Quality gate** — Each rule must pass: "If I remove this, will the agent make a mistake?" If no, it belongs in memory file only.
- **Confirmation** — Present proposed changes with line impact. Get explicit user approval before editing AGENTS.md.

### Step 4: Write Memory File

Write a structured markdown file to `~/.codex/memories/save-{timestamp}.md`.

Use the current timestamp from `date +%Y-%m-%d_%H%M`.

File structure:

```markdown
# Session Memory

## Date
YYYY-MM-DD

## Learnings

### Category: [category-name]

- [Learning 1]
- [Learning 2]

## Tags
- [tag1]
- [tag2]
```

### Step 5: Review AGENTS.md Health

After saving, run a health check:

- **Line count** — warn if over 200 lines, hard warn at 300+
- **Byte count** — warn if over 20 KB, hard warn at 30 KB (approaching 32 KB Codex cap)
- **Section size** — flag any section over 50 lines (move details to `docs/` or a skill)
- **Stale rule scan** — flag rules that agents consistently follow without instruction (candidates for pruning)
- **Source audit** — flag rules without a clear reason for existing
- **Report** — print health summary to user

### Step 6: Report Summary

Report to the user:

- Number of learnings saved
- Rules promoted to AGENTS.md (with approval status)
- AGENTS.md health status
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

## AGENTS.md Size Management Guidelines

- **Target**: under 200 lines per file, each section under 50 lines
- **Progressive disclosure**: brief rule in AGENTS.md, details in skills or `docs/`
- **Prune quarterly**: remove rules agents follow correctly without instruction
- **Source tracking**: every rule should have a reason for existing
- **Acid test**: if removing the rule wouldn't cause an agent mistake, it doesn't belong

## Key Date Format

Include date as: `(YYYY-MM-DD)` at start of content or in tags.

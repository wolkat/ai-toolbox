---
name: skill-audit
description: Cross-check new OpenCode skills against existing installed skills before installation. Analyze skill purpose, functionality overlap, use cases, and present conflicts, redundancies, and benefits. Wait for user confirmation before proceeding with installation. Use when user requests to install a new OpenCode skill or asks about skill compatibility.
---

# Skill Audit Skill

Systematically analyze and safely install OpenCode skills by cross-referencing against existing configuration.

## When to Use

- User requests to install a new OpenCode skill
- User asks about skill compatibility or conflicts
- User wants to understand what a skill does before installing
- User wants to audit existing skills for overlap

## Workflow

### Step 1: Identify the Skill

Determine the skill to install:
- Extract skill name from GitHub URL (e.g., `dmmulroy/cloudflare-skill` → `cloudflare`)
- Check if it's a skill vs plugin (plugins go to opencode.json, skills go to skills/)
- Note the source: GitHub repo, npm package, or manual

### Step 2: Gather Current Skills

Read and analyze existing OpenCode skills:

**Global skills:**
- Read all SKILL.md files in `~/.config/opencode/skills/*/`
- List all available skills with their names and descriptions

**Project-level skills:**
- Check for `.opencode/skills/*/SKILL.md` in current directory
- Check for `.claude/skills/*/SKILL.md` (Claude-compatible)

**Commands (may include skill references):**
- Check `~/.config/opencode/command/*.md`
- Note any commands that load specific skills

### Step 3: Research the New Skill

Fetch information about the new skill:
- Read the GitHub README or SKILL.md
- Extract: name, description, use cases, trigger conditions
- Note any referenced files or subdirectories
- Check for dependencies or prerequisites

### Step 4: Cross-Check Analysis

Compare the new skill against existing skills:

**Purpose Analysis:**
- What does this skill do?
- What specific use cases does it cover?

**Overlap Analysis:**
- Check for functional overlap with existing skills
- Look for similar keywords in descriptions
- Identify if skills serve the same purpose

**Trigger Analysis:**
- What activates this skill? (skill tool, keywords, commands)
- Does it conflict with any existing triggers?

**Benefit Analysis:**
- What unique value does this skill add?
- Is there redundancy with existing skills?

### Step 5: Present Findings

Create a clear analysis report for the user:

```
## Skill Audit: {skill-name}

### Current Skills
- {skill1}: {description}
- {skill2}: {description}
- ...

### New Skill Details
- Name: {name}
- Source: {GitHub repo / npm / manual}
- Purpose: {what it does}
- Use cases: {when to use}

### Overlap Assessment
| Existing Skill | Overlap Type | Notes |
|----------------|--------------|-------|
| {skill1} | High/Medium/Low | {specific overlap} |
| {skill2} | None | {reason} |

### Redundancy Check
- Is there a skill that already does this? Yes/No
- If yes, which one and why keep/replace?

### Benefits
- {unique benefit 1}
- {unique benefit 2}

### Installation Plan (if approved)
- Copy skill files to ~/.config/opencode/skills/{name}/
- Or: Run npx skills add {repo}
- Verify skill loads: skill({ name: '{name}' })
```

### Step 6: Get Confirmation

Present the analysis and ask for confirmation:
- Summarize key findings
- Highlight any overlaps or concerns
- Ask: "Proceed with installation?"
- Wait for explicit yes/no before continuing

### Step 7: Install the Skill

After confirmation:

**Via npx CLI:**
```bash
npx skills add https://github.com/{owner}/{repo}
```

**Manual install:**
```bash
# Global install
mkdir -p ~/.config/opencode/skills/{skill-name}/
cp -r {skill-files} ~/.config/opencode/skills/{skill-name}/

# Or use install script if provided
curl -fsSL https://raw.githubusercontent.com/{owner}/{repo}/main/install.sh | bash
```

**Project-level install:**
```bash
mkdir -p .opencode/skills/{skill-name}/
cp -r {skill-files} .opencode/skills/{skill-name}/
```

### Step 8: Post-Install Verification

After installation:
- Verify SKILL.md exists in the target directory
- Test loading: `skill({ name: '{name}' })`
- Note that skills don't require restart - they load on demand

## Best Practices

1. **Always cross-check** - Never install without checking existing skills
2. **Check for redundancy** - Skills can overlap, avoid duplicates
3. **Get explicit confirmation** - Don't proceed without user approval
4. **Document the skill** - Note what it does for future reference
5. **Test loading** - Verify skill can be invoked
6. **Save learnings** - Use supermemory to record skill installations

## Skill Discovery Locations

OpenCode searches these locations (in order):
1. `.opencode/skills/{name}/SKILL.md` (project-level)
2. `~/.config/opencode/skills/{name}/SKILL.md` (global)
3. `.claude/skills/{name}/SKILL.md` (Claude-compatible, project)
4. `~/.claude/skills/{name}/SKILL.md` (Claude-compatible, global)
5. `.agents/skills/{name}/SKILL.md` (OpenCode agents format)

## Skill vs Plugin

| Aspect | Skill | Plugin |
|--------|-------|--------|
| Install location | skills/ directory | opencode.json plugin array |
| Activation | `skill({ name: '...' })` | Automatic via hooks |
| Loading | On-demand | Startup |
| Configuration | None (self-contained) | May need config |
| Update method | Replace files | Update npm package |

## Common Skill Sources

- GitHub repos with SKILL.md (e.g., cloudflare-skill)
- npx skills CLI: `npx skills add {url}`
- Claude Code compatible skills
- Custom-built skills

## Verification Commands

```bash
# List installed skills
ls ~/.config/opencode/skills/

# Verify specific skill
ls ~/.config/opencode/skills/{name}/

# Test loading (in OpenCode)
skill({ name: '{name}' })
```
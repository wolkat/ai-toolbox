---
name: plugin-audit
description: Analyze new OpenCode plugins for conflicts with existing configuration before installation. Triggers when user requests plugin install or compatibility check.
---

# Plugin Audit Skill

Systematically analyze and safely install OpenCode plugins by cross-referencing against existing configuration.

## When to Use

- User requests to install a new OpenCode plugin
- User asks about plugin compatibility or conflicts
- User wants to understand what a plugin does before installing

## Workflow

### Step 1: Identify the Plugin

Determine the plugin to install:
- Extract npm package name from user's request
- If GitHub URL, convert to npm package name (e.g., `antongulin/opencode-skill-creator` → `opencode-skill-creator`)
- For scoped packages (e.g., `@spoons-and-mirrors/subtask2`), preserve the scope

### Step 2: Gather Current Configuration

Read and analyze the existing OpenCode setup:

**Global config:**
- Read `~/.config/opencode/opencode.json` and `~/.config/opencode/opencode.jsonc`
- Extract all currently installed plugins
- Note any custom agents, permissions, and MCP servers

**Local project config:**
- Check for `.opencode/opencode.json` or `.opencode/opencode.jsonc` in current directory
- Note project-specific plugins

**Installed packages:**
- Check `~/.config/opencode/node_modules/` for installed packages
- Look at `~/.config/opencode/package.json` for dependencies

### Step 3: Research the New Plugin

Fetch information about the new plugin:
- Read the GitHub README (e.g., `https://github.com/{owner}/{repo}`)
- Identify what hooks the plugin uses (`tool.execute.before`, `command.handler`, etc.)
- Note any custom commands or tools it registers
- Check for required post-install steps (installer commands, config creation)
- Identify any agent or model dependencies

### Step 4: Cross-Check Analysis

Compare the new plugin against existing setup:

**Hook Analysis:**
- Check which hooks the new plugin uses
- Identify any existing plugins using the same hooks
- Flag potential hook overlap conflicts

**Command Analysis:**
- List custom commands the new plugin adds
- Check for command name conflicts with existing commands

**Model/Agent Analysis:**
- Identify any agent overrides or model requirements
- Check if existing agents might conflict

**Benefit Analysis:**
- Identify what the new plugin adds
- Compare to existing functionality
- Summarize net benefit

### Step 5: Present Findings

Create a clear analysis report for the user:

```
## Plugin Audit: {plugin-name}

### Current State
- Global plugins: {list}
- Local plugins: {list}

### New Plugin Details
- Package: {npm-name}
- Hooks used: {list}
- Commands: {list}
- Post-install: {yes/no, details}

### Risk Assessment
| Factor | Status | Notes |
|--------|--------|-------|
| Hook overlap | Low/Medium/High | {details} |
| Command conflict | Low/Medium/High | {details} |
| Model interaction | Low/Medium/High | {details} |

### Benefits
- {benefit 1}
- {benefit 2}

### Installation Plan
1. Add to plugin array in opencode.json
2. Run: {install command if needed}
3. Restart OpenCode
```

### Step 6: Get Confirmation

Present the analysis and ask for confirmation before proceeding:

- Summarize key findings
- Ask: "Proceed with installation?"
- Wait for explicit yes/no before continuing

### Step 7: Install the Plugin

After confirmation:

**For npm packages:**
1. Edit `~/.config/opencode/opencode.json` to add plugin to the plugin array
2. Run `cd ~/.config/opencode && bun add {plugin-name}@latest`
3. Check for post-install steps (installer commands, config files)
4. Report success/failure

**For local plugins:**
1. Copy plugin files to appropriate location
2. Add reference to opencode.json
3. Document any required setup

### Step 8: Post-Install Verification

After installation:
- Verify plugin loads (check for errors in logs)
- If skill was installed, verify skill file exists in `~/.config/opencode/skills/`
- Remind user to restart OpenCode
- Note any follow-up actions required

## Best Practices

1. **Always cross-check** - Never install without analyzing existing config first
2. **Document findings** - Create clear reports for the user
3. **Get explicit confirmation** - Don't proceed without user approval
4. **Check post-install** - Many plugins need additional steps after adding to config
5. **Verify installation** - Confirm the plugin actually loads
6. **Save learnings** - Use supermemory to record installation patterns

## Common Hooks to Check

- `tool.execute.before` - Runs before tool execution
- `tool.execute.after` - Runs after tool execution
- `command.handler` - Handles slash commands
- `config.loaded` - Runs after config loads

## Installation Command Reference

| Package Manager | Command |
|----------------|---------|
| bun | `bun add {package}@latest` |
| npm | `npm install {package}@latest` |
| yarn | `yarn add {package}@latest` |

## Post-Install Patterns

- **No post-install**: Plugin loads automatically via hook
- **Installer command**: Run `npx {package} install` or `bunx {package} install`
- **Config creation**: Create additional config files (e.g., `oh-my-opencode-slim.json`)
- **Skill copy**: Verify SKILL.md exists in `~/.config/opencode/skills/`
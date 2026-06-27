# ai-toolbox

This repo contains configs for AI coding agents (OpenCode, Claude Code, etc.).

## Directory Purpose

| Directory | Purpose |
|-----------|---------|
| `opencode/skills/` | OpenCode skills (invoke with `skill({ name: "..." })`) |
| `opencode/commands/` | OpenCode slash commands (use with `/command-name`) |
| `opencode/agents/` | Custom OpenCode agents |
| `opencode/plugins/` | OpenCode plugin files |
| `claude/skills/` | Claude Code skills |
| `claude/commands/` | Claude Code commands |
| `scripts/` | Shell scripts for automation |
| `hooks/` | Git/tool hooks |
| `templates/` | Templates for new skills/agents |

## Quick Reference

### OpenCode Skills Location
Global: `~/.config/opencode/skills/`
Project: `.opencode/skills/`

### OpenCode Commands Location
Global: `~/.config/opencode/command/`
Project: `.opencode/command/`

### Claude Code Skills Location
Global: `~/.claude/skills/`
Project: `.claude/skills/`

## Standards

### Timestamp Format

When creating files with timestamps:

1. **Always use real current time:** Execute `date +%Y-%m-%d_%H%M` at the moment of creation
2. **Never use session context time** (which may be stale)
3. **Format:** `YYYY-MM-DD_HHMM` (e.g., `2026-05-17_2028`)
4. **Use this format for:**
   - Retro report filenames (`data/{timestamp}.json` and `.md`)
   - Log file rotations
   - Any session artifacts

## Git Commit Rules

All commits in this repo (and all repos where AI assists) must follow these rules:

### 1. Atomic Commits
- One logical change per commit
- If you need "and" in the commit message, split it into multiple commits

### 2. Conventional Commits Format
```
type(scope): description

[optional body]

[optional footer]
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`, `ci`

### 3. Co-Author Attribution (CRITICAL)

**Rule:** Always use the model declared in the system prompt, **never** the model from `opencode.json` provider config.

| Wrong | Correct |
|-------|---------|
| `Co-authored-by: opencode (minimax-m2.5-free)` | `Co-authored-by: opencode (kimi-k2.6)` |

**Why:** `opencode.json` configures which model the OpenCode app calls for chat. The `Co-authored-by` line must reflect the **actual model generating the code** — which is declared in the system prompt at session start. These are often different.

**How to determine the correct model:**
- Check the system prompt line: `You are powered by the model named X`
- Or check: `The exact model ID is Y`
- Current model: **kimi-k2.6** (exact: `opencode-go/kimi-k2.6`)

### 4. Required Trailers
```
Signed-off-by: <your name>
Co-authored-by: opencode (<actual model>)
```

### 5. Enforcement
Use the helper tools:
```bash
# Quick commit with auto-generated co-author
gac "feat: add new feature"

# Or use the script directly
ai-toolbox/scripts/commit-with-coauthor.sh "feat: add new feature"
```

Or set up globally once:
```bash
bash ai-toolbox/scripts/setup-coauthor.sh
```

## Maintenance

To update skills from this repo to your local config:

```bash
# Update OpenCode skills
cp -r ai-toolbox/opencode/skills/* ~/.config/opencode/skills/

# Update OpenCode commands
cp ai-toolbox/opencode/commands/*.md ~/.config/opencode/command/
```

## Preferred CLI Tools

Prefer these tools over legacy alternatives for better performance and output quality:

| Task | Prefer | Over | Fallback |
|------|--------|------|----------|
| File search | `fd` | `find` | `find` (if fd unavailable) |
| JSON processing | `jq` | `grep/sed` | Python `json.tool` |
| YAML processing | `yq` | manual parsing | Python `yaml` module |
| Directory listing | `eza` | `ls` | `ls` (if eza unavailable) |
| File viewing | `bat` | `cat` | `cat` (if bat unavailable) |
| Directory tree | `tree` | manual `find` | `find` + formatting |
| Smart navigation | `zoxide` (`z`) | `cd` + history | `cd` |
| Fuzzy search | `fzf` | manual grep | `grep` + manual selection |
| Git diffs | `delta` (auto) | default pager | default pager |
| Markdown preview | `glow` | `cat` | `cat` |
| HTTP requests | `http` (httpie) | `curl` | `curl` |
| Code statistics | `tokei` | `cloc`, `scc` | `wc -l` |
| Simplified man | `tldr` | `man` | `man` |

**When writing scripts:** Check tool availability with `command -v <tool>` before using. Provide fallbacks for portability.

**Full documentation:** `docs/cli-tools-2026-06-20.md` (install script, examples, troubleshooting)
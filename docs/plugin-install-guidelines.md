# OpenCode Plugin Installation Guidelines

Reference document for safely installing OpenCode plugins. Based on real failures from May 2026.

---

## 1. Pre-Install Checklist

Run these checks before any plugin install:

```bash
# Verify package exists on npm
npm view <package-name> version

# Check peer dependencies
npm view <package-name> peerDependencies

# Check if it's a scoped package (may need @owner/ prefix)
npm search <package-name> --limit 5

# For GitHub repos, check if published to npm
npm search <repo-name> --limit 5
```

**Why this matters:** Many OpenCode plugins are GitHub-only (instruction files) and not published to npm. Others have scoped names like `@ramarivera/opencode-model-announcer` that differ from the repo name.

---

## 2. Package Name Verification Rules

### Rule 1: Check Registry First
| What You Know | What to Verify | Example |
|---------------|---------------|---------|
| GitHub repo `JRedeker/opencode-shell-strategy` | Is it on npm? | **No** — it's GitHub-only |
| Repo `ramarivera/opencode-model-announcer` | Is it scoped? | **Yes** — `@ramarivera/opencode-model-announcer` |
| Plugin name `oh-my-opencode-slim/tui` | Is subpath valid? | **No** — not a real package |

### Rule 2: Scoped vs Unscoped
- Unscoped: `opencode-snip`, `opencode-mem`
- Scoped: `@tarquinen/opencode-dcp`, `@franlol/opencode-md-table-formatter`, `@ramarivera/opencode-model-announcer`
- **Always** check `npm view` if unsure — unscoped names often 404

### Rule 3: No Subpaths
```bash
# WRONG: bun add opencode-worktree/schedule
# WRONG: bun add oh-my-opencode-slim/tui
# CORRECT: bun add opencode-worktree
# CORRECT: bun add oh-my-opencode-slim
```

---

## 3. Plugin vs Instruction vs Local JS

Know which config array to use:

| Type | Example | Config Array | Install Method |
|------|---------|-------------|----------------|
| **npm plugin** | `opencode-snip`, `@ramarivera/...` | `plugin` array | `bun add <name>` |
| **Instruction file** | `shell-strategy.md` | `instructions` array | Clone repo manually |
| **Local JS plugin** | `./plugins/agent-logger.js` | `plugin` array | Copy file manually |

### Instruction Plugin Example
```bash
# 1. Clone to plugin directory
git clone https://github.com/JRedeker/opencode-shell-strategy.git \
  ~/.config/opencode/plugin/shell-strategy

# 2. Add to opencode.json "instructions" array
{
  "instructions": [
    "~/.config/opencode/profile.json",
    "~/.config/opencode/plugin/shell-strategy/shell_strategy.md"
  ]
}
```

**Common mistake:** Putting instruction file paths in the `plugin` array. This causes "Plugin export is not a function" errors.

---

## 4. Safe Installation Order

Follow this order exactly:

1. **Verify package name** — `npm view <name> version`
2. **Check peer dependencies** — `npm view <name> peerDependencies`
3. **Determine plugin type** — npm? GitHub-only? Local JS?
4. **Add to correct config array** — `plugin` or `instructions`
5. **Install the package** — `cd ~/.config/opencode && bun add <name>@latest`
6. **Verify in node_modules** — `ls node_modules/<name>/`
7. **Restart OpenCode** — Check logs for load errors

---

## 5. Common Failure Patterns & Fixes

| Error | Root Cause | Fix |
|-------|-----------|-----|
| `GET registry.npmjs.org/... 404` | Wrong package name or GitHub-only | Check scoped name; check if GitHub-only |
| `NpmInstallFailedError: unable to resolve dependency tree` | Peer dependency conflict | Check `npm view <pkg> peerDependencies`; install missing peers |
| `Cannot find module '/path/to/plugin.js'` | Wrong path in config | Verify relative path from `~/.config/opencode/` |
| `Plugin export is not a function` | Instruction file in `plugin` array | Move to `instructions` array |
| `opencode-supermemory` fails to load | Missing `@opencode-ai/plugin` peer dep | Ensure peer dependency is installed |
| `opencode-ralph-wiggum` peer dep error | Missing `@opencode-ai/plugin` | Install peer dependency first |
| Stale version despite `@latest` | Cache in `~/.cache/opencode/` | Clear cache: `rm -rf ~/.cache/opencode/node_modules/<pkg>` |

---

## 6. Rollback Procedure

If installation fails:

```bash
# 1. Remove from config
#    Edit ~/.config/opencode/opencode.json
#    Remove entry from plugin or instructions array

# 2. Uninstall package
cd ~/.config/opencode
bun remove <package-name>

# 3. Clear cache (if stale version suspected)
rm -rf ~/.cache/opencode/node_modules/<package-name>

# 4. Restart OpenCode
#    Check logs: tail -f ~/.local/share/opencode/log/$(ls -t ~/.local/share/opencode/log/ | head -1)
```

---

## 7. Quick Reference Commands

```bash
# Pre-install verification
npm view <pkg> version              # Check existence
npm view <pkg> peerDependencies     # Check requirements
npm info <pkg> | head -20           # Full package info

# Install
bun add <pkg>@latest                # Install to ~/.config/opencode/

# Verify
ls ~/.config/opencode/node_modules/<pkg>/
cat ~/.config/opencode/package.json | grep <pkg>

# Cache management
rm -rf ~/.cache/opencode/node_modules/<pkg>

# Log check
tail -f ~/.local/share/opencode/log/$(ls -t ~/.local/share/opencode/log/ | head -1)
```

---

## 8. Real Failures Log (May 2026)

| Plugin | Expected | Actual | Lesson |
|--------|----------|--------|--------|
| `opencode-shell-strategy` | npm package | GitHub-only instruction file | Always check registry first |
| `opencode-model-announcer` | Unscoped | `@ramarivera/opencode-model-announcer` | Verify scoped vs unscoped |
| `oh-my-opencode-slim/tui` | Valid subpath | Not a real npm package | No subpaths in package names |
| `opencode-supermemory` | Auto-install | Peer dep conflict | Check peerDependencies before install |
| `graphify.js` | Loads correctly | `Cannot find module` | Verify relative paths carefully |

---

Last updated: 2026-05-17

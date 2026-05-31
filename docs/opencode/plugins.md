# Plugins

## Plugin Types

- **npm-published** — listed by name in the `plugin` array; auto-installed by
  OpenCode's background installer.
- **Path-based** — referenced as a file path; must be compiled `.js`.
- **Instruction-only** — markdown files listed in the `instructions` array;
  must be cloned or created manually.

## Adding an npm-published plugin

```bash
cd ~/.config/opencode && bun add <package-name>
```

Then add the package name to the `plugin` array in `opencode.json`.

## Adding a path-based plugin

Path must reference **compiled `.js`**, not `.ts` source.

Correct:

```json
"/Users/katops/git/projects/opencode-skill-hush/dist/index.js"
```

Wrong:

```json
"/Users/katops/git/projects/opencode-skill-hush/src/index.ts"
```

The `"main"` field in a plugin's `package.json` is for npm consumers, not for
OpenCode. Before adding, check how existing path-based plugins are referenced:

```json
"./plugins/agent-logger.js"
"/Users/katops/git/.opencode/plugins/graphify.js"
```

## Applying changes

A simple OpenCode restart may not be enough. Start a **fresh session**:

```bash
opencode   # new session ID, reloads plugins
```

`opencode -c` or `opencode -s <id>` resumes an existing session and will
**not reload** plugins.

If plugins still don't load, clear the cache:

```bash
rm -rf ~/.cache/opencode/packages/
cd ~/.config/opencode && bun install
```

## Package Manager

Use **bun exclusively** for `~/.config/opencode/`.

Do NOT use `npm install` — it creates `package-lock.json`, which conflicts
with `bun.lock` and causes OpenCode's background installer to fail silently
(caches only a subset of plugins).

## Troubleshooting load failures

1. Check logs:
   ```bash
   cat ~/.local/share/opencode/log/<latest>.log
   ```
2. Search for failures:
   ```bash
   grep -i "loading plugin\|NpmInstallFailedError" ~/.local/share/opencode/log/<latest>.log
   ```
3. Verify `package.json` and `opencode.json` list the same plugins.
4. If using `oh-my-opencode-slim`, check its dedicated log.
5. Confirm active agent: `grep "agent=" ~/.local/share/opencode/log/<latest>.log`
6. Fix stale lockfile:
   ```bash
   rm -f ~/.config/opencode/package-lock.json
   rm -rf ~/.cache/opencode/packages/
   cd ~/.config/opencode && bun install
   ```

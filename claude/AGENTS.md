# AGENTS.md

Multi-project workspace. Root `~/git/` is NOT a git repo -- only subdirectories have their own repos.

## Structure

- `projects/` -- repos Kat develops (lifebinder, Comber, ai-toolbox, opencode-skill-hush)
- `pull/` -- external/reference repos (cloned for inspection, not modified)
- `docs/` -- shared docs
- `scripts/` -- workspace-level utility scripts
- `env-snapshot/` -- macOS environment reproducibility tooling

## Commands

```bash
# env-snapshot
make snapshot                    # dump Homebrew, pip, npm, pipx, configs, macOS prefs
make restore SNAPSHOT=<date>     # install everything on new machine (interactive)
make diff                        # changes between last two snapshots
make verify                      # check installed versions against latest snapshot
```

## Git Rules

**Never run git from `~/git/`** -- run from specific project subdir. Before write/commit, verify target inside git repo: `git -C <path> rev-parse --git-dir`. If fail, stop.

### Conventional Commits

```
type(scope): description    # under 50 chars, imperative mood, no period
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`, `ci`

- One logical change per commit. If need "and" in message, split.
- AI-assisted: add `Signed-off-by: wolkat` + `Co-authored-by: <tool> (<model>)`
- Always review AI code before push.

## Tool Constraints

### Paths
- **Absolute paths only** -- no `~/`, no `$HOME`, no env vars in tool path params.

### Bash
- **One concern per call** -- separate unrelated commands into individual calls.
- **Interactive prompts to stderr** (`>&2`). Data output to stdout.
- **Use `printf` not `echo`** for escape sequences and cross-platform reliability.

### Shell Compatibility
Target bash 3.2 (macOS). No associative arrays, no `<(cmd)`, no `mapfile`. Use here-strings, while-read loops, positional params.

## Preferred CLI Tools

| Task | Prefer | Over | Fallback |
|------|--------|------|----------|
| File search | `fd` | `find` | `find` |
| JSON | `jq` | `grep/sed` | Python `json.tool` |
| YAML | `yq` | manual parsing | Python `yaml` |
| Directory listing | `eza` | `ls` | `ls` |
| File viewing | `bat` | `cat` | `cat` |
| Directory tree | `tree` | manual `find` | `find` |
| Navigation | `zoxide` (`z`) | `cd` | `cd` |
| Fuzzy search | `fzf` | manual grep | `grep` |
| Git diffs | `delta` (auto) | default pager | default pager |
| Markdown | `glow` | `cat` | `cat` |
| HTTP | `http` (httpie) | `curl` | `curl` |
| Code stats | `tokei` | `cloc` | `wc -l` |
| Man pages | `tldr` | `man` | `man` |

In scripts: check availability with `command -v <tool>`. Provide fallbacks.

## Code Quality

- Lint/format before commit, test before push
- Prefer TypeScript over JavaScript for new projects; type hints in Python
- Refactor when files exceed ~200 lines
- Meaningful names over comments; comments only for complex logic
- Guard clauses and early returns; max nesting depth 3

## Scripting Conventions

Every script MUST support `-h`/`--help`. Target bash 3.2. Positive opt-in flags. Interactive menus need `[0] Cancel`. Validate args before `shift`. User messages to stderr.

Guard optional sources: `[[ -f "$path" ]] && source "$path"`.

## Boundaries

### Always
- Read existing files before modifying
- Verify paths are inside git repos before commits
- Run tests after changes

### Ask First
- Destructive operations (rm -rf, force push, drop tables)
- Changes to CI/CD pipelines
- Adding new dependencies

### Never
- Run git operations from `~/git/` root
- Expose secrets, API keys, or credentials in code
- Edit files in `.slim/clonedeps/repos/` (read-only deps)
- Treat `MEMORY.md` files as canonical documentation

## Directory Exclusions

Exclude from context-file generation, dirmap listings, AI traversal:
`.agents`, `.agents-disabled`, `.claude`, `_bmad`, `_bmad-output`, `.slim`, `.opencode`, `.omo`, `.sisyphus`, `.logs`

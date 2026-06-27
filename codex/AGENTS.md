# Global Codex Instructions

These instructions apply to all Codex sessions.

## Approach
- Read existing files before writing. Don't re-read unless changed.
- Thorough in reasoning, concise in output.
- Skip files over 100KB unless required.
- No sycophantic openers or closing fluff.
- No emojis or em-dashes.
- Do not guess APIs, versions, flags, commit SHAs, or package names. Verify by reading code or docs before asserting.

## Git Commit Rules

All commits must follow these rules:

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

### 3. Subject Line
- Use imperative mood: "Add feature" (not "Added", "Adding")
- Keep under 50 characters
- No period at end
- Describe outcome, not activity

### 4. AI-Assisted Commits
- Always add both AI tool/model and yourself:
  ```
  feat: description

  Signed-off-by: wolkat
  Co-authored-by: codex (model-name)
  ```

## Shell Non-Interactive Strategy

Assume CI=true non-interactive environment. No TTY available.

- Always use non-interactive flags: `-y`, `--yes`, `--non-interactive`, `-f`, `--force`
- Never use: `vim`, `nano`, `less`, `more`, `man`, `git add -p`, `git rebase -i`
- Use `git commit -m "msg"` not bare `git commit`
- Use `git --no-pager log` not `git log`
- Use `npm init -y` not `npm init`
- Use `npm install --yes` not `npm install`
- Prefer file tools over `sed`, `echo`, `cat`

## Project Conventions

- TypeScript with `verbatimModuleSyntax`: use `import type` for type-only imports
- TailwindCSS v4: NO `tailwind.config.js`, use `@theme` in CSS
- React Router v7.13.1 with `ssr: false` — client-side only
- Polish (`pl.json`) is source of truth for i18n

<!-- codebase-memory-mcp:start -->
# Codebase Knowledge Graph (codebase-memory-mcp)

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.
ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

## Priority Order
1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `query_graph` — run Cypher queries for complex patterns
5. `get_architecture` — high-level project summary

## When to fall back to grep/glob
- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results

## Examples
- Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
- Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
- Read source: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`
<!-- codebase-memory-mcp:end -->

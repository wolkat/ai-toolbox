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

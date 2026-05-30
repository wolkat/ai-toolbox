# Contributing to ai-toolbox

Thanks for considering contributing.

## How Can I Contribute?

### Reporting Bugs

Open an issue with:

- A clear, descriptive title
- What you tried and what happened
- Expected behavior
- Relevant configuration or tool versions

### Suggesting Features

Open an issue describing the problem you want to solve and your proposed solution.

### Submitting Code

1. Fork the repo or create a branch from `main`.
2. Run `make check` to verify the package structure is valid.
3. Open a pull request with a clear description of what changed and why.

## Commit Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add Codex agent for TUI code review
fix: correct stow target path for copilot hooks
docs: update installation instructions
```

Keep the subject under 50 characters, imperative mood, no period.

All commits must carry a `Signed-off-by` trailer (yours) and `Co-authored-by` trailers for any AI tools used.

## Development Setup

Prerequisites:

- GNU stow (for symlink installation)
- The agent tools you intend to configure (OpenCode, Claude Code, Codex CLI, etc.)

To verify your changes:

```bash
make check
make status
```

## Code of Conduct

This project is governed by the [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold it.

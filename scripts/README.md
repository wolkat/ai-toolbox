# ai-toolbox Scripts

Utility scripts for AI coding agent tooling and automation.

## Scripts

| Script | Purpose | Key Functions |
|--------|---------|---------------|
| `add-zsh-alias.sh` | Adds a zsh alias to ~/.zshrc with validation | validate_alias(), add_alias(), reload_shell() |
| `commit-with-coauthor.sh` | Git commit with auto-generated co-author attribution | commit_with_coauthor(), get_model_name() |
| `install-hooks.sh` | Installs git hooks from the hooks/ directory | install_hooks(), validate_hooks() |
| `lint-skill.sh` | Lints OpenCode skill markdown files | lint_skill(), check_required_sections() |
| `setup-coauthor.sh` | One-time setup for co-author git config | setup_coauthor_config() |
| `todo-scan.sh` | Scans repos under a root for unfinished work (uncommitted, stashed, TODOs, stale branches, backlog files, checkboxes, status-tracked plans) | discover_repos(), scan_uncommitted(), scan_code_todos(), scan_stale_branches(), find_backlog_files(), scan_checkboxes(), scan_status_tracked() |
| `track-tool-usage.sh` | Surveys CLI tool usage from shell history with dependency resolution | parse_history(), resolve_binary(), categorize_source(), resolve_deps(), generate_report() |
| `track-kpi.sh` | Logs AI skill invocations and outcomes for effectiveness reporting | log_entry(), generate_report() |
| `verify-plugin.sh` | Validates OpenCode plugin configurations | verify_plugin(), check_permissions() |

#!/usr/bin/env bash
# precheck-skill-update.sh - Pre-update validation for OpenCode skills
#
# Runs 11 read-only checks before editing an OpenCode skill to verify
# the environment and detect stale references. Returns exit 0 if all
# pass, exit 1 if any [FAIL] checks.

set -uo pipefail

PROGNAME=$(basename "$0")
warnings=0
failures=0
checks_run=0

# Defaults
WITH_DB=0
DRY_RUN=0
SKILL_NAME=""
SOURCE_PATH=""
REPO_PATH="$HOME/git/projects/ai-toolbox"
TARGET_PATH="$HOME/.config/opencode"

usage() {
    cat <<EOF
Usage: $PROGNAME [-h|--help] [--with-db] [--dry-run] <skill-name> <source-path>

Pre-update validation for OpenCode skills. Run before editing a skill
to verify environment and detect stale references.

Arguments:
  skill-name      Name of the skill (e.g., 'retro')
  source-path     Absolute path to the source SKILL.md

Options:
  --with-db       Run opencode.db schema check (PRE-5)
  --dry-run       Print what would be checked without executing
  -h, --help      Show this help and exit

Description:
  Runs 11 read-only checks to validate the environment and content
  before modifying an OpenCode skill.

Checks performed:
  PRE-1  Git working tree clean (no uncommitted changes)
  PRE-2  stow is installed
  PRE-3  Installed skill is a symlink to source
  PRE-4  Output target directory exists
  PRE-5  opencode.db schema validates (--with-db)
  PRE-6  All hardcoded paths in source exist on disk
  PRE-7  No stale step references in other docs
  PRE-8  Stow restow target exists in Makefile
  PRE-9  YAML frontmatter parses
  PRE-10 No broken markdown links
  PRE-11 File size under 100KB

Example:
  $PROGNAME retro ~/git/projects/ai-toolbox/opencode/skills/retro/SKILL.md
  $PROGNAME --with-db retro ~/git/projects/ai-toolbox/opencode/skills/retro/SKILL.md

Exit codes:
  0  All checks passed
  1  One or more checks failed
  2  Invalid arguments
EOF
    exit 0
}

ok() {
    echo "[OK] $*"
    checks_run=$((checks_run + 1))
}

warn() {
    echo "[WARN] $*"
    warnings=$((warnings + 1))
    checks_run=$((checks_run + 1))
}

fail() {
    echo "[FAIL] $*"
    failures=$((failures + 1))
    checks_run=$((checks_run + 1))
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --with-db)
            WITH_DB=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            echo "Try '$PROGNAME --help' for usage." >&2
            exit 2
            ;;
        *)
            if [[ -z "$SKILL_NAME" ]]; then
                SKILL_NAME="$1"
            elif [[ -z "$SOURCE_PATH" ]]; then
                SOURCE_PATH="$1"
            else
                echo "Too many arguments" >&2
                exit 2
            fi
            shift
            ;;
    esac
done

if [[ -z "$SKILL_NAME" || -z "$SOURCE_PATH" ]]; then
    echo "Error: skill-name and source-path are required" >&2
    echo "Try '$PROGNAME --help' for usage." >&2
    exit 2
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: would check $SKILL_NAME at $SOURCE_PATH"
    echo "Checks: PRE-1 through PRE-11 (PRE-5 only with --with-db)"
    exit 0
fi

# Expand ~ to $HOME
SOURCE_PATH="${SOURCE_PATH/#\~/$HOME}"
REPO_PATH="${REPO_PATH/#\~/$HOME}"
TARGET_PATH="${TARGET_PATH/#\~/$HOME}"

echo "=== Pre-update checks for skill: $SKILL_NAME ==="
echo "Source: $SOURCE_PATH"
echo "Repo:   $REPO_PATH"
echo ""

# PRE-1: Git working tree clean
if [[ -d "$REPO_PATH/.git" ]]; then
    if git -C "$REPO_PATH" status --porcelain 2>/dev/null | grep -q .; then
        fail "PRE-1: git working tree dirty in $REPO_PATH — commit/stash before restow"
    else
        ok "PRE-1: git working tree clean in $REPO_PATH"
    fi
else
    warn "PRE-1: $REPO_PATH is not a git repo — skipping"
fi

# PRE-2: stow installed
if command -v stow >/dev/null 2>&1; then
    STOW_PATH=$(command -v stow)
    ok "PRE-2: stow installed at $STOW_PATH"
else
    fail "PRE-2: stow not found in PATH — cannot restow"
fi

# PRE-3: Installed skill is symlink
INSTALLED_PATH="$TARGET_PATH/skills/$SKILL_NAME/SKILL.md"
if [[ -L "$INSTALLED_PATH" ]]; then
    TARGET=$(readlink "$INSTALLED_PATH")
    if [[ "$TARGET" == "$SOURCE_PATH" ]] || [[ "$(readlink -f "$INSTALLED_PATH" 2>/dev/null)" == "$(cd "$(dirname "$SOURCE_PATH")" && pwd)/$(basename "$SOURCE_PATH")" ]]; then
        ok "PRE-3: $INSTALLED_PATH is symlink to source"
    else
        warn "PRE-3: $INSTALLED_PATH is symlink but points to $TARGET, not $SOURCE_PATH"
    fi
elif [[ -f "$INSTALLED_PATH" ]]; then
    warn "PRE-3: $INSTALLED_PATH is a regular file, not a symlink — restow won't update it"
else
    warn "PRE-3: $INSTALLED_PATH does not exist yet — will be created on restow"
fi

# PRE-4: Output target exists
DOCS_LEARNINGS="$HOME/git/docs/learnings"
if [[ -d "$DOCS_LEARNINGS" ]]; then
    ok "PRE-4: $DOCS_LEARNINGS exists (primary output target)"
else
    XDG_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/retro"
    if [[ -d "$XDG_PATH" ]]; then
        ok "PRE-4: $XDG_PATH exists (fallback output target)"
    else
        fail "PRE-4: neither $DOCS_LEARNINGS nor $XDG_PATH exists — create one"
    fi
fi

# PRE-5: opencode.db schema (only with --with-db)
if [[ "$WITH_DB" -eq 1 ]]; then
    DB_PATH="$HOME/.local/share/opencode/opencode.db"
    if [[ ! -f "$DB_PATH" ]]; then
        warn "PRE-5: $DB_PATH not found — skipping schema check"
    elif ! command -v sqlite3 >/dev/null 2>&1; then
        warn "PRE-5: sqlite3 not installed — skipping schema check"
    else
        TABLES=$(sqlite3 "$DB_PATH" "SELECT name FROM sqlite_master WHERE type='table';" 2>/dev/null | tr '\n' ' ')
        if [[ "$TABLES" == *"session"* && "$TABLES" == *"message"* && "$TABLES" == *"part"* ]]; then
            ok "PRE-5: opencode.db schema has session, message, part tables"
        else
            fail "PRE-5: opencode.db missing required tables. Found: $TABLES"
        fi
    fi
else
    echo "[SKIP] PRE-5: opencode.db schema (use --with-db to enable)"
fi

# PRE-6: Hardcoded paths exist
if [[ -f "$SOURCE_PATH" ]]; then
    PATHS_TO_CHECK=$(grep -oE '(/Users/[^ )"]+|~/?[^ )"]+)' "$SOURCE_PATH" 2>/dev/null | sort -u)
    MISSING=0
    if [[ -n "$PATHS_TO_CHECK" ]]; then
        for p in $PATHS_TO_CHECK; do
            p_expanded="${p/#\~/$HOME}"
            if [[ ! -e "$p_expanded" ]]; then
                warn "PRE-6: path $p in $SKILL_NAME does not exist"
                MISSING=$((MISSING + 1))
            fi
        done
        if [[ $MISSING -eq 0 ]]; then
            ok "PRE-6: all hardcoded paths in source exist"
        fi
    else
        ok "PRE-6: no hardcoded paths in source (or none to check)"
    fi
else
    fail "PRE-6: source file $SOURCE_PATH does not exist"
fi

# PRE-7: No stale step references
STALE_REFS=0
for pattern in "Step 0.5:" "Step 0.6:" "Step 1.5:" "Step 1.6:";
do
    REFS=$(grep -rln "$pattern" "$REPO_PATH/opencode/" 2>/dev/null | grep -v "skills/retro/" | wc -l | tr -d ' ')
    if [[ "$REFS" -gt 0 ]]; then
        warn "PRE-7: $pattern referenced in $REFS other files"
        STALE_REFS=$((STALE_REFS + REFS))
    fi
done
if [[ $STALE_REFS -eq 0 ]]; then
    ok "PRE-7: no stale step references in other skills"
fi

# PRE-8: Stow restow target exists
if [[ -f "$REPO_PATH/Makefile" ]]; then
    if grep -q "^restow-opencode:" "$REPO_PATH/Makefile" 2>/dev/null; then
        ok "PRE-8: restow-opencode target exists in $REPO_PATH/Makefile"
    else
        fail "PRE-8: restow-opencode target not found in Makefile"
    fi
else
    fail "PRE-8: $REPO_PATH/Makefile not found"
fi

# PRE-9: YAML frontmatter parses
if [[ -f "$SOURCE_PATH" ]]; then
    FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$SOURCE_PATH" 2>/dev/null)
    if [[ -z "$FRONTMATTER" ]]; then
        fail "PRE-9: no YAML frontmatter found in $SOURCE_PATH"
    else
        REQUIRED_FIELDS=("name" "description")
        MISSING_FIELD=0
        for field in "${REQUIRED_FIELDS[@]}"; do
            if ! echo "$FRONTMATTER" | grep -q "^${field}:"; then
                fail "PRE-9: frontmatter missing required field '$field'"
                MISSING_FIELD=$((MISSING_FIELD + 1))
            fi
        done
        if [[ $MISSING_FIELD -eq 0 ]]; then
            ok "PRE-9: YAML frontmatter has required fields (name, description)"
        fi
    fi
else
    fail "PRE-9: source file $SOURCE_PATH does not exist"
fi

# PRE-10: No broken markdown links
if [[ -f "$SOURCE_PATH" ]]; then
    # Find [text](path) links that are local paths
    LINKS=$(grep -oE '\[[^]]+\]\((/Users/[^)]+)\)' "$SOURCE_PATH" 2>/dev/null | grep -oE '\(/Users/[^)]+\)')
    BROKEN=0
    if [[ -n "$LINKS" ]]; then
        for link in $LINKS; do
            path="${link:2:-1}"  # strip ( and )
            if [[ ! -e "$path" ]]; then
                warn "PRE-10: broken link in source: $path"
                BROKEN=$((BROKEN + 1))
            fi
        done
        if [[ $BROKEN -eq 0 ]]; then
            ok "PRE-10: all local markdown links resolve"
        fi
    else
        ok "PRE-10: no local markdown links to verify"
    fi
fi

# PRE-11: File size under 100KB
if [[ -f "$SOURCE_PATH" ]]; then
    SIZE=$(wc -c < "$SOURCE_PATH" | tr -d ' ')
    if [[ $SIZE -lt 102400 ]]; then
        ok "PRE-11: file size ${SIZE} bytes (under 100KB)"
    else
        fail "PRE-11: file size ${SIZE} bytes exceeds 100KB"
    fi
else
    warn "PRE-11: cannot check size of missing file"
fi

echo ""
echo "=== Summary ==="
echo "Checks run: $checks_run"
echo "Warnings:   $warnings"
echo "Failures:   $failures"

if [[ $failures -gt 0 ]]; then
    echo ""
    echo "RESULT: FAILED — do not proceed with edit"
    exit 1
else
    echo ""
    echo "RESULT: PASSED — safe to proceed with edit"
    if [[ $warnings -gt 0 ]]; then
        echo "Note: $warnings warning(s) — review before continuing"
    fi
    exit 0
fi

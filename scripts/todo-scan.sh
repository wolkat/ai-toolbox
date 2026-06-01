#!/usr/bin/env bash
# todo-scan.sh - Cross-repo scan for unfinished work
# Scans all git repos under ROOT and reports:
#   1. Uncommitted git state (modified, added, untracked, conflicted)
#   2. Stashed work
#   3. Code TODO / FIXME / XXX / HACK markers in source files
#   4. Stale branches (no commits in N days, excluding default branch)
#   5. Canonical backlog files (CHECKLIST, TODO, PLAN, BACKLOG, etc.)
#   6. Unchecked markdown checkboxes inside backlog files
#   7. Status-tracked plans (markdown tables with Status column)
#
# Read-only. Exits 0 always; per-repo errors are logged but do not abort.

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------

ROOT="${HOME}/git"
MAX_DEPTH=2
STALE_DAYS=90
SOURCE_FILTER=""
REPO_FILTER=""
WRITE_PATH=""
QUIET=0

# Report buffers (parallel indexed arrays; bash 3.2 safe)
SECTION_TITLES=()
SECTION_BODIES=()

# Source extension allowlist (code TODOs)
TODO_EXTS=(ts tsx js jsx mjs cjs ps1 psm1 sh bash py go rs java kt kts swift rb php c h cpp hpp cs scala dart vue svelte)

# Directories to exclude from code-TODO scan
TODO_EXCLUDE_DIRS=(node_modules dist build out .next .cache .output .vite coverage outputs vendor target .git .svn .hg _bmad _bmad-output graphify-out)

# Canonical backlog file basenames
BACKLOG_BASENAMES=(CHECKLIST.md TODO.md BACKLOG.md PLAN.md ROADMAP.md STATUS.md)
BACKLOG_GLOBS=(
  "*plan*.md"
  "*todo*.md"
  "*backlog*.md"
  "*-actions*.md"
  "*action-items*.md"
  "*checklist*.md"
)

# Paths excluded from checkbox scan (PR templates, standards docs, retro logs)
CHECKBOX_EXCLUDE_PATHS=(
  ".github/PULL_REQUEST_TEMPLATE.md"
  "SKILL_STANDARDS.md"
  "docs/learnings/retrospective-"
  "docs/learnings/retrospectived-"
)

# Default branch names to exclude from stale-branches scan
DEFAULT_BRANCHES=(main master develop trunk)

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

err() {
  printf "todo-scan: %s\n" "$*" >&2
}

log() {
  if [ "$QUIET" -eq 0 ]; then
    printf "todo-scan: %s\n" "$*"
  fi
}

# Add a completed section to the report buffers.
# Usage: add_section "Title" "Body"
add_section() {
  local title="$1"
  local body="$2"
  SECTION_TITLES+=("$title")
  SECTION_BODIES+=("$body")
}

# Render a markdown table row. Args: cells...
md_row() {
  local out="|"
  local cell
  for cell in "$@"; do
    out+=" ${cell} |"
  done
  printf "%s\n" "$out"
}

# Render markdown table header. First arg is separator count, then headers.
md_header() {
  local sep
  sep=$(printf -- '-%.0s' $(seq 1 60))
  local out="|"
  local cell
  for cell in "$@"; do
    out+=" ${cell} |"
  done
  printf "%s\n" "$out"
  out="|"
  for _ in "$@"; do
    out+=" ${sep:0:20} |"
  done
  printf "%s\n" "$out"
}

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------

show_help() {
  cat <<'EOF'
Usage: todo-scan.sh [OPTIONS]

Scan git repos under ROOT for unfinished work and emit a markdown report.

Options:
  --root <path>       Scan root directory (default: ~/git)
  --repo <name>       Comma-separated repo names to limit scan (default: all)
  --source <n>        Run only data source N (1-7, default: all)
                      1=uncommitted  2=stash  3=code-TODOs  4=stale-branches
                      5=backlog-files  6=checkboxes  7=status-tracked
  --stale <days>      Stale-branch threshold in days (default: 90)
  --max-depth <n>     Repo discovery depth (default: 2)
  --write <path>      Write report to path instead of stdout
  --quiet             Suppress progress messages on stderr
  -h, --help          Show this help

Description of data sources:
  1. Uncommitted git state - modified, added, untracked, conflicted files
  2. Stashed work          - entries in git stash list
  3. Code TODOs/FIXMEs     - TODO, FIXME, XXX, HACK markers in source files
  4. Stale branches        - branches with no commits in --stale days
  5. Backlog files         - markdown files matching canonical names/globs
  6. Unchecked checkboxes  - `- [ ]` lines inside backlog files only
  7. Status-tracked plans  - markdown tables with Status column (planned/created)

Examples:
  todo-scan.sh
  todo-scan.sh --root ~/work
  todo-scan.sh --repo lifebinder,ai-toolbox
  todo-scan.sh --source 1,3,6
  todo-scan.sh --stale 30 --write /tmp/todo-report.md
  todo-scan.sh --quiet --write docs/todo-scan-$(date +%Y-%m-%d).md
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --root)
        [ $# -ge 2 ] || { err "--root requires a value"; exit 2; }
        ROOT="$2"
        shift 2
        ;;
      --repo)
        [ $# -ge 2 ] || { err "--repo requires a value"; exit 2; }
        REPO_FILTER="$2"
        shift 2
        ;;
      --source)
        [ $# -ge 2 ] || { err "--source requires a value"; exit 2; }
        SOURCE_FILTER="$2"
        shift 2
        ;;
      --stale)
        [ $# -ge 2 ] || { err "--stale requires a value"; exit 2; }
        STALE_DAYS="$2"
        shift 2
        ;;
      --max-depth)
        [ $# -ge 2 ] || { err "--max-depth requires a value"; exit 2; }
        MAX_DEPTH="$2"
        shift 2
        ;;
      --write)
        [ $# -ge 2 ] || { err "--write requires a value"; exit 2; }
        WRITE_PATH="$2"
        shift 2
        ;;
      --quiet)
        QUIET=1
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        err "unknown argument: $1"
        err "run with --help for usage"
        exit 2
        ;;
    esac
  done
}

# ---------------------------------------------------------------------------
# Repo discovery
# ---------------------------------------------------------------------------

# Print absolute paths of git repos under $ROOT (one per line).
discover_repos() {
  if [ ! -d "$ROOT" ]; then
    err "root does not exist: $ROOT"
    return 1
  fi
  find "$ROOT" -maxdepth "$MAX_DEPTH" -name .git -type d 2>/dev/null \
    | while read -r gitdir; do
        dirname "$gitdir"
      done \
    | sort
}

# Filter discovered repos against --repo list (comma-separated basenames).
filter_repos() {
  local all_repos="$1"
  if [ -z "$REPO_FILTER" ]; then
    printf "%s\n" "$all_repos"
    return
  fi
  local name
  local IFS=','
  for name in $REPO_FILTER; do
    printf "%s\n" "$all_repos" | while read -r repo; do
      if [ "$(basename "$repo")" = "$name" ]; then
        printf "%s\n" "$repo"
      fi
    done
  done | sort -u
}

# ---------------------------------------------------------------------------
# Source gating
# ---------------------------------------------------------------------------

# Return success (0) if source number N is enabled by --source filter.
source_enabled() {
  local n="$1"
  if [ -z "$SOURCE_FILTER" ]; then
    return 0
  fi
  local IFS=','
  local item
  for item in $SOURCE_FILTER; do
    if [ "$item" = "$n" ]; then
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Data source 1: Uncommitted git state
# ---------------------------------------------------------------------------

scan_uncommitted() {
  local repo="$1"
  local branch
  branch=$(git -C "$repo" branch --show-current 2>/dev/null || echo "(detached)")
  local porcelain
  porcelain=$(git -C "$repo" status --porcelain 2>/dev/null || true)
  if [ -z "$porcelain" ]; then
    return
  fi
  local m=0 a=0 u=0 c=0
  local line
  while read -r line; do
    [ -z "$line" ] && continue
    local x="${line:0:1}"
    local y="${line:1:1}"
    case "$x$y" in
      ??*) u=$((u + 1)) ;;
      U*|*U|*AA|*DD) c=$((c + 1)) ;;
      *) case "$x" in
           M|A|T|D|R|C) a=$((a + 1)) ;;
           *) case "$y" in
                M|A|T|D) m=$((m + 1)) ;;
              esac
              ;;
         esac
         ;;
    esac
  done <<EOF
$porcelain
EOF
  printf "%s|%s|%s|%s|%s|%s\n" "$(basename "$repo")" "$branch" "$m" "$a" "$u" "$c"
}

# ---------------------------------------------------------------------------
# Data source 2: Stashed work
# ---------------------------------------------------------------------------

scan_stash() {
  local repo="$1"
  local count
  count=$(git -C "$repo" stash list 2>/dev/null | wc -l | tr -d ' ')
  if [ "$count" -eq 0 ]; then
    return
  fi
  local oldest
  oldest=$(git -C "$repo" stash list 2>/dev/null \
    | head -n 1 \
    | sed -nE 's/^[^:]+: WIP on [^:]+: ([0-9a-f]+) .*/\1/p')
  if [ -n "$oldest" ]; then
    local age
    age=$(git -C "$repo" log -1 --format=%ct "$oldest" 2>/dev/null || echo "")
    if [ -n "$age" ]; then
      local now
      now=$(date +%s)
      local days=$(( (now - age) / 86400 ))
      printf "%s|%s|%s\n" "$(basename "$repo")" "$count" "${days}d"
      return
    fi
  fi
  printf "%s|%s|?\n" "$(basename "$repo")" "$count"
}

# ---------------------------------------------------------------------------
# Data source 3: Code TODOs / FIXMEs
# ---------------------------------------------------------------------------

# Build find -prune expression for excluded directories.
build_exclude_prune() {
  local first=1
  printf " \\( "
  for d in "${TODO_EXCLUDE_DIRS[@]}"; do
    if [ $first -eq 1 ]; then
      first=0
    else
      printf " -o "
    fi
    printf "-name %s" "$d"
  done
  printf " \\) -prune -o"
}

# Build the -name OR chain for source extensions.
build_ext_or() {
  local first=1
  for ext in "${TODO_EXTS[@]}"; do
    if [ $first -eq 1 ]; then
      first=0
    else
      printf " -o "
    fi
    printf "-name '*.%s'" "$ext"
  done
}

scan_code_todos() {
  local repo="$1"
  local relpath
  relpath="${repo#${ROOT}/}"
  relpath="${relpath%/}"
  [ -z "$relpath" ] && relpath="."

  local prune
  prune=$(build_exclude_prune)
  local exts
  exts=$(build_ext_or)

  # Use eval to expand the dynamic find expression (bash 3.2 safe).
  # Output: file:lineno:marker (per marker, capped per file at top 5).
  local counts
  counts=$(eval find "'$repo'" $prune -type f "$exts" -print 2>/dev/null \
    | while read -r f; do
        grep -nE '\b(TODO|FIXME|XXX|HACK)\b' "$f" 2>/dev/null \
          | awk -F: -v file="${f#${repo}/}" '
              {
                marker = ""
                if (match($0, /\b(TODO|FIXME|XXX|HACK)\b/)) {
                  marker = substr($0, RSTART, RLENGTH)
                }
                print file ":" $2 ":" marker
                count[file]++
                if (count[file] >= 5) next
              }
            '
      done)

  local total
  total=$(printf "%s\n" "$counts" | grep -c . 2>/dev/null || echo 0)
  if [ "$total" -eq 0 ]; then
    return
  fi

  local top
  top=$(printf "%s\n" "$counts" \
    | awk -F: '{print $1}' \
    | sort | uniq -c | sort -rn | head -n 5)
  printf "%s|%s|%s\n" "$(basename "$repo")" "$total" "$(echo "$top" | tr '\n' ',' | sed 's/,$//' | tr ' ' '~')"
}

# ---------------------------------------------------------------------------
# Data source 4: Stale branches
# ---------------------------------------------------------------------------

scan_stale_branches() {
  local repo="$1"
  local now
  now=$(date +%s)
  local threshold=$((now - STALE_DAYS * 86400))
  local default_branch
  default_branch=$(git -C "$repo" symbolic-ref --short HEAD 2>/dev/null || echo "")

  # for-each-ref emits: committerdate (unix ts) \t refname
  local line
  while read -r ts ref; do
    [ -z "$ts" ] && continue
    [ -z "$ref" ] && continue
    if [ "$ts" -ge "$threshold" ] 2>/dev/null; then
      continue
    fi
    local branch="${ref#refs/heads/}"
    local skip=0
    local b
    for b in "${DEFAULT_BRANCHES[@]}"; do
      if [ "$branch" = "$b" ]; then
        skip=1
        break
      fi
    done
    [ "$branch" = "$default_branch" ] && skip=1
    [ $skip -eq 1 ] && continue
    local age=$(( (now - ts) / 86400 ))
    local last_subject
    last_subject=$(git -C "$repo" log -1 --format=%s "$ref" 2>/dev/null | head -c 60)
    printf "%s|%s|%sd|%s\n" "$(basename "$repo")" "$branch" "$age" "$last_subject"
  done < <(git -C "$repo" for-each-ref --format='%(committerdate:unix) %(refname)' refs/heads/ 2>/dev/null || true)
}

# ---------------------------------------------------------------------------
# Data source 5: Backlog file detection
# ---------------------------------------------------------------------------

is_excluded_checkbox_path() {
  local rel="$1"
  local ex
  for ex in "${CHECKBOX_EXCLUDE_PATHS[@]}"; do
    case "$rel" in
      *"$ex"*) return 0 ;;
    esac
  done
  return 1
}

# Returns "1" if a basename matches the canonical backlog set or glob.
is_backlog_basename() {
  local base="$1"
  local b
  for b in "${BACKLOG_BASENAMES[@]}"; do
    if [ "$base" = "$b" ]; then
      return 0
    fi
  done
  local low
  low=$(printf "%s" "$base" | tr '[:upper:]' '[:lower:]')
  local g
  for g in "${BACKLOG_GLOBS[@]}"; do
    # shellcheck disable=SC2053
    case "$low" in
      $g) return 0 ;;
    esac
  done
  return 1
}

# Find backlog files within a repo (capped at 50 to avoid noise).
find_backlog_files() {
  local repo="$1"

  # 1. Canonical names at repo root
  local b
  for b in "${BACKLOG_BASENAMES[@]}"; do
    if [ -f "$repo/$b" ]; then
      printf "%s\n" "$b"
    fi
  done

  # 2. Candidate deep paths: docs/, _bmad-output/planning-artifacts/,
  #    docs/learnings/. -path is the simplest way to scope.
  local f
  while read -r f; do
    [ -z "$f" ] && continue
    printf "%s\n" "${f#${repo}/}"
  done < <(find "$repo" \
      \( -path "*/node_modules" -o -path "*/.git" -o -path "*/.git/*" \) -prune -o \
      -type f -name "*.md" \( \
        -path "*/docs/*" -o \
        -path "*/_bmad-output/planning-artifacts/*" -o \
        -path "*/_bmad-output/*/checklist*" -o \
        -path "*/_bmad-output/*/plan*" \
      \) -print 2>/dev/null)
}

scan_backlog_files() {
  local repo="$1"
  local file
  while read -r file; do
    [ -z "$file" ] && continue
    printf "%s|%s\n" "$(basename "$repo")" "$file"
  done < <(find_backlog_files "$repo")
}

# ---------------------------------------------------------------------------
# Data source 6: Unchecked checkboxes (in backlog files only)
# ---------------------------------------------------------------------------

scan_checkboxes() {
  local repo="$1"
  local file
  while read -r file; do
    [ -z "$file" ] && continue
    is_excluded_checkbox_path "$file" && continue
    local full="$repo/$file"
    [ -f "$full" ] || continue
    local unchecked
    unchecked=$(grep -cE '^- \[ \]' "$full" 2>/dev/null || echo 0)
    [ "$unchecked" -eq 0 ] && continue
    local samples
    samples=$(grep -nE '^- \[ \]' "$full" 2>/dev/null \
      | head -n 5 \
      | sed -E 's/^[0-9]+:- \[ \] //' \
      | head -c 200)
    printf "%s|%s|%s|%s\n" "$(basename "$repo")" "$file" "$unchecked" "$samples"
  done < <(find_backlog_files "$repo")
}

# ---------------------------------------------------------------------------
# Data source 7: Status-tracked plans
# ---------------------------------------------------------------------------

# Extract a markdown table line-by-line: find blocks where a "Status" column
# exists, then emit rows whose Status is in the incomplete set.
scan_status_tracked() {
  local repo="$1"
  local file
  while read -r file; do
    [ -z "$file" ] && continue
    local full="$repo/$file"
    [ -f "$full" ] || continue
    # Find lines like: | item | planned | notes |
    # and the table header that includes "Status" (case-insensitive).
    local header_line
    header_line=$(grep -niE '^\|[[^|]*\|[^|]*[Ss]tatus[^|]*\|' "$full" 2>/dev/null | head -n 1)
    [ -z "$header_line" ] && continue
    # Get header column count
    local header_count
    header_count=$(printf "%s\n" "$header_line" | awk -F'|' '{print NF-2}')
    [ "$header_count" -lt 2 ] && continue
    # Identify which column is Status
    local status_col
    status_col=$(printf "%s\n" "$header_line" | awk -F'|' '
      {
        for (i=2; i<=NF-1; i++) {
          gsub(/^ +| +$/, "", $i)
          if (tolower($i) == "status") { print i-1; exit }
        }
      }')
    [ -z "$status_col" ] && continue

    local line_num=0
    while IFS= read -r line; do
      line_num=$((line_num + 1))
      case "$line" in
        \|*\|)
          # Parse row
          local IFS='|'
          local cells=($line)
          local n=${#cells[@]}
          # cells[0] is empty (leading |), cells[n-1] is empty (trailing |)
          # So column i is cells[i] (1-indexed) -> array index i
          if [ "$n" -le "$status_col" ]; then
            continue
          fi
          local status_val
          status_val=$(printf "%s" "${cells[$status_col]}" | sed -E 's/^ +| +$//g' | tr '[:upper:]' '[:lower:]')
          case "$status_val" in
            planned|created|open|in-progress|in_progress|wip|pending|blocked|todo)
              local item
              item=$(printf "%s" "${cells[1]}" | sed -E 's/^ +| +$//g' | head -c 80)
              printf "%s|%s|%s|%s\n" "$(basename "$repo")" "$file" "$item" "$status_val"
              ;;
          esac
          ;;
      esac
    done < "$full"
  done < <(find_backlog_files "$repo")
}

# ---------------------------------------------------------------------------
# Section assembly
# ---------------------------------------------------------------------------

# Run a scan function over all repos and emit one big body string.
# Usage: render_section "Title" scan_func
render_section() {
  local title="$1"
  local scan_func="$2"
  local body=""
  local repo
  while read -r repo; do
    [ -z "$repo" ] && continue
    local line
    line=$($scan_func "$repo" 2>/dev/null || true)
    [ -z "$line" ] && continue
    body+="$line"
    body+=$'\n'
  done < <(printf "%s\n" "$REPOS")

  if [ -z "$body" ]; then
    add_section "$title" "(empty across all repos)"
    return
  fi
  add_section "$title" "$body"
}

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

emit_report() {
  local report=""
  report+="# /todo scan"
  report+=$'\n'
  report+="Generated: $(date '+%Y-%m-%d %H:%M:%S')"
  report+=$'\n'
  report+="Root: $ROOT | Stale threshold: ${STALE_DAYS}d | Depth: $MAX_DEPTH"
  report+=$'\n'
  if [ -n "$REPO_FILTER" ]; then
    report+="Filter: repos=$REPO_FILTER"
    report+=$'\n'
  fi
  if [ -n "$SOURCE_FILTER" ]; then
    report+="Filter: sources=$SOURCE_FILTER"
    report+=$'\n'
  fi
  report+=$'\n'

  local i
  for ((i=0; i<${#SECTION_TITLES[@]}; i++)); do
    report+="## ${SECTION_TITLES[$i]}"
    report+=$'\n'
    report+="${SECTION_BODIES[$i]}"
    report+=$'\n\n'
  done

  if [ -n "$WRITE_PATH" ]; then
    printf "%s" "$report" > "$WRITE_PATH"
    log "wrote report to $WRITE_PATH"
  else
    printf "%s" "$report"
  fi
}

# ---------------------------------------------------------------------------
# Section renderers (turn raw body lines into markdown tables)
# ---------------------------------------------------------------------------

# Body format: repo|branch|m|a|u|c  per line.
render_uncommitted_section() {
  local title="$1"
  local body="$2"
  if [ "$body" = "(empty across all repos)" ]; then
    add_section "$title" "$body"
    return
  fi
  local out=""
  out+="| Repo | Branch | Modified | Added | Untracked | Conflicted |"
  out+=$'\n'
  out+="| --- | --- | --- | --- | --- | --- |"
  out+=$'\n'
  out+=$(printf "%s\n" "$body" | awk -F'|' '{printf "| %s | %s | %s | %s | %s | %s |\n", $1, $2, $3, $4, $5, $6}')
  add_section "$title" "$out"
}

render_stash_section() {
  local title="$1"
  local body="$2"
  if [ "$body" = "(empty across all repos)" ]; then
    add_section "$title" "$body"
    return
  fi
  local out=""
  out+="| Repo | Stash entries | Oldest age |"
  out+=$'\n'
  out+="| --- | --- | --- |"
  out+=$'\n'
  out+=$(printf "%s\n" "$body" | awk -F'|' '{printf "| %s | %s | %s |\n", $1, $2, $3}')
  add_section "$title" "$out"
}

render_todo_section() {
  local title="$1"
  local body="$2"
  if [ "$body" = "(empty across all repos)" ]; then
    add_section "$title" "$body"
    return
  fi
  local out=""
  out+="| Repo | Markers | Top files (first 5, count) |"
  out+=$'\n'
  out+="| --- | --- | --- |"
  out+=$'\n'
  # Top-files field was tilde-joined with " " replaced to keep awk happy;
  # restore spaces for display.
  out+=$(printf "%s\n" "$body" | awk -F'|' '{
    files = $3
    gsub(/~/, " ", files)
    printf "| %s | %s | %s |\n", $1, $2, files
  }')
  add_section "$title" "$out"
}

render_stale_section() {
  local title="$1"
  local body="$2"
  if [ "$body" = "(empty across all repos)" ]; then
    add_section "$title" "$body"
    return
  fi
  local out=""
  out+="| Repo | Branch | Age | Last subject |"
  out+=$'\n'
  out+="| --- | --- | --- | --- |"
  out+=$'\n'
  out+=$(printf "%s\n" "$body" | awk -F'|' '{printf "| %s | %s | %s | %s |\n", $1, $2, $3, $4}')
  add_section "$title" "$out"
}

render_backlog_files_section() {
  local title="$1"
  local body="$2"
  if [ "$body" = "(empty across all repos)" ]; then
    add_section "$title" "$body"
    return
  fi
  local out=""
  out+="| Repo | File |"
  out+=$'\n'
  out+="| --- | --- |"
  out+=$'\n'
  out+=$(printf "%s\n" "$body" | awk -F'|' '{printf "| %s | %s |\n", $1, $2}')
  add_section "$title" "$out"
}

render_checkboxes_section() {
  local title="$1"
  local body="$2"
  if [ "$body" = "(empty across all repos)" ]; then
    add_section "$title" "$body"
    return
  fi
  local out=""
  out+="| Repo | File | [ ] count | Sample items |"
  out+=$'\n'
  out+="| --- | --- | --- | --- |"
  out+=$'\n'
  out+=$(printf "%s\n" "$body" | awk -F'|' '{printf "| %s | %s | %s | %s |\n", $1, $2, $3, $4}')
  add_section "$title" "$out"
}

render_status_section() {
  local title="$1"
  local body="$2"
  if [ "$body" = "(empty across all repos)" ]; then
    add_section "$title" "$body"
    return
  fi
  local out=""
  out+="| Repo | File | Item | Status |"
  out+=$'\n'
  out+="| --- | --- | --- | --- |"
  out+=$'\n'
  out+=$(printf "%s\n" "$body" | awk -F'|' '{printf "| %s | %s | %s | %s |\n", $1, $2, $3, $4}')
  add_section "$title" "$out"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  parse_args "$@"

  log "scanning $ROOT (depth=$MAX_DEPTH, stale=${STALE_DAYS}d)"
  local all_repos
  all_repos=$(discover_repos)
  if [ -z "$all_repos" ]; then
    err "no git repos found under $ROOT"
    exit 0
  fi

  REPOS=$(filter_repos "$all_repos")
  if [ -z "$REPOS" ]; then
    err "no repos matched filter (--repo $REPO_FILTER)"
    exit 0
  fi
  local repo_count
  repo_count=$(printf "%s\n" "$REPOS" | wc -l | tr -d ' ')
  log "found $repo_count repo(s)"

  # Section 1: uncommitted
  if source_enabled 1; then
    local body=""
    local repo
    while read -r repo; do
      [ -z "$repo" ] && continue
      local line
      line=$(scan_uncommitted "$repo" 2>/dev/null || true)
      [ -z "$line" ] && continue
      body+="$line"$'\n'
    done < <(printf "%s\n" "$REPOS")
    if [ -z "$body" ]; then
      add_section "1. Uncommitted git state" "(empty across all repos)"
    else
      render_uncommitted_section "1. Uncommitted git state" "$body"
    fi
  fi

  # Section 2: stash
  if source_enabled 2; then
    local body=""
    local repo
    while read -r repo; do
      [ -z "$repo" ] && continue
      local line
      line=$(scan_stash "$repo" 2>/dev/null || true)
      [ -z "$line" ] && continue
      body+="$line"$'\n'
    done < <(printf "%s\n" "$REPOS")
    if [ -z "$body" ]; then
      add_section "2. Stashed work" "(empty across all repos)"
    else
      render_stash_section "2. Stashed work" "$body"
    fi
  fi

  # Section 3: code TODOs
  if source_enabled 3; then
    local body=""
    local repo
    while read -r repo; do
      [ -z "$repo" ] && continue
      local line
      line=$(scan_code_todos "$repo" 2>/dev/null || true)
      [ -z "$line" ] && continue
      body+="$line"$'\n'
    done < <(printf "%s\n" "$REPOS")
    if [ -z "$body" ]; then
      add_section "3. Code TODOs / FIXMEs" "(empty across all repos)"
    else
      render_todo_section "3. Code TODOs / FIXMEs" "$body"
    fi
  fi

  # Section 4: stale branches
  if source_enabled 4; then
    local body=""
    local repo
    while read -r repo; do
      [ -z "$repo" ] && continue
      local line
      line=$(scan_stale_branches "$repo" 2>/dev/null || true)
      [ -z "$line" ] && continue
      body+="$line"$'\n'
    done < <(printf "%s\n" "$REPOS")
    if [ -z "$body" ]; then
      add_section "4. Stale branches (>${STALE_DAYS}d, non-default)" "(empty across all repos)"
    else
      render_stale_section "4. Stale branches (>${STALE_DAYS}d, non-default)" "$body"
    fi
  fi

  # Section 5: backlog files
  if source_enabled 5; then
    local body=""
    local repo
    while read -r repo; do
      [ -z "$repo" ] && continue
      local line
      line=$(scan_backlog_files "$repo" 2>/dev/null || true)
      [ -z "$line" ] && continue
      body+="$line"$'\n'
    done < <(printf "%s\n" "$REPOS")
    if [ -z "$body" ]; then
      add_section "5. Backlog files detected" "(empty across all repos)"
    else
      render_backlog_files_section "5. Backlog files detected" "$body"
    fi
  fi

  # Section 6: checkboxes
  if source_enabled 6; then
    local body=""
    local repo
    while read -r repo; do
      [ -z "$repo" ] && continue
      local line
      line=$(scan_checkboxes "$repo" 2>/dev/null || true)
      [ -z "$line" ] && continue
      body+="$line"$'\n'
    done < <(printf "%s\n" "$REPOS")
    if [ -z "$body" ]; then
      add_section "6. Unchecked checkboxes (in backlog files)" "(empty across all repos)"
    else
      render_checkboxes_section "6. Unchecked checkboxes (in backlog files)" "$body"
    fi
  fi

  # Section 7: status-tracked plans
  if source_enabled 7; then
    local body=""
    local repo
    while read -r repo; do
      [ -z "$repo" ] && continue
      local line
      line=$(scan_status_tracked "$repo" 2>/dev/null || true)
      [ -z "$line" ] && continue
      body+="$line"$'\n'
    done < <(printf "%s\n" "$REPOS")
    if [ -z "$body" ]; then
      add_section "7. Status-tracked plans (incomplete)" "(empty across all repos)"
    else
      render_status_section "7. Status-tracked plans (incomplete)" "$body"
    fi
  fi

  emit_report
}

main "$@"

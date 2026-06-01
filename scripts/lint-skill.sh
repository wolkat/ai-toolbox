#!/usr/bin/env bash
# lint-skill.sh — Validate OpenCode SKILL.md files against SKILL_STANDARDS.md
# Usage: lint-skill.sh [OPTIONS] <skill-directory>
#        lint-skill.sh --all

set -euo pipefail

# ---------------------------------------------------------------------------
# Globals
# ---------------------------------------------------------------------------

SCRIPT_DIR=""
SKILL_STANDARDS=""
QUIET=0
FIX=0
ALL=0
ERRORS=0
WARNINGS=0
TOTAL_CHECKS=0

# Detect color support
USE_COLOR=0
if [ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ]; then
  USE_COLOR=1
fi

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

pass() {
  local msg="$1"
  if [ "$QUIET" -eq 0 ]; then
    if [ "$USE_COLOR" -eq 1 ]; then
      printf "  \033[32m✅\033[0m %s\n" "$msg"
    else
      printf "  ✅ %s\n" "$msg"
    fi
  fi
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

fail() {
  local msg="$1"
  if [ "$USE_COLOR" -eq 1 ]; then
    printf "  \033[31m❌\033[0m %s\n" "$msg" >&2
  else
    printf "  ❌ %s\n" "$msg" >&2
  fi
  ERRORS=$((ERRORS + 1))
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

warn() {
  local msg="$1"
  if [ "$USE_COLOR" -eq 1 ]; then
    printf "  \033[33m⚠️ \033[0m %s\n" "$msg" >&2
  else
    printf "  ⚠️  %s\n" "$msg" >&2
  fi
  WARNINGS=$((WARNINGS + 1))
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

info() {
  local msg="$1"
  printf "%s\n" "$msg"
}

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------

show_help() {
  cat <<'EOF'
Usage: lint-skill.sh [OPTIONS] <skill-directory>

Options:
  --all       Lint all opencode/skills/*/ directories
  --fix       Show suggested fixes (does not modify files)
  --quiet     Only show errors, not passes
  -h, --help  Show this help

Examples:
  lint-skill.sh opencode/skills/retro/
  lint-skill.sh --all
  lint-skill.sh --fix opencode/skills/plugin-audit/
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

parse_args() {
  local pos_args=()

  while [ $# -gt 0 ]; do
    case "$1" in
      --all)
        ALL=1
        shift
        ;;
      --fix)
        FIX=1
        shift
        ;;
      --quiet)
        QUIET=1
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      --)
        shift
        pos_args+=("$@")
        break
        ;;
      -*)
        printf "Unknown option: %s\n" "$1" >&2
        show_help >&2
        exit 1
        ;;
      *)
        pos_args+=("$1")
        shift
        ;;
    esac
  done

  if [ "$ALL" -eq 1 ]; then
    if [ "${#pos_args[@]}" -gt 0 ]; then
      printf "Error: --all does not accept a directory argument\n" >&2
      show_help >&2
      exit 1
    fi
    return
  fi

  if [ "${#pos_args[@]}" -eq 0 ]; then
    printf "Error: missing skill-directory argument\n" >&2
    show_help >&2
    exit 1
  fi

  SKILL_DIR="${pos_args[0]}"
}

# ---------------------------------------------------------------------------
# Path helpers (no realpath)
# ---------------------------------------------------------------------------

abs_path() {
  local p="$1"
  if [ -d "$p" ]; then
    (cd "$p" && pwd)
  elif [ -f "$p" ]; then
    local dir
    dir=$(cd "$(dirname "$p")" && pwd)
    printf "%s/%s\n" "$dir" "$(basename "$p")"
  else
    printf "%s\n" "$p"
  fi
}

# ---------------------------------------------------------------------------
# Frontmatter extraction
# ---------------------------------------------------------------------------

extract_frontmatter() {
  local file="$1"
  local in_fm=0
  local line

  while IFS= read -r line; do
    if [ "$in_fm" -eq 0 ] && [ "$line" = "---" ]; then
      in_fm=1
      continue
    fi
    if [ "$in_fm" -eq 1 ] && [ "$line" = "---" ]; then
      break
    fi
    if [ "$in_fm" -eq 1 ]; then
      printf "%s\n" "$line"
    fi
  done < "$file"
}

get_frontmatter_value() {
  local fm="$1"
  local key="$2"
  printf "%s\n" "$fm" | sed -n "s/^${key}:[[:space:]]*//p" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# ---------------------------------------------------------------------------
# Word count (simple: count space-separated tokens)
# ---------------------------------------------------------------------------

word_count() {
  local text="$1"
  printf "%s" "$text" | wc -w | tr -d '[:space:]'
}

# ---------------------------------------------------------------------------
# Title case check
# ---------------------------------------------------------------------------

is_title_case() {
  local text="$1"
  # Allow common small words in title case
  # Heuristic: each word should start with uppercase, except small words
  local small_words="a an and at but by for in nor of on or per the to vs"
  local word
  local first=1

  for word in $text; do
    local first_char
    first_char=$(printf "%s" "$word" | cut -c1)
    if [ "$first" -eq 1 ]; then
      # First word must be capitalized
      if ! printf "%s" "$first_char" | grep -q '[A-Z]'; then
        return 1
      fi
      first=0
    else
      local lower_word
      lower_word=$(printf "%s" "$word" | tr '[:upper:]' '[:lower:]')
      if printf "%s" "$small_words" | grep -qw "$lower_word"; then
        : # small word is fine
      else
        if ! printf "%s" "$first_char" | grep -q '[A-Z]'; then
          return 1
        fi
      fi
    fi
  done
  return 0
}

# ---------------------------------------------------------------------------
# Lint a single skill directory
# ---------------------------------------------------------------------------

lint_skill() {
  local dir="$1"
  local skill_name
  skill_name=$(basename "$dir")
  local skill_md="$dir/SKILL.md"
  local readme_md="$dir/README.md"

  info "$dir/"

  # --- File existence ---
  if [ ! -f "$skill_md" ]; then
    fail "SKILL.md not found"
    return 1
  fi

  # --- Extract frontmatter ---
  local fm
  fm=$(extract_frontmatter "$skill_md")

  # 1. name field exists
  local name_val
  name_val=$(get_frontmatter_value "$fm" "name")
  if [ -z "$name_val" ]; then
    fail "frontmatter: 'name' field missing"
  else
    pass "frontmatter: name='$name_val'"
  fi

  # 2. name matches directory
  if [ -n "$name_val" ] && [ "$name_val" != "$skill_name" ]; then
    fail "frontmatter: name='$name_val' does not match directory '$skill_name'"
  elif [ -n "$name_val" ]; then
    pass "frontmatter: name='$name_val' matches directory"
  fi

  # 3. description field exists
  local desc_val
  desc_val=$(get_frontmatter_value "$fm" "description")
  if [ -z "$desc_val" ]; then
    fail "frontmatter: 'description' field missing"
  else
    pass "frontmatter: description present"
  fi

  # 4. description <= 40 words
  if [ -n "$desc_val" ]; then
    local desc_words
    desc_words=$(word_count "$desc_val")
    if [ "$desc_words" -gt 40 ]; then
      fail "frontmatter: description $desc_words words (>40)"
      if [ "$FIX" -eq 1 ]; then
        printf "      Suggested: shorten to ≤40 words (remove implementation details)\n" >&2
      fi
    else
      pass "frontmatter: description $desc_words words (≤40)"
    fi
  fi

  # 5. No prohibited fields
  local prohibited_found=""
  local field
  for field in author date version; do
    if printf "%s\n" "$fm" | grep -q "^${field}:"; then
      prohibited_found="$prohibited_found $field"
    fi
  done
  if [ -n "$prohibited_found" ]; then
    fail "frontmatter: prohibited field(s) found:$prohibited_found"
  else
    pass "frontmatter: no prohibited fields"
  fi

  # 6. YAML uses 2-space indent, no tabs in frontmatter
  local tab_lines
  tab_lines=$(printf "%s\n" "$fm" | grep -c $'\t' || true)
  if [ "$tab_lines" -gt 0 ]; then
    fail "frontmatter: contains tabs (use 2-space indent)"
  else
    pass "frontmatter: no tabs, spaces only"
  fi

  local bad_indent
  bad_indent=$(printf "%s\n" "$fm" | grep -E '^[ ]{1}[a-zA-Z]' || true)
  if [ -n "$bad_indent" ]; then
    fail "frontmatter: odd indentation detected (use 2-space indent)"
  else
    pass "frontmatter: 2-space indent consistent"
  fi

  # --- SKILL.md Structure ---

  # 7. ## When to Use section exists
  if grep -q '^## When to Use' "$skill_md"; then
    pass "required sections: 'When to Use' found"
  else
    fail "required sections: 'When to Use' missing"
  fi

  # 8. ## Workflow section exists
  if grep -q '^## Workflow' "$skill_md"; then
    pass "required sections: 'Workflow' found"
  else
    fail "required sections: 'Workflow' missing"
  fi

  # 9. ## Best Practices section exists
  if grep -q '^## Best Practices' "$skill_md"; then
    pass "required sections: 'Best Practices' found"
  else
    fail "required sections: 'Best Practices' missing"
  fi

  # 10. ## When to Use has ≤ 5 bullet items
  local wtucount
  wtucount=$(awk '/^## When to Use/{flag=1;next} /^## /{flag=0} flag && /^- /{count++} END{print count+0}' "$skill_md")
  if [ "$wtucount" -gt 5 ]; then
    fail "When to Use: $wtucount items (>5)"
  else
    pass "When to Use: $wtucount items (≤5)"
  fi

  # 11. Headings use title case for required sections
  local heading_issues=""
  local h
  for h in "When to Use" "Workflow" "Best Practices"; do
    if grep -q "^## $h" "$skill_md"; then
      : # ok
    elif grep -q "^## $(printf '%s' "$h" | tr '[:upper:]' '[:lower:]')" "$skill_md" || grep -q "^## $(printf '%s' "$h" | tr '[:lower:]' '[:upper:]')" "$skill_md"; then
      heading_issues="$heading_issues '$h'"
    fi
  done
  if [ -n "$heading_issues" ]; then
    fail "headings: required sections not in title case:$heading_issues"
  else
    pass "headings: required sections in title case"
  fi

  # 12. Max depth: 3 levels (## → ### → bullets)
  local deep_headings
  deep_headings=$(grep -c '^####' "$skill_md" || true)
  if [ "$deep_headings" -gt 0 ]; then
    fail "heading depth: $deep_headings #### headings found (max depth: 3 levels)"
  else
    pass "heading depth: max 3 levels (## → ### → bullets)"
  fi

  # 13. Target length: warn if > 500 lines
  local line_count
  line_count=$(wc -l < "$skill_md" | tr -d '[:space:]')
  if [ "$line_count" -gt 500 ]; then
    warn "SKILL.md: $line_count lines (target <500, consider sharding)"
  else
    pass "SKILL.md: $line_count lines (≤500)"
  fi

  # --- README.md Checks ---

  # 14. README.md exists
  if [ ! -f "$readme_md" ]; then
    fail "README.md: not found"
    return 1
  else
    pass "README.md: exists"
  fi

  # 15. README.md links to SKILL.md
  if grep -qE '\[SKILL\.md\]\(\./SKILL\.md\)' "$readme_md"; then
    pass "README.md: links to SKILL.md"
  else
    fail "README.md: missing link to SKILL.md"
  fi

  # 16. README.md has ## Usage section
  if grep -q '^## Usage' "$readme_md"; then
    pass "README.md: 'Usage' section found"
  else
    fail "README.md: 'Usage' section missing"
  fi

  # 17. README.md has ## Example section
  if grep -q '^## Example' "$readme_md"; then
    pass "README.md: 'Example' section found"
  else
    fail "README.md: 'Example' section missing"
  fi

  # 18. README.md ≤ 50 lines (warn)
  local readme_lines
  readme_lines=$(wc -l < "$readme_md" | tr -d '[:space:]')
  if [ "$readme_lines" -gt 50 ]; then
    warn "README.md: $readme_lines lines (max 50)"
  else
    pass "README.md: $readme_lines lines (≤50)"
  fi

  # --- Consistency Checks ---

  # 19. No duplicate content (heuristic: README has ### Step headings)
  local readme_steps
  readme_steps=$(grep -c '^### Step' "$readme_md" || true)
  if [ "$readme_steps" -gt 0 ]; then
    fail "duplicate content: README.md has $readme_steps '### Step' headings (should not duplicate workflow)"
  else
    pass "no duplicate content: README has no '### Step' headings"
  fi

  # 20. Code fences specify language
  local bad_fences
  bad_fences=$(grep -n '^```$' "$skill_md" || true)
  if [ -n "$bad_fences" ]; then
    local bad_count
    bad_count=$(printf "%s\n" "$bad_fences" | wc -l | tr -d '[:space:]')
    fail "code fences: $bad_count fence(s) without language tag"
    if [ "$FIX" -eq 1 ]; then
      printf "%s\n" "$bad_fences" | while IFS= read -r badline; do
        printf "      Line %s: add language (e.g., \`\`\`bash)\n" "$(printf "%s" "$badline" | cut -d: -f1)" >&2
      done
    fi
  else
    pass "code fences: all specify language"
  fi

  # Also check README.md for code fences without language
  local readme_bad_fences
  readme_bad_fences=$(grep -n '^```$' "$readme_md" || true)
  if [ -n "$readme_bad_fences" ]; then
    local readme_bad_count
    readme_bad_count=$(printf "%s\n" "$readme_bad_fences" | wc -l | tr -d '[:space:]')
    fail "README.md code fences: $readme_bad_count fence(s) without language tag"
  fi

  # 21. Cross-reference: SKILL.md mentions README.md and README.md mentions SKILL.md
  local skill_mentions_readme
  skill_mentions_readme=$(grep -c 'README\.md' "$skill_md" || true)
  local readme_mentions_skill
  readme_mentions_skill=$(grep -c 'SKILL\.md' "$readme_md" || true)

  if [ "$skill_mentions_readme" -gt 0 ] && [ "$readme_mentions_skill" -gt 0 ]; then
    pass "cross-reference: SKILL.md ↔ README.md"
  else
    if [ "$skill_mentions_readme" -eq 0 ]; then
      fail "cross-reference: SKILL.md does not mention README.md"
    fi
    if [ "$readme_mentions_skill" -eq 0 ]; then
      fail "cross-reference: README.md does not mention SKILL.md"
    fi
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  parse_args "$@"

  if [ "$ALL" -eq 1 ]; then
    local found=0
    for dir in opencode/skills/*/; do
      if [ -d "$dir" ]; then
        found=1
        # Reset per-skill counters
        local prev_errors=$ERRORS
        local prev_warnings=$WARNINGS
        lint_skill "$dir"
        info ""
      fi
    done
    if [ "$found" -eq 0 ]; then
      printf "No skill directories found in opencode/skills/*/\n" >&2
      exit 1
    fi
  else
    if [ ! -d "$SKILL_DIR" ]; then
      printf "Error: directory not found: %s\n" "$SKILL_DIR" >&2
      exit 1
    fi
    lint_skill "$SKILL_DIR"
  fi

  # Summary
  info ""
  if [ "$ERRORS" -gt 0 ] || [ "$WARNINGS" -gt 0 ]; then
    printf "%d error(s), %d warning(s) found.\n" "$ERRORS" "$WARNINGS"
    exit 1
  else
    printf "All checks passed.\n"
    exit 0
  fi
}

main "$@"

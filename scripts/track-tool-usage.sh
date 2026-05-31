#!/usr/bin/env bash
set -eo pipefail
export LC_ALL=C

# Configuration
HISTORY_FILE="${HISTORY_FILE:-}"
OUTPUT_FILE="${OUTPUT_FILE:-docs/tool-usage-report.md}"
TOP_N="${TOP_N:-20}"
TIMEOUT_PER_TOOL="${TIMEOUT_PER_TOOL:-10}"
TIMEOUT_NPM="${TIMEOUT_NPM:-30}"

# Project directories to scan for node_modules/.bin/
PROJECT_DIRS=(
  "/Users/katops/git/projects/panikaogarnia/lifebinder"
  "/Users/katops/git/projects/Comber"
  "/Users/katops/git/projects/ai-toolbox"
)

# Builtins to filter out
BUILTINS="cd echo export pwd set unset alias unalias type source bg fg jobs kill wait exec exit return read shift times trap umask hash builtin command disown enable help let local printf typeset ulimit test [ [[ true false"

# Keywords to filter out
KEYWORDS="if then while for case esac fi do done elif else function select until"

show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Track terminal tool usage and dependencies from shell history.

OPTIONS:
  --help           Show this help message
  --history-file   Path to shell history file (default: from HISTFILE env)
  --output         Output report path (default: docs/tool-usage-report.md)
  --top-n          Number of top tools to report (default: 20)

EXAMPLES:
  $(basename "$0")
  $(basename "$0") --history-file ~/.zsh_history --output report.md
  $(basename "$0") --top-n 30
EOF
}

sanitize_pii() {
  local line="$1"

  # URLs with embedded credentials: https://user:pass@host
  line=$(echo "$line" | sed -E 's|https?://[^[:space:]]*:[^[:space:]]*@[^[:space:]]*|[REDACTED]|g')

  # password=..., passwd=..., pass=...
  line=$(echo "$line" | sed -E 's/(password|passwd|pass)=[^[:space:]]+/\1=[REDACTED]/gi')

  # token=..., api_token=..., auth_token=...
  line=$(echo "$line" | sed -E 's/(token|api_token|auth_token)=[^[:space:]]+/\1=[REDACTED]/gi')

  # secret=..., client_secret=...
  line=$(echo "$line" | sed -E 's/(secret|client_secret)=[^[:space:]]+/\1=[REDACTED]/gi')

  # key=..., api_key=..., private_key=...
  line=$(echo "$line" | sed -E 's/(key|api_key|private_key)=[^[:space:]]+/\1=[REDACTED]/gi')

  # Bearer tokens (JWT and other bearer tokens)
  line=$(echo "$line" | sed -E 's/Bearer[[:space:]]+[^[:space:]]+/Bearer [REDACTED]/g')

  # OpenAI API keys (sk-...)
  line=$(echo "$line" | sed -E 's/sk-[[:alnum:]]+/[REDACTED]/g')

  # GitHub tokens (ghp_..., gho_...)
  line=$(echo "$line" | sed -E 's/gh[pou]_[[:alnum:]]+/[REDACTED]/g')

  echo "$line"
}

_is_builtin() {
  local word="$1"
  local b
  for b in $BUILTINS; do
    if [[ "$word" == "$b" ]]; then
      return 0
    fi
  done
  return 1
}

_is_keyword() {
  local word="$1"
  local k
  for k in $KEYWORDS; do
    if [[ "$word" == "$k" ]]; then
      return 0
    fi
  done
  return 1
}

_extract_tools() {
  local cmd="$1"

  # Handle multi-line commands: replace literal \n with space for parsing
  cmd=$(echo "$cmd" | sed 's/\\n/ /g')

  # Split by pipes and process each segment
  local segment
  echo "$cmd" | tr '|' '\n' | while IFS= read -r segment; do
    # Trim leading/trailing whitespace
    segment=$(echo "$segment" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Skip empty segments
    [[ -z "$segment" ]] && continue

    # Extract first word (the command/tool name)
    local first_word="${segment%% *}"
    first_word=$(echo "$first_word" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Skip empty first words
    [[ -z "$first_word" ]] && continue

    # Remove leading $ if present (variable expansion in command position)
    first_word="${first_word#\$}"

    # Skip assignments (foo=bar)
    [[ "$first_word" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && continue

    # Skip builtins
    if _is_builtin "$first_word"; then
      continue
    fi

    # Skip keywords
    if _is_keyword "$first_word"; then
      continue
    fi

    # Skip if it looks like a path or complex expression
    [[ "$first_word" =~ ^[[:space:]]*\( ]] && continue
    [[ "$first_word" =~ ^\{ ]] && continue

    # Output the tool name
    echo "$first_word"
  done
}

parse_history() {
  local histfile="${1:-}"
  local counts_tmpfile="${2:-}"

  # Determine history file: arg > HISTFILE env > ~/.zsh_history
  if [[ -z "$histfile" ]]; then
    histfile="${HISTFILE:-$HOME/.zsh_history}"
  fi

  if [[ ! -f "$histfile" ]]; then
    echo "Error: History file not found: $histfile" >&2
    return 1
  fi

  # Copy to temp file to avoid read-write conflicts
  local tmpfile
  tmpfile=$(mktemp)
  cp "$histfile" "$tmpfile"

  # Temp file for collecting all tool names
  local tools_tmpfile
  tools_tmpfile=$(mktemp)

  trap 'rm -f "$tmpfile" "$tools_tmpfile"' RETURN

  local current_cmd=""
  local in_multiline=false
  local malformed_count=0
  local total_entries=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    total_entries=$((total_entries + 1))

    # Sanitize PII before processing
    line=$(sanitize_pii "$line")

    # Check if this is an EXTENDED_HISTORY entry delimiter
    if echo "$line" | grep -qE '^:[[:space:]]+[0-9]+:[0-9]+;'; then
      # Process previous command if exists
      if [[ -n "$current_cmd" ]]; then
        _extract_tools "$current_cmd" >> "$tools_tmpfile"
      fi
      # Extract command after the semicolon
      current_cmd="${line#*;}"
      in_multiline=false
    elif echo "$line" | grep -qE '^:[[:space:]]+[0-9]+:[0-9]+:[0-9]+;'; then
      # Alternative EXTENDED_HISTORY format with 3 timestamps
      if [[ -n "$current_cmd" ]]; then
        _extract_tools "$current_cmd" >> "$tools_tmpfile"
      fi
      current_cmd="${line#*;}"
      in_multiline=false
    elif echo "$line" | grep -qE '^\:[[:space:]]'; then
      # Malformed line - starts with : but doesn't match extended history format
      if [[ -n "$current_cmd" ]]; then
        _extract_tools "$current_cmd" >> "$tools_tmpfile"
      fi
      malformed_count=$((malformed_count + 1))
      current_cmd=""
      in_multiline=false
    else
      # Non-extended line or continuation
      if [[ "$in_multiline" == true ]] || [[ -n "$current_cmd" ]]; then
        # Append to current command (multi-line continuation)
        current_cmd="$current_cmd\\n$line"
      else
        # Standalone non-extended line
        current_cmd="$line"
      fi
      in_multiline=true
    fi
  done < "$tmpfile"

  # Process the last command
  if [[ -n "$current_cmd" ]]; then
    _extract_tools "$current_cmd" >> "$tools_tmpfile"
  fi

  # Write counts to temp file for main() to read
  if [[ -n "$counts_tmpfile" ]]; then
    echo "$total_entries $malformed_count" > "$counts_tmpfile"
  fi

  # Count frequencies and sort descending
  if [[ -s "$tools_tmpfile" ]]; then
    sort "$tools_tmpfile" | uniq -c | sort -rn | sed 's/^[[:space:]]*//'
  fi
}

main() {
  local histfile="${HISTORY_FILE:-}"
  if [[ -z "$histfile" ]]; then
    histfile="${HISTFILE:-$HOME/.zsh_history}"
  fi

  echo "Parsing history file: $histfile"
  echo ""

  local count=0
  local enriched_tmp
  enriched_tmp=$(mktemp)

  local counts_tmpfile
  counts_tmpfile=$(mktemp)
  local parse_output_tmp
  parse_output_tmp=$(mktemp)

  set +e
  parse_history "$histfile" "$counts_tmpfile" > "$parse_output_tmp"
  local parse_exit=$?
  set -e

  local total_entries=0
  local malformed_count=0
  if [[ -s "$counts_tmpfile" ]]; then
    read -r total_entries malformed_count < "$counts_tmpfile"
  fi

  if [[ $parse_exit -ne 0 ]]; then
    echo "Warning: Could not parse history file. Generating empty report." >&2
    generate_report "$OUTPUT_FILE" "$TOP_N" "$total_entries" "$malformed_count" < /dev/null
    rm -f "$enriched_tmp" "$counts_tmpfile" "$parse_output_tmp"
    echo "Report appended to: $OUTPUT_FILE"
    exit 0
  fi

  while IFS= read -r line; do
    if [[ -z "$line" ]]; then
      continue
    fi

    local freq tool_name
    read -r freq tool_name <<< "$line"

    local resolved_path source_category
    resolved_path=$(resolve_binary "$tool_name")
    source_category=$(categorize_source "$resolved_path")

    local deps
    deps=$(resolve_deps "$tool_name" "$source_category" "$resolved_path")

    printf "%s\t%s\t%s\t%s\t%s\n" "$freq" "$tool_name" "$resolved_path" "$source_category" "$deps" >> "$enriched_tmp"

    count=$((count + 1))
    if [[ $count -ge $TOP_N ]]; then
      break
    fi
  done < "$parse_output_tmp"

  if [[ $count -eq 0 ]]; then
    echo "No commands found in history."
    generate_report "$OUTPUT_FILE" "$TOP_N" "$total_entries" "$malformed_count" < /dev/null
    rm -f "$enriched_tmp" "$counts_tmpfile" "$parse_output_tmp"
    echo "Report appended to: $OUTPUT_FILE"
    exit 0
  fi

  generate_report "$OUTPUT_FILE" "$TOP_N" "$total_entries" "$malformed_count" < "$enriched_tmp"
  rm -f "$enriched_tmp" "$counts_tmpfile" "$parse_output_tmp"

  echo "Report appended to: $OUTPUT_FILE"
}

resolve_binary() {
  local cmd="$1"
  local path

  if ! path=$(command -v "$cmd" 2>/dev/null); then
    echo "unknown"
    return
  fi

  if [[ "$path" == /* ]]; then
    python3 -c "import os; print(os.path.realpath('$path'))" 2>/dev/null || echo "$path"
  else
    local cmd_type
    cmd_type=$(type -t "$cmd" 2>/dev/null || true)
    if [[ "$cmd_type" == "builtin" ]]; then
      echo "builtin"
    elif [[ "$cmd_type" == "keyword" ]]; then
      echo "keyword"
    else
      echo "unknown"
    fi
  fi
}

categorize_source() {
  local binary_path="$1"

  case "$binary_path" in
    builtin|keyword|unknown)
      echo "$binary_path"
      return
      ;;
  esac

  if [[ -z "${_BREW_PREFIX:-}" ]]; then
    _BREW_PREFIX=$(brew --prefix 2>/dev/null || true)
  fi
  if [[ -z "${_NPM_ROOT_GLOBAL:-}" ]]; then
    _NPM_ROOT_GLOBAL=$(npm root -g 2>/dev/null || true)
  fi

  if [[ -n "${_BREW_PREFIX:-}" && "$binary_path" == "$_BREW_PREFIX"* ]] || \
     [[ "$binary_path" == /usr/local/Cellar/* ]] || \
     [[ "$binary_path" == /opt/homebrew/Cellar/* ]]; then
    echo "Homebrew"
    return
  fi

  if [[ -n "${_NPM_ROOT_GLOBAL:-}" && "$binary_path" == "$_NPM_ROOT_GLOBAL"* ]]; then
    echo "npm"
    return
  fi

  if [[ "$binary_path" == */pipx/venvs/* ]]; then
    echo "pipx"
    return
  fi

  case "$binary_path" in
    /usr/bin/*|/bin/*|/usr/sbin/*|/sbin/*|/usr/local/bin/*)
      echo "system"
      return
      ;;
  esac

  echo "unknown"
}

_run_with_timeout() {
    local timeout_sec="$1"
    local out_file="$2"
    shift 2
    ( "$@" > "$out_file" 2>&1 ) &
    local pid=$!
    ( sleep "$timeout_sec" && kill "$pid" 2>/dev/null ) &
    local sleeper=$!
    wait "$pid" 2>/dev/null
    local rc=$?
    kill "$sleeper" 2>/dev/null
    wait "$sleeper" 2>/dev/null
    return $rc
}

resolve_deps() {
    local cmd_name="$1"
    local source_category="$2"
    local resolved_path="${3:-}"

    local tmpfile output rc

    case "$source_category" in
        Homebrew)
            local formula="$cmd_name"
            if [[ "$resolved_path" == */Cellar/* ]]; then
                formula=$(echo "$resolved_path" | sed -E 's|.*/Cellar/([^/]+)/.*|\1|')
            fi

            tmpfile=$(mktemp)
            _run_with_timeout "$TIMEOUT_PER_TOOL" "$tmpfile" env HOMEBREW_NO_ENV_HINTS=1 brew deps --direct "$formula"
            rc=$?
            output=$(cat "$tmpfile" 2>/dev/null)
            rm -f "$tmpfile"

            output=$(echo "$output" | grep -vE '^(Warning:|Hide these hints)')

            if [[ $rc -ne 0 ]]; then
                if [[ "$output" == *"No available formula"* ]] || [[ "$output" == *"Error:"* ]]; then
                    echo "formula not found"
                else
                    echo "no dependencies"
                fi
            elif [[ -z "$output" ]]; then
                echo "no dependencies"
            else
                echo "$output" | tr '\n' ',' | sed 's/,$//'
            fi
            ;;

        npm)
            tmpfile=$(mktemp)
            _run_with_timeout "$TIMEOUT_NPM" "$tmpfile" npm ls -g "$cmd_name" --depth=0 --json
            rc=$?
            output=$(cat "$tmpfile" 2>/dev/null)
            rm -f "$tmpfile"

            if [[ $rc -ne 0 ]] || [[ -z "$output" ]]; then
                echo "no dependencies or not installed"
            else
                local deps
                deps=$(echo "$output" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    pkg = sys.argv[1]
    if 'dependencies' in data and pkg in data['dependencies']:
        pkg_data = data['dependencies'][pkg]
        if 'dependencies' in pkg_data and pkg_data['dependencies']:
            print(', '.join(pkg_data['dependencies'].keys()))
        else:
            print('no dependencies')
    else:
        print('no dependencies')
except Exception:
    print('no dependencies')
" "$cmd_name" 2>/dev/null)
                echo "${deps:-no dependencies}"
            fi
            ;;

        pipx)
            tmpfile=$(mktemp)
            _run_with_timeout "$TIMEOUT_PER_TOOL" "$tmpfile" pipx list --json
            rc=$?
            output=$(cat "$tmpfile" 2>/dev/null)
            rm -f "$tmpfile"

            if [[ $rc -ne 0 ]] || [[ -z "$output" ]]; then
                echo "pipx list failed"
            else
                local pkg_name
                pkg_name=$(echo "$resolved_path" | sed -E 's|.*/pipx/venvs/([^/]+)/.*|\1|')

                local deps
                deps=$(echo "$output" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    pkg = sys.argv[1]
    venvs = data.get('venvs', {})
    if pkg in venvs:
        meta = venvs[pkg].get('metadata', {})
        pipx_meta = meta.get('pipx_metadata', {})
        venv_meta = pipx_meta.get('venv_metadata', {})
        installed = venv_meta.get('installed_packages', {})
        if installed:
            deps_list = [p for p in installed.keys() if p.lower() != pkg.lower()]
            if deps_list:
                print(', '.join(deps_list))
            else:
                print('no dependencies')
        else:
            print('no dependencies')
    else:
        print('package not found')
except Exception:
    print('no deps tracked')
" "$pkg_name" 2>/dev/null)
                echo "${deps:-no deps tracked}"
            fi
            ;;

        system|builtin|keyword|unknown)
            echo "no deps tracked"
            ;;

        *)
            echo "no deps tracked"
            ;;
    esac
}

_truncate() {
  local str="$1"
  local max_len="${2:-100}"
  if [[ ${#str} -gt $max_len ]]; then
    echo "${str:0:$((max_len-3))}..."
  else
    echo "$str"
  fi
}

_escape_md() {
  local str="$1"
  str="${str//|/\|}"      # escape pipe for tables
  str="${str//\*/\\*}"     # escape asterisks
  str="${str//_/\_}"      # escape underscores
  echo "$str"
}

generate_report() {
  local output_file="$1"
  local top_n="$2"
  local total_entries="${3:-0}"
  local malformed_count="${4:-0}"

  mkdir -p "$(dirname "$output_file")"

  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  if [[ ! -f "$output_file" ]]; then
    {
      echo "# CLI Tool Usage Report"
      echo ""
    } > "$output_file"
  fi

  local data_tmp
  data_tmp=$(mktemp)
  cat > "$data_tmp"

  local total_unique
  total_unique=$(wc -l < "$data_tmp" | tr -d ' ')

  local prev_tools_tmp
  prev_tools_tmp=$(mktemp)

  if [[ -f "$output_file" ]] && grep -q '## Report:' "$output_file"; then
    local last_report_tmp
    last_report_tmp=$(mktemp)

    awk '
      /## Report:/ { start = NR }
      { lines[NR] = $0 }
      END {
        if (start > 0) {
          for (i = start; i <= NR; i++) {
            print lines[i]
          }
        }
      }
    ' "$output_file" > "$last_report_tmp"

    awk -F'|' '
      BEGIN { in_table = 0 }
      /### Top [0-9]+ Commands/ { in_table = 1; next }
      in_table && /^### / { in_table = 0 }
      in_table && /^[[:space:]]*\|/ && !/Rank.*Command/ && !/^\|[-|]/ {
        cmd = $3
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", cmd)
        if (cmd != "" && cmd != "Command") {
          print cmd
        }
      }
    ' "$last_report_tmp" | sort -u > "$prev_tools_tmp"

    rm -f "$last_report_tmp"
  fi

  local current_tools_tmp
  current_tools_tmp=$(mktemp)
  awk -F'\t' '{print $2}' "$data_tmp" | sort -u > "$current_tools_tmp"

  local new_tools removed_tools
  if [[ -s "$prev_tools_tmp" ]]; then
    new_tools=$(comm -23 "$current_tools_tmp" "$prev_tools_tmp" | tr '\n' ', ' | sed 's/, $//')
    removed_tools=$(comm -13 "$current_tools_tmp" "$prev_tools_tmp" | tr '\n' ', ' | sed 's/, $//')
  fi

  local source_breakdown_tmp
  source_breakdown_tmp=$(mktemp)
  awk -F'\t' '{print $4}' "$data_tmp" | sort | uniq -c | sort -rn | sed 's/^[[:space:]]*//' > "$source_breakdown_tmp"

  {
    echo "## Report: $timestamp"
    echo ""
    echo "### Summary Stats"
    echo ""
    echo "- **Total unique commands:** $total_unique"
    echo "- **Total history entries parsed:** $total_entries"
    echo "- **Skipped malformed entries:** $malformed_count"
    echo "- **Breakdown by source:**"
    echo ""
    echo "| Source | Count |"
    echo "|--------|-------|"

    while IFS= read -r line; do
      local src_count src_name
      read -r src_count src_name <<< "$line"
      echo "| $src_name | $src_count |"
    done < "$source_breakdown_tmp"

    echo ""
    echo "### Top $top_n Commands"
    echo ""
    echo "| Rank | Command | Frequency | Source | Path |"
    echo "|------|---------|-----------|--------|------|"

    local rank=0
    while IFS=$'\t' read -r freq cmd path src deps; do
      rank=$((rank + 1))
      local escaped_cmd truncated_path
      escaped_cmd=$(_escape_md "$cmd")
      truncated_path=$(_truncate "$path")
      echo "| $rank | $escaped_cmd | $freq | $src | $truncated_path |"
    done < <(head -n "$top_n" "$data_tmp")

    echo ""
    echo "### Dependency Chains"
    echo ""

    rank=0
    while IFS=$'\t' read -r freq cmd path src deps; do
      rank=$((rank + 1))
      local truncated_deps
      truncated_deps=$(_truncate "$deps")
      echo "- **$cmd** → $truncated_deps"
    done < <(head -n "$top_n" "$data_tmp")

    echo ""
    echo "### Changed Since Last Run"
    echo ""

    if [[ -s "$prev_tools_tmp" ]]; then
      if [[ -n "$new_tools" ]]; then
        echo "- **New:** $new_tools"
      else
        echo "- **New:** (none)"
      fi

      if [[ -n "$removed_tools" ]]; then
        echo "- **Removed:** $removed_tools"
      else
        echo "- **Removed:** (none)"
      fi
    else
      echo "- First run — no previous data to compare."
    fi

    echo ""
  } >> "$output_file"

  _compute_trends "$output_file" >> "$output_file"

  rm -f "$data_tmp" "$prev_tools_tmp" "$current_tools_tmp" "$source_breakdown_tmp"
}

_compute_trends() {
  local report_file="$1"

  local total_runs
  total_runs=$(grep -c '^## Report:' "$report_file" 2>/dev/null || echo 0)
  if [[ "$total_runs" -le 1 ]]; then
    return
  fi

  python3 -c "
import sys, re

report_file = '$report_file'
try:
    with open(report_file) as f:
        content = f.read()
except FileNotFoundError:
    sys.exit(0)

sections = re.split(r'^## Report: ', content, flags=re.MULTILINE)
sections = [s for s in sections if s.strip()]

if len(sections) <= 1:
    sys.exit(0)

runs = []
for section in sections[1:]:
    lines = section.strip().split('\n')
    timestamp = lines[0].strip()
    in_table = False
    commands = {}
    for line in lines:
        if '### Top' in line and 'Commands' in line:
            in_table = True
            continue
        if in_table and line.startswith('### '):
            break
        if in_table and line.startswith('|') and 'Rank' not in line and '---' not in line:
            parts = [p.strip() for p in line.split('|')]
            if len(parts) >= 5:
                cmd = parts[2]
                freq = parts[3]
                if cmd and freq and cmd != 'Command':
                    try:
                        commands[cmd] = int(freq)
                    except ValueError:
                        pass
    if commands:
        runs.append({'timestamp': timestamp, 'commands': commands})

if len(runs) <= 1:
    sys.exit(0)

first = runs[0]
last = runs[-1]

first_date = first['timestamp'].split()[0]
last_date = last['timestamp'].split()[0]

print()
print('### Usage Trends')
print()
print(f'- **Total runs:** {len(runs)}')
print(f'- **Date range:** {first_date} to {last_date}')
print(f'- **Tools in first run:** {len(first[\"commands\"])}')
print(f'- **Tools in latest run:** {len(last[\"commands\"])}')
print()
print('| Tool | First Freq | Latest Freq | Trend |')
print('|------|-----------|-------------|-------|')

for cmd, freq in sorted(last['commands'].items(), key=lambda x: x[1], reverse=True):
    first_freq = first['commands'].get(cmd)
    if first_freq is not None:
        if freq > first_freq:
            trend = 'up'
        elif freq < first_freq:
            trend = 'down'
        else:
            trend = 'stable'
        print(f'| {cmd} | {first_freq} | {freq} | {trend} |')
    else:
        print(f'| {cmd} | (new) | {freq} | up |')
" 2>/dev/null || true
}

# CLI argument parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      show_help
      exit 0
      ;;
    --history-file)
      HISTORY_FILE="$2"
      shift 2
      ;;
    --output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    --top-n)
      TOP_N="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help >&2
      exit 1
      ;;
  esac
done

main

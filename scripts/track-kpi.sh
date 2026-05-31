#!/bin/bash
# Skill KPI Tracker
# Logs AI skill invocations and outcomes, generates effectiveness reports.
# Usage:
#   bash track-kpi.sh --skill <name> --outcome <success|fail> --session <id> [--duration <sec>]
#   bash track-kpi.sh --report

set -euo pipefail

KPI_FILE="${KPI_FILE:-$HOME/.opencode/kpi.csv}"
ACTION="${1:-}"

show_usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Track AI skill effectiveness over time.

LOG MODE:
  --skill <name>     Skill name (e.g., graphify, review)
  --outcome <val>    success or fail
  --session <id>     Session identifier (e.g., bg_abc123)
  --duration <sec>   Duration in seconds (optional)
  Example: $(basename "$0") --skill graphify --outcome success --session bg_abc123 --duration 45

REPORT MODE:
  --report           Generate KPI summary from log
  --skill <name>     Filter report to specific skill (optional)

ENVIRONMENT:
  KPI_FILE           Path to KPI log (default: ~/.opencode/kpi.csv)
EOF
}

init_log() {
  local dir
  dir=$(dirname "$KPI_FILE")
  mkdir -p "$dir"
  if [[ ! -f "$KPI_FILE" ]]; then
    echo "timestamp,skill,outcome,session_id,duration_sec" > "$KPI_FILE"
  fi
}

log_entry() {
  local skill="" outcome="" session="" duration=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skill) skill="$2"; shift 2 ;;
      --outcome) outcome="$2"; shift 2 ;;
      --session) session="$2"; shift 2 ;;
      --duration) duration="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; show_usage; exit 1 ;;
    esac
  done

  if [[ -z "$skill" || -z "$outcome" || -z "$session" ]]; then
    echo "Error: --skill, --outcome, and --session are required" >&2
    show_usage
    exit 1
  fi

  if [[ "$outcome" != "success" && "$outcome" != "fail" ]]; then
    echo "Error: --outcome must be 'success' or 'fail'" >&2
    exit 1
  fi

  init_log
  local ts
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$ts,$skill,$outcome,$session,${duration:-}" >> "$KPI_FILE"
  echo "Logged: $skill | $outcome | $session"
}

generate_report() {
  local filter_skill=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skill) filter_skill="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  if [[ ! -f "$KPI_FILE" ]]; then
    echo "No KPI data found at $KPI_FILE"
    exit 0
  fi

  python3 -c "
import csv
from collections import defaultdict

kpi_file = '$KPI_FILE'
filter_skill = '$filter_skill'

with open(kpi_file) as f:
    reader = csv.DictReader(f)
    if reader.fieldnames is None:
        print('Empty KPI file')
        exit(0)

    skills = defaultdict(lambda: {'total': 0, 'success': 0, 'fail': 0, 'sessions': set(), 'durations': []})

    for row in reader:
        skill = row.get('skill', '').strip()
        outcome = row.get('outcome', '').strip()
        session = row.get('session_id', '').strip()
        duration = row.get('duration_sec', '').strip()

        if not skill:
            continue
        if filter_skill and skill != filter_skill:
            continue

        skills[skill]['total'] += 1
        if outcome == 'success':
            skills[skill]['success'] += 1
        elif outcome == 'fail':
            skills[skill]['fail'] += 1

        if session:
            skills[skill]['sessions'].add(session)
        if duration:
            try:
                skills[skill]['durations'].append(int(duration))
            except ValueError:
                pass

    if not skills:
        print('No matching KPI data found')
        exit(0)

    print()
    print('## Skill KPI Summary')
    print()
    print('| Skill | Invocations | Success | Fail | Rate | Sessions | Avg Duration |')
    print('|-------|------------|---------|------|------|----------|--------------|')

    for skill, data in sorted(skills.items(), key=lambda x: x[1]['total'], reverse=True):
        total = data['total']
        success = data['success']
        fail = data['fail']
        rate = f'{success / total * 100:.0f}%' if total > 0 else '-'
        sessions = len(data['sessions'])
        avg_dur = f'{sum(data[\"durations\"]) // len(data[\"durations\"])}s' if data['durations'] else '-'
        print(f'| {skill} | {total} | {success} | {fail} | {rate} | {sessions} | {avg_dur} |')
" 2>/dev/null || echo "Error generating KPI report"
}

main() {
  case "${1:-}" in
    --report)
      shift
      generate_report "$@"
      ;;
    --skill)
      log_entry "$@"
      ;;
    --help|-h)
      show_usage
      ;;
    *)
      if [[ -z "${1:-}" ]]; then
        show_usage
      else
        echo "Unknown option: $1" >&2
        show_usage
        exit 1
      fi
      ;;
  esac
}

main "$@"

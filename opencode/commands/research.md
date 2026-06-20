---
description: Research external repos for patterns, anti-patterns, and adoption recommendations
---

# /research

Research external repositories to discover architectural patterns, anti-patterns, and prioritized adoption recommendations.

## What It Does

- Discovers candidate repos matching a research theme via web search
- Shallow-clones repos for analysis
- Extracts quantitative metrics and qualitative patterns
- Builds a comparative matrix across studied repos
- Produces prioritized adoption recommendations
- Writes a structured report to `docs/research/<theme>-<date>.md`

## Usage

1. `/research` -- interactive: specify theme and scope
2. `/research testing patterns in Go CLI tools` -- research a specific theme
3. `/research compare auth approaches in Node.js frameworks` -- comparative study

## Example

> `/research testing patterns in popular Go CLI projects`

→ Scope defined → Discover 3-5 repos → Clone → Analyze → Compare → Recommend → Report at `docs/research/testing-patterns-2026-06-16.md`

See [SKILL.md](../skills/repo-research/SKILL.md) for full implementation details.
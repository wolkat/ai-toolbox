---
name: repo-research
description: Research external repositories for architectural patterns, anti-patterns, and adoption recommendations. Triggers when user asks to analyze repos, compare approaches, or study external codebases.
---

# Repo Research Skill

Structured multi-repo research workflow that discovers, clones, analyzes, compares, and reports on external repositories to extract actionable insights for your project.

## When to Use

- User asks to analyze or study external repositories
- User wants to compare architectural patterns across repos
- User needs industry benchmarks or best practices research
- User requests adoption recommendations from open-source projects
- User wants to identify anti-patterns in external codebases

## Workflow

### Step 1: SCOPE — Define Research Theme

Determine the research scope from the user's request:

- Extract the **theme**: architecture, patterns, security, testing, performance, DX
- Identify the **local project** context (current repo or a specified path)
- Determine how many repos to study (default: 3-5, max: 8)
- Write a one-paragraph scope statement summarizing intent

If `.slim/repo-research/manifest.json` exists, read it before starting. Reuse completed entries and only process new or stale ones.

### Step 2: DISCOVER — Find Candidate Repos

Use `exa-search` skill via Task agents for token isolation:

- Search for repos matching the theme (e.g., "Go CLI project structure best practices")
- Prefer repos with: recent commits, good documentation, clear architecture
- Aim for 2x candidates — you'll narrow down in Step 3
- Record candidate URLs and brief rationale

### Step 3: CLONE — Shallow-Clone Repos

Follow the `clonedeps` skill pattern for cloning:

1. Verify refs with `git ls-remote` where practical
2. Shallow clone: `git clone --depth 1 <url>`
3. Clone into `.slim/repo-research/repos/<safe-name>/`
4. Safe name: replace `/` with `__`, strip `.git`, no unsafe path chars
5. Do not run install/build/test scripts from cloned repos
6. One clone per source repo, even if studying multiple aspects

### Step 4: ANALYZE — Extract Patterns

For each cloned repo:

1. Run `graphify extract <path>` if graphify is available, otherwise read key files manually
2. Identify: directory structure, entry points, dependency graph, test patterns
3. Note: god modules, circular deps, error handling conventions, config patterns
4. Use the `scripts/compare-metrics.mjs` helper to extract quantitative metrics from `graphify-out/graph.json` files

Focus on patterns relevant to the research theme. Do not produce exhaustive catalogs.

### Step 5: COMPARE — Build Comparative Matrix

Create a comparison across all studied repos:

| Dimension | Repo A | Repo B | Repo C | Local Project |
|-----------|--------|--------|--------|---------------|
| Pattern X | uses Y | uses Z | avoids | uses Z |
| ... | ... | ... | ... | ... |

Quantitative metrics (from compare-metrics.mjs):
- Node count, edge count, community count, god nodes
- Edge-type distribution, top dependencies
- Test file ratio, config file count

### Step 6: RECOMMEND — Prioritized Adoption List

For each finding, assign:

- **Priority**: High / Medium / Low
- **Effort**: Small / Medium / Large
- **Category**: Pattern, Anti-pattern, Tool, Config, Process

Format as an actionable list mapped to the local project.

### Step 7: REPORT — Write Structured Output

Write the final report to:

```
docs/research/<theme>-<YYYY-MM-DD>.md
```

Report structure:

```markdown
# Research: <Theme>

**Date:** YYYY-MM-DD
**Repos studied:** N
**Scope:** <one-paragraph scope statement>

## Summary

<tldr>

## Comparative Matrix

<table from Step 5>

## Quantitative Metrics

<table from compare-metrics.mjs>

## Recommendations

<prioritized list from Step 6>

## Per-Repo Analysis

### <repo-name>

- Architecture: ...
- Key patterns: ...
- Anti-patterns: ...
- Relevant to local project: ...

## Methodology

- Repos cloned with shallow depth
- Analysis: graphify + manual review
- Metrics: compare-metrics.mjs
```

After writing the report, update `.slim/repo-research/manifest.json` with the completed research state.

## Manifest Format

The manifest tracks research state across sessions:

```json
{
  "version": "1.0.0",
  "updatedAt": "2026-06-15T00:00:00.000Z",
  "theme": "testing-patterns",
  "repos": [
    {
      "name": "example-repo",
      "url": "https://github.com/org/example-repo.git",
      "ref": "main",
      "path": ".slim/repo-research/repos/org__example-repo",
      "status": "analyzed",
      "analyzedAt": "2026-06-15T00:00:00.000Z"
    }
  ],
  "reportPath": "docs/research/testing-patterns-2026-06-15.md"
}
```

Status values: `cloned`, `analyzing`, `analyzed`, `failed`

## Best Practices

1. **Start from existing state** — always check manifest before re-scanning
2. **Delegate to Task agents** — use exa-search in subagents for token isolation
3. **Reuse graphify** — don't re-extract if `graphify-out/` already exists
4. **Keep scope tight** — a theme like "testing" is better than "everything about this repo"
5. **Shallow clones only** — never install or build cloned repos
6. **Max 8 repos** — diminishing returns beyond 5-6 studied repos
7. **Use compare-metrics.mjs** — deterministic metric extraction is faster and more reliable than manual JSON reading
8. **Write manifest early** — create it after cloning so interrupted sessions can resume
# Repo Research - Multi-Repository Analysis Skill

Analyze external repositories to discover architectural patterns, anti-patterns, and prioritized adoption recommendations for your project.

## Usage

1. Describe what you want to research (e.g., "analyze testing patterns in popular Go CLI projects")
2. The skill discovers candidate repos, shallow-clones them, extracts metrics, and produces a structured report
3. Find the report in `docs/research/<theme>-<date>.md`

## What It Does

- Discovers and shallow-clones candidate repos via exa-search
- Extracts architectural patterns and quantitative metrics via graphify + compare-metrics.mjs
- Builds a comparative matrix across studied repos and your local project
- Produces prioritized adoption recommendations (High/Medium/Low)
- Tracks research state in `.slim/repo-research/manifest.json` for resumability

## Example

> "Research authentication patterns in Node.js web frameworks"

→ Scope defined → Discover 5 repos → Clone → Analyze each → Compare → Recommend → Report written to `docs/research/auth-patterns-2026-06-16.md`

See [SKILL.md](./SKILL.md) for full implementation details.

---

## Data Location

| Type | Location | Notes |
|------|----------|-------|
| Reports | `docs/research/<theme>-<date>.md` | Project-tracked |
| Manifest | `.slim/repo-research/manifest.json` | Resumable state |
| Cloned repos | `.slim/repo-research/repos/` | Gitignored, shallow clones |
| Metrics cache | `.slim/repo-research/metrics/` | compare-metrics.mjs output |

## Integration with ai-toolbox

```bash
# If using stow
cd ~/git/projects/ai-toolbox && make restow-opencode

# Or manual copy
cp -r ~/git/projects/ai-toolbox/opencode/skills/repo-research ~/.config/opencode/skills/
```
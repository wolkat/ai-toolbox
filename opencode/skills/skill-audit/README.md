# Skill Audit

Cross-check new OpenCode skills against your existing skills before installation.

## Usage

When you want to install a skill:
1. Request install (e.g., "install cloudflare skill")
2. Skill reads your current skills directory
3. Presents audit report with overlap analysis
4. Asks for confirmation before proceeding

## What It Checks

- **Functional overlap** — skills serving the same purpose
- **Trigger conflicts** — multiple skills activating on same keywords
- **Redundancy** — duplicate capabilities with existing skills
- **Dependencies** — prerequisite skills or tools needed

## Example

> "Install the cloudflare skill"

→ Audit report showing existing cloudflare skill → compare versions → confirm replace or keep

See [SKILL.md](./SKILL.md) for full implementation details.

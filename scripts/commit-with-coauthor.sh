#!/bin/bash
# OpenCode AI-assisted commit helper with correct co-author attribution
# Usage: ./commit-with-coauthor.sh "commit message"
# Or: git ai-commit "commit message" (after setup)

set -euo pipefail

MSG="${1:-}"
SCOPE="${2:-}"

if [ -z "$MSG" ]; then
  cat << 'EOF'
Usage: commit-with-coauthor.sh "type(scope): description"

Examples:
  commit-with-coauthor.sh "feat(skill): add verification steps"
  commit-with-coauthor.sh "fix: resolve path error" "plugin"

Auto-detects model from git config (ai.model) or defaults to kimi-k2.6.
EOF
  exit 1
fi

# Get model from git config or use default
MODEL=$(git config --get ai.model 2>/dev/null || echo "kimi-k2.6")

# Get user info from git config
USER_NAME=$(git config --get user.name 2>/dev/null || echo "user")
USER_EMAIL=$(git config --get user.email 2>/dev/null || echo "user@example.com")

# Build commit message with trailers
COMMIT_MSG="$MSG"

# Add scope to body if provided
if [ -n "$SCOPE" ]; then
  COMMIT_MSG="$COMMIT_MSG

Scope: $SCOPE"
fi

COMMIT_MSG="$COMMIT_MSG

Signed-off-by: $USER_NAME <$USER_EMAIL>
Co-authored-by: opencode ($MODEL)"

# Create the commit
git commit -m "$COMMIT_MSG"

echo "✓ Committed with Co-authored-by: opencode ($MODEL)"

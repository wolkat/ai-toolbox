#!/bin/bash
# Setup global git co-author enforcement for AI-assisted commits
# Run once: bash scripts/setup-coauthor.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== OpenCode Co-Author Setup ==="
echo ""

# 1. Store current model in git config
echo "--- 1. Setting AI model in git config ---"
git config --global ai.model "kimi-k2.6"
echo "   ✓ git config ai.model = $(git config --get ai.model)"

# 2. Create global git alias 'ai-commit'
echo ""
echo "--- 2. Creating git alias 'ai-commit' ---"
git config --global alias.ai-commit "!bash -c 'cd \"\$(git rev-parse --show-toplevel)\" && \"$REPO_ROOT/scripts/commit-with-coauthor.sh\" \"\$@\"' _"
echo "   ✓ git ai-commit 'your message'  →  commits with correct co-author"

# 3. Add shell function to .zshrc (if zsh is shell)
ZSHRC="$HOME/.zshrc"
BASHRC="$HOME/.bashrc"

add_gac_function() {
  local rcfile="$1"
  if [ -f "$rcfile" ]; then
    if ! grep -q "^# AI-assisted commit with correct co-author" "$rcfile" 2>/dev/null; then
      cat >> "$rcfile" << 'EOF'

# AI-assisted commit with correct co-author
# Usage: gac "feat: add new feature"
gac() {
  local msg="$1"
  if [ -z "$msg" ]; then
    echo "Usage: gac 'commit message'"
    return 1
  fi
  local model
  model=$(git config --get ai.model 2>/dev/null || echo "kimi-k2.6")
  local user_name
  user_name=$(git config --get user.name 2>/dev/null || echo "user")
  local user_email
  user_email=$(git config --get user.email 2>/dev/null || echo "user@example.com")
  git commit -m "$msg

Signed-off-by: $user_name <$user_email>
Co-authored-by: opencode ($model)"
}
EOF
      echo "   ✓ Added gac() function to $rcfile"
      return 0
    else
      echo "   ✓ gac() already exists in $rcfile"
      return 0
    fi
  fi
  return 1
}

echo ""
echo "--- 3. Adding shell function ---"
if [ -n "${ZSH_VERSION:-}" ] || [ "${SHELL:-}" = "/bin/zsh" ] || [ -f "$ZSHRC" ]; then
  add_gac_function "$ZSHRC" || echo "   ! Could not find .zshrc"
elif [ -n "${BASH_VERSION:-}" ] || [ "${SHELL:-}" = "/bin/bash" ] || [ -f "$BASHRC" ]; then
  add_gac_function "$BASHRC" || echo "   ! Could not find .bashrc"
else
  echo "   ! Could not detect shell. Please add gac() function manually."
fi

# 4. Add git commit template with reminder
echo ""
echo "--- 4. Setting up commit template ---"
TEMPLATE_DIR="$HOME/.config/git"
mkdir -p "$TEMPLATE_DIR"
cat > "$TEMPLATE_DIR/commit-template" << EOF
# type(scope): description
#
# Types: feat, fix, refactor, docs, test, chore, perf, style, ci
# Remember: Co-authored-by must use the ACTUAL model (kimi-k2.6)
#           NOT the opencode.json provider model (minimax-m2.5-free)
#
EOF
git config --global commit.template "$TEMPLATE_DIR/commit-template"
echo "   ✓ Commit template set: $TEMPLATE_DIR/commit-template"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Usage:"
echo "  gac 'feat: add new feature'           # Shell function (after reload)"
echo "  git ai-commit 'feat: add new feature' # Git alias"
echo "  $REPO_ROOT/scripts/commit-with-coauthor.sh 'feat: add new feature'"
echo ""
echo "Current model: $(git config --get ai.model)"
echo ""
echo "To update model: git config --global ai.model <new-model>"

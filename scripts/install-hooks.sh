#!/usr/bin/env bash
# Install git hooks for ai-toolbox
set -euo pipefail

git config core.hooksPath hooks
echo "✅ Git hooks installed. Hook path: hooks/"
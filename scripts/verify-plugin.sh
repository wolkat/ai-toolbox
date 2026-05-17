#!/bin/bash
# OpenCode Plugin Pre-Install Verification Script
# Usage: ./verify-plugin.sh <package-name>
# Based on: ai-toolbox/docs/plugin-install-guidelines.md

set -euo pipefail

PKG="${1:-}"

if [ -z "$PKG" ]; then
  echo "Usage: $0 <package-name>"
  echo "Example: $0 opencode-snip"
  echo "Example: $0 @ramarivera/opencode-model-announcer"
  exit 1
fi

echo "=== OpenCode Plugin Verification ==="
echo "Package: $PKG"
echo ""

# 1. Check npm registry
echo "--- 1. Checking npm registry ---"
if npm view "$PKG" version 2>/dev/null; then
  echo "   ✓ Package found on npm"
  
  # 2. Check peer dependencies
  echo ""
  echo "--- 2. Peer Dependencies ---"
  PEERS=$(npm view "$PKG" peerDependencies 2>/dev/null || echo "None")
  if [ "$PEERS" != "None" ] && [ -n "$PEERS" ]; then
    echo "   Required peers: $PEERS"
    
    # Check if peers are installed
    echo ""
    echo "--- 3. Peer Dependency Status ---"
    PEER_NAMES=$(echo "$PEERS" | tr ',' '\n' | sed 's/^[[:space:]]*//' | cut -d: -f1 | tr -d ' "{}')
    for PEER in $PEER_NAMES; do
      if [ -d "$HOME/.config/opencode/node_modules/$PEER" ]; then
        echo "   ✓ $PEER installed"
      else
        echo "   ✗ $PEER NOT installed (may cause failure)"
      fi
    done
  else
    echo "   No peer dependencies"
  fi
  
  # 3. Check if already installed
  echo ""
  echo "--- 4. Current Install Status ---"
  if [ -d "$HOME/.config/opencode/node_modules/$PKG" ]; then
    CURRENT=$(cat "$HOME/.config/opencode/node_modules/$PKG/package.json" 2>/dev/null | grep '"version"' | head -1 | cut -d'"' -f4)
    echo "   Already installed: version $CURRENT"
  else
    echo "   Not currently installed"
  fi
  
  echo ""
  echo "=== VERIFICATION PASSED ==="
  echo "Ready to install: bun add $PKG@latest"
  
else
  echo "   ✗ Package NOT found on npm"
  echo ""
  echo "--- Possible Reasons ---"
  echo "1. Wrong package name (check for scoped name: @owner/$PKG)"
  echo "2. GitHub-only plugin (not published to npm)"
  echo "3. Typo in package name"
  echo ""
  echo "--- Suggestions ---"
  
  # Try to find similar packages
  echo "Searching for similar packages..."
  npm search "${PKG#@*/}" --limit 3 2>/dev/null | grep -E "NAME|${PKG#@*/}" || echo "   No similar packages found"
  
  echo ""
  echo "If this is a GitHub-only plugin:"
  echo "  1. Clone repo to ~/.config/opencode/plugin/$PKG"
  echo "  2. Add to 'instructions' array in opencode.json"
  echo "  3. Do NOT add to 'plugin' array"
  echo ""
  echo "=== VERIFICATION FAILED ==="
  exit 1
fi

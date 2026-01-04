#!/bin/bash
set -e

WORKSPACE_DIR="/home/node/clawd"
CONFIG_DIR="/home/node/.clawdbot"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Clone or pull workspace repo
if [ -n "$WORKSPACE_REPO" ]; then
  if [ -d "$WORKSPACE_DIR/.git" ]; then
    echo "Pulling latest workspace..."
    cd "$WORKSPACE_DIR"
    git pull --ff-only || true
  else
    echo "Cloning workspace repo..."
    git clone "$WORKSPACE_REPO" "$WORKSPACE_DIR"
  fi
  
  # Configure git for commits
  cd "$WORKSPACE_DIR"
  git config user.email "jarvis@clawd.bot"
  git config user.name "Jarvis"
fi

# Start the gateway
exec node dist/index.js gateway --bind lan --port ${PORT:-18789}

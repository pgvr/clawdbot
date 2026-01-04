#!/bin/bash
set -e

WORKSPACE_DIR="${HOME}/clawd"
CONFIG_DIR="${HOME}/.clawdbot"

echo "=== Railway Startup ==="
echo "PORT: ${PORT:-not set}"
echo "WORKSPACE_REPO: ${WORKSPACE_REPO:-not set}"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

# Create minimal config if none exists
if [ ! -f "$CONFIG_DIR/clawdbot.json" ]; then
  echo "Creating minimal config..."
  echo '{}' > "$CONFIG_DIR/clawdbot.json"
fi

# Clone or pull workspace repo
if [ -n "$WORKSPACE_REPO" ]; then
  if [ -d "$WORKSPACE_DIR/.git" ]; then
    echo "Pulling latest workspace..."
    cd "$WORKSPACE_DIR"
    git pull --ff-only || true
  elif [ -d "$WORKSPACE_DIR" ] && [ "$(ls -A $WORKSPACE_DIR 2>/dev/null)" ]; then
    echo "Workspace dir exists but isn't a git repo - reinitializing..."
    cd "$WORKSPACE_DIR"
    git init
    git remote add origin "$WORKSPACE_REPO"
    git fetch origin
    git reset --hard origin/main || git reset --hard origin/master
  else
    echo "Cloning workspace repo..."
    rm -rf "$WORKSPACE_DIR" 2>/dev/null || true
    git clone "$WORKSPACE_REPO" "$WORKSPACE_DIR"
  fi
  
  # Configure git for commits
  cd "$WORKSPACE_DIR"
  git config user.email "jarvis@clawd.bot"
  git config user.name "Jarvis"
else
  # Create empty workspace if no repo
  mkdir -p "$WORKSPACE_DIR"
fi

cd /app

# Start the gateway - use Railway's PORT
echo "Starting gateway on port ${PORT:-18789}..."
exec node dist/index.js gateway --bind auto --port ${PORT:-18789} --allow-unconfigured

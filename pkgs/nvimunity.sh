#!/bin/bash

CONFIG_DIR="$HOME/.config/nvim-unity"
CONFIG_FILE="$CONFIG_DIR/config.json"
NVIM_PATH="nvim"
SOCKET="$HOME/.cache/nvimunity.sock"
mkdir -p "$CONFIG_DIR"

# Create config.json if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  echo '{"last_project": ""}' > "$CONFIG_FILE"
fi

# Read last_project
LAST_PROJECT=$(jq -r '.last_project' "$CONFIG_FILE")

# Arguments
FILE="$1"
LINE="${2:-1}"

if ! [[ "$LINE" =~ ^[1-9][0-9]*$ ]]; then
  LINE="1"
fi

# Detect Shift key (optional, requires xdotool)
SHIFT_PRESSED=false
if command -v xdotool >/dev/null; then
  xdotool keydown Shift_L keyup Shift_L >/dev/null 2>&1 && SHIFT_PRESSED=true
fi

# Launch Neovim with quoted paths
if [ "$SHIFT_PRESSED" = true ] && [ -n "$LAST_PROJECT" ]; then
  exec "$NVIM_PATH" --listen "$SOCKET" "+$LINE" "+cd \"$LAST_PROJECT\"" "$FILE"
else
  exec "$NVIM_PATH" --listen "$SOCKET" "+$LINE" "$FILE"
fi

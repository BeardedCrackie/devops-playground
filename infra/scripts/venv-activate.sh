#!/bin/bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$SCRIPT_DIR/.."

# Check if venv exists, if not, create it
if [ ! -d "$INFRA_DIR/venv" ]; then
  echo "Python virtual environment not found. Running setup..."
  bash "$SCRIPT_DIR/venv-setup.sh"
fi

. "$INFRA_DIR/venv/bin/activate"

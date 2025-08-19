#!/bin/bash

# Convenience script to run the Python example from the project root
# This script simply delegates to the comprehensive setup script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_EXAMPLE_DIR="$SCRIPT_DIR/examples/python"

echo "🐍 Controller Python Example Launcher"
echo "======================================"
echo ""
echo "This script will run the comprehensive Python example setup."
echo "It will handle all dependencies, building, and execution."
echo ""

# Check if the python example directory exists
if [[ ! -d "$PYTHON_EXAMPLE_DIR" ]]; then
    echo "❌ Python example directory not found: $PYTHON_EXAMPLE_DIR"
    exit 1
fi

# Change to the python example directory and run the setup script
cd "$PYTHON_EXAMPLE_DIR"

if [[ -x "./setup_and_run.sh" ]]; then
    echo "🚀 Running Python example setup and execution..."
    echo ""
    exec ./setup_and_run.sh "$@"
else
    echo "❌ Setup script not found or not executable: ./setup_and_run.sh"
    exit 1
fi

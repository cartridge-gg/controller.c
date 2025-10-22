#!/bin/bash

# Python Test Runner for Controller UniFFI Bindings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🐍 Running Python Controller Tests"
echo "=================================="

# Check if library exists
if [ ! -f "$PROJECT_ROOT/target/release/libcontroller_uniffi.dylib" ]; then
    echo "❌ Library not found. Building..."
    cd "$PROJECT_ROOT"
    cargo build --release
fi

# Check if bindings exist
if [ ! -f "$PROJECT_ROOT/bindings/python/controller_uniffi.py" ]; then
    echo "❌ Python bindings not found. Generating..."
    cd "$PROJECT_ROOT"
    ./scripts/build_python.sh
fi

# Run the test
cd "$SCRIPT_DIR"
python3 controller.py

echo ""
echo "✅ Python tests completed!"

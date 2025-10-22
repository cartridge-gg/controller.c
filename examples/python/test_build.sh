#!/bin/bash

# Simple test script to debug the build process

set -e

echo "🔧 Testing Controller Python Build"
echo "=================================="

# Check if library exists
echo "📁 Checking for Rust library..."
if [[ -f "target/release/libcontroller_uniffi.dylib" ]]; then
    echo "✅ Found libcontroller_uniffi.dylib"
    ls -la target/release/libcontroller_uniffi.dylib
else
    echo "❌ libcontroller_uniffi.dylib not found, building..."
    cargo build --release
fi

# Check bindings
echo "📁 Checking Python bindings..."
if [[ -d "bindings/python" ]]; then
    echo "✅ Found Python bindings directory"
    ls bindings/python/
else
    echo "❌ Python bindings not found. Run: ./scripts/build_python.sh"
    exit 1
fi

# Test import
echo "🔧 Testing Python import..."
cd "$PROJECT_ROOT"

python3 -c "
import sys
from pathlib import Path
sys.path.insert(0, str(Path('bindings/python')))
import controller_uniffi
print('✅ controller_uniffi imported successfully!')
"

echo "🎉 Build test completed!"

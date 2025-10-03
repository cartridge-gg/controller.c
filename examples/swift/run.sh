#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Building Swift bindings..."
cd "$PROJECT_ROOT"
./scripts/build.sh swift

echo ""
echo "Running Swift example..."
cd "$SCRIPT_DIR"

# Compile the example
swiftc main.swift \
    -I "$PROJECT_ROOT/bindings/swift/ControllerSDK/.build/debug" \
    -L "$PROJECT_ROOT/target/release" \
    -lcontroller_c \
    -module-link-name ControllerSDK \
    -import-objc-header "$PROJECT_ROOT/bindings/swift/ControllerSDK/Sources/CControllerBridge/include/CControllerBridge.h" \
    -o swift_example

# Set library path and run
export DYLD_LIBRARY_PATH="$PROJECT_ROOT/target/release:$DYLD_LIBRARY_PATH"
./swift_example

# Clean up
rm -f swift_example
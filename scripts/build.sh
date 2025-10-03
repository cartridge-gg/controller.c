#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Check if target is Swift
if [ "$1" = "swift" ]; then
    # For Swift, we need to generate C bindings first
    echo "Generating C bindings for Swift..."
    cargo run --bin generator -- c

    # Build the bridge crate as a dynamic library
    echo "Building controller-c library..."
    cargo build --release --package controller-c

    # Copy C headers to Swift package
    echo "Copying C headers to Swift package..."
    cp bindings/c/*.h bindings/swift/ControllerSDK/Sources/CControllerBridge/include/
    cp bindings/c/*.d.h bindings/swift/ControllerSDK/Sources/CControllerBridge/include/

    # Build Swift package
    echo "Building Swift package..."
    cd bindings/swift/ControllerSDK
    swift build

    echo "Swift bindings complete!"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Library: target/release/libcontroller_c.dylib"
    else
        echo "Library: target/release/libcontroller_c.so"
    fi
    echo "Swift Package: bindings/swift/ControllerSDK"
else
    # First run the generator to create bindings
    echo "Generating bindings..."
    cargo run --bin generator -- "$1"

    # Build the bridge crate as a dynamic library
    echo "Building controller-c library..."
    cargo build --release --package controller-c

    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Build complete! Library available at target/release/libcontroller_c.dylib"
    else
        echo "Build complete! Library available at target/release/libcontroller_c.so"
    fi
fi
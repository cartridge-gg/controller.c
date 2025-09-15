#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# First run the generator to create bindings
echo "Generating bindings..."
cargo run --bin generator -- "$1"

# Build the bridge crate as a dynamic library
echo "Building controller-c library..."
cargo build --release --package controller-c

echo "Build complete! Library available at target/release/libcontroller_c.dylib"
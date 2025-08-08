#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"
cargo run --bin generator

cp "$PROJECT_ROOT/target/release/libcontroller_c.dylib" "$PROJECT_ROOT/examples/test_controller.dylib"
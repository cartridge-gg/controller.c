#!/bin/bash
set -e

echo "Building Swift bindings for controller-uniffi..."

# Build the Rust library
cargo build --release

# Generate Swift bindings (both .swift and .h files by default)
cargo run --release --bin uniffi-bindgen-swift

echo "Swift bindings generated in bindings/swift/"




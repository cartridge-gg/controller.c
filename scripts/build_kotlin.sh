#!/bin/bash
set -e

echo "Building Kotlin bindings for controller-uniffi..."

# Build the Rust library
cargo build --release

# Generate Kotlin bindings
cargo run --release --bin uniffi-bindgen-kotlin

echo "Kotlin bindings generated in bindings/kotlin/"


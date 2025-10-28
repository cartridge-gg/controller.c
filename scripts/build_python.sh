#!/bin/bash
set -e

echo "Building Python bindings for controller-uniffi..."

# Build the Rust library
cargo build --release

# Generate Python bindings
cargo run --release --bin uniffi-bindgen-python

# Copy the dynamic library
cp target/release/libcontroller_uniffi.dylib bindings/python/ || \
cp target/release/libcontroller_uniffi.so bindings/python/ || \
cp target/release/controller_uniffi.dll bindings/python/ || true

echo "Python bindings generated in bindings/python/"




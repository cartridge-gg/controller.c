#!/bin/bash

set -e

echo "🔨 Building Controller C++ Test..."
echo ""

# Build the library first
cd ../..
echo "📦 Building controller-uniffi library..."
cargo build --release -p controller-uniffi
echo "✓ Library built"
echo ""

# Go to examples/cpp
cd examples/cpp

# Create build directory
mkdir -p build
cd build

# Configure and build
echo "⚙️  Configuring CMake..."
cmake ..
echo ""

echo "🔧 Compiling C++ test..."
cmake --build .
echo "✓ Compiled successfully"
echo ""

# Run the test
echo "🚀 Running C++ Controller Test..."
echo ""
./controller_test



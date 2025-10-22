#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo "🧪 Running Swift Controller Tests"
echo "=================================="

# Check if library exists
if [ ! -f "target/release/libcontroller_uniffi.dylib" ]; then
    echo "❌ Library not found. Building..."
    cargo build --release -p controller-uniffi
fi

# Check if Swift bindings exist
if [ ! -f "bindings/swift/controller_uniffi.swift" ]; then
    echo "❌ Swift bindings not found. Generating..."
    cargo run --bin uniffi-bindgen-swift --release -- --swift-sources --headers --modulemap
fi

if [ ! -f "bindings/swift/controller_uniffiFFI.h" ]; then
    echo "❌ Swift binding headers not found. Regenerating..."
    cargo run --bin uniffi-bindgen-swift --release -- --swift-sources --headers --modulemap
fi

# Create a temporary directory for compilation
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Copy all necessary files
cp "bindings/swift/controller_uniffi.swift" "$TEMP_DIR/"
cp "bindings/swift/controller_uniffiFFI.h" "$TEMP_DIR/"
cp "bindings/swift/controller_uniffi.modulemap" "$TEMP_DIR/module.modulemap"
cp "examples/swift/controller.swift" "$TEMP_DIR/"

# Create a combined Swift file
cat > "$TEMP_DIR/main.swift" << 'EOF'
// Combined Swift bindings and test
EOF

cat "bindings/swift/controller_uniffi.swift" >> "$TEMP_DIR/main.swift"

cat >> "$TEMP_DIR/main.swift" << 'EOF'

// Test code below
EOF

# Add the test code (skip the first 6 lines which are comments and import)
tail -n +7 "examples/swift/controller.swift" >> "$TEMP_DIR/main.swift"

echo "📦 Compiling Swift test..."

# Compile with proper module import and bridging header
cd "$TEMP_DIR"
swiftc -o controller \
    -import-objc-header controller_uniffiFFI.h \
    -I . \
    -L "$PROJECT_ROOT/target/release" \
    -lcontroller_uniffi \
    -Xlinker -rpath -Xlinker "$PROJECT_ROOT/target/release" \
    main.swift

echo "🚀 Running tests..."

# Run the compiled program
DYLD_LIBRARY_PATH="$PROJECT_ROOT/target/release" \
    ./controller

echo ""
echo "✅ Swift tests completed!"

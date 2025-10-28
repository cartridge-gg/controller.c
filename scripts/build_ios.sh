#!/bin/bash
# Build script for iOS XCFramework and Swift bindings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Building iOS XCFramework ===${NC}"
echo ""

# Step 1: Build for iOS device (arm64)
echo -e "${YELLOW}Step 1/5:${NC} Building for iOS device (aarch64-apple-ios)..."
cd "$PROJECT_ROOT"
cargo build --release --target aarch64-apple-ios
echo -e "${GREEN}✓ iOS device build complete${NC}"
echo ""

# Step 2: Build for iOS simulator (arm64)
echo -e "${YELLOW}Step 2/5:${NC} Building for iOS simulator (aarch64-apple-ios-sim)..."
cargo build --release --target aarch64-apple-ios-sim
echo -e "${GREEN}✓ iOS simulator build complete${NC}"
echo ""

# Step 3: Generate Swift bindings
echo -e "${YELLOW}Step 3/5:${NC} Generating Swift bindings..."
./scripts/build_swift.sh
echo -e "${GREEN}✓ Swift bindings generated${NC}"
echo ""

# Step 4: Create XCFramework
echo -e "${YELLOW}Step 4/5:${NC} Creating XCFramework..."
rm -rf target/controller_uniffi.xcframework
xcodebuild -create-xcframework \
  -library target/aarch64-apple-ios/release/libcontroller_uniffi.a \
  -library target/aarch64-apple-ios-sim/release/libcontroller_uniffi.a \
  -output target/controller_uniffi.xcframework
echo -e "${GREEN}✓ XCFramework created${NC}"
echo ""

# Step 5: Copy Swift bindings to Xcode project
echo -e "${YELLOW}Step 5/5:${NC} Copying Swift bindings to Xcode project..."
XCODE_PROJECT="$PROJECT_ROOT/examples/ios-app/SessionAccountApp/controller/controller"
if [ -d "$XCODE_PROJECT" ]; then
    cp "$PROJECT_ROOT/bindings/swift/controller_uniffi.swift" "$XCODE_PROJECT/controller_uniffi.swift"
    cp "$PROJECT_ROOT/bindings/swift/controller_uniffiFFI.h" "$XCODE_PROJECT/controller_uniffiFFI.h"
    echo -e "${GREEN}✓ Swift bindings copied to Xcode project${NC}"
else
    echo -e "${YELLOW}⚠ Xcode project not found at expected location${NC}"
fi
echo ""

echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  • XCFramework: target/controller_uniffi.xcframework"
echo "  • iOS device:  target/aarch64-apple-ios/release/libcontroller_uniffi.a"
echo "  • iOS sim:     target/aarch64-apple-ios-sim/release/libcontroller_uniffi.a"
echo "  • Bindings:    bindings/swift/"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Open Xcode"
echo "  2. Clean build folder (Cmd+Shift+K)"
echo "  3. Build and run (Cmd+R)"
echo ""


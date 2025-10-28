#!/bin/bash
# Run script for SessionAccount Swift example

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../.."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Building SessionAccount Swift Example ===${NC}"
echo ""

# Generate Swift bindings if they don't exist
if [ ! -f "$PROJECT_ROOT/bindings/swift/controller_uniffiFFI.h" ]; then
    echo "Step 1: Generating Swift bindings..."
    cd "$PROJECT_ROOT"
    ./scripts/build_swift.sh
    echo -e "${GREEN}✓ Swift bindings generated${NC}"
    echo ""
fi

# Build the controller library first
echo "Step 2: Building controller library..."
cd "$PROJECT_ROOT"
cargo build --release
echo -e "${GREEN}✓ Library built${NC}"
echo ""

# Build Swift example
echo "Step 3: Compiling Swift example..."
cd "$SCRIPT_DIR"

swiftc \
    -import-objc-header ../../bindings/swift/controller_uniffiFFI.h \
    -L ../../target/release \
    -lcontroller_uniffi \
    -Xlinker -rpath -Xlinker ../../target/release \
    ../../bindings/swift/controller_uniffi.swift \
    session_account.swift \
    -o session_account_example

echo -e "${GREEN}✓ Compilation successful${NC}"
echo ""

# Run the example
echo "Step 3: Running example..."
echo -e "${YELLOW}Note: You will need to open a browser and create a session${NC}"
echo ""

./session_account_example

# Cleanup
rm -f session_account_example

echo ""
echo -e "${GREEN}=== Done ===${NC}"


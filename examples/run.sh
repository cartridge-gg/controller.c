#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building C example...${NC}"

# Ensure the Rust library is built first
echo "Building Rust library..."
cd "$PROJECT_ROOT"
./scripts/build.sh c

# Build the bridge crate as a dynamic library
echo "Building controller-c library..."
cargo build --release --package controller-c

# Compile the C example
echo -e "\n${YELLOW}Compiling test_session_account.c...${NC}"

# For macOS (adjust for Linux if needed)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    gcc -o "$SCRIPT_DIR/test_controller" \
        "$SCRIPT_DIR/test_session_account.c" \
        -L"$PROJECT_ROOT/target/release" \
        -lcontroller_c \
        -framework CoreFoundation \
        -framework Security \
        -lpthread
else
    # Linux
    gcc -o "$SCRIPT_DIR/test_controller" \
        "$SCRIPT_DIR/test_session_account.c" \
        -L"$PROJECT_ROOT/target/release" \
        -lcontroller_c \
        -lpthread \
        -ldl
fi

echo -e "${GREEN}✅ Build successful!${NC}"
echo -e "Run with: ${YELLOW}./examples/test_controller${NC}"

# Note about library path
echo -e "\n${YELLOW}Note:${NC} If you get a 'library not found' error when running, set:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "export DYLD_LIBRARY_PATH=$PROJECT_ROOT/target/release:\$DYLD_LIBRARY_PATH"
else
    echo "export LD_LIBRARY_PATH=$PROJECT_ROOT/target/release:\$LD_LIBRARY_PATH"
fi

"$PROJECT_ROOT"/examples/test_controller
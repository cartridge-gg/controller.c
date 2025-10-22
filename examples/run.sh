#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TEST_SCRIPT="$1"
if [[ -z "$TEST_SCRIPT" ]]; then
    TEST_SCRIPT="$TEST_SCRIPT"
fi

echo -e "${YELLOW}Building C example ${TEST_SCRIPT}...${NC}"

# Build the bridge crate as a dynamic library
echo "Building controller-uniffi library..."
cd "$PROJECT_ROOT"
cargo build --release

# Compile the C example
echo -e "\n${YELLOW}Compiling ${TEST_SCRIPT}.c...${NC}"

# For macOS (adjust for Linux if needed)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    gcc -o "$SCRIPT_DIR/$TEST_SCRIPT" \
        "$SCRIPT_DIR/$TEST_SCRIPT.c" \
        -L"$PROJECT_ROOT/target/release" \
        -lcontroller_uniffi \
        -framework CoreFoundation \
        -framework Security \
        -lpthread
else
    # Linux
    gcc -o "$SCRIPT_DIR/$TEST_SCRIPT" \
        "$SCRIPT_DIR/$TEST_SCRIPT.c" \
        -L"$PROJECT_ROOT/target/release" \
        -lcontroller_uniffi \
        -lpthread \
        -ldl
fi

echo -e "${GREEN}✅ Build successful!${NC}"
echo -e "Run with: ${YELLOW}./examples/${TEST_SCRIPT}${NC}"

# Note about library path
echo -e "\n${YELLOW}Note:${NC} If you get a 'library not found' error when running, set:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "export DYLD_LIBRARY_PATH=$PROJECT_ROOT/target/release:\$DYLD_LIBRARY_PATH"
else
    echo "export LD_LIBRARY_PATH=$PROJECT_ROOT/target/release:\$LD_LIBRARY_PATH"
fi

"$PROJECT_ROOT"/examples/"$TEST_SCRIPT"

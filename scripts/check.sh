#!/bin/bash
# Run all CI checks locally

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Running All CI Checks ===${NC}"
echo ""

cd "$PROJECT_ROOT"

# Track if any check fails
FAILED=0

# 1. Format check
echo -e "${YELLOW}Step 1/4:${NC} Checking formatting..."
if ./scripts/fmt.sh --check; then
    echo ""
else
    FAILED=1
    echo ""
fi

# 2. Clippy
echo -e "${YELLOW}Step 2/4:${NC} Running clippy..."
if ./scripts/clippy.sh; then
    echo ""
else
    FAILED=1
    echo ""
fi

# 3. Tests
echo -e "${YELLOW}Step 3/4:${NC} Running tests..."
if cargo test --all --verbose; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    echo ""
else
    echo -e "${RED}✗ Tests failed${NC}"
    FAILED=1
    echo ""
fi

# 4. Build
echo -e "${YELLOW}Step 4/4:${NC} Building release..."
if cargo build --release; then
    echo -e "${GREEN}✓ Build successful${NC}"
    echo ""
else
    echo -e "${RED}✗ Build failed${NC}"
    FAILED=1
    echo ""
fi

# Summary
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo -e "${BLUE}Ready to commit and push${NC}"
    exit 0
else
    echo -e "${RED}❌ Some checks failed${NC}"
    echo -e "${BLUE}Fix the issues above before committing${NC}"
    exit 1
fi


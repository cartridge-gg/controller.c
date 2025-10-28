#!/bin/bash
# Run clippy linter

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Running clippy ===${NC}"
echo ""

cd "$PROJECT_ROOT"

# Check if we should fix issues automatically
if [ "$1" = "--fix" ]; then
    echo "Running clippy with automatic fixes..."
    cargo clippy --all-targets --all-features --fix --allow-dirty --allow-staged
    echo -e "${GREEN}✓ Clippy fixes applied${NC}"
    echo -e "${YELLOW}Note: Review changes before committing${NC}"
else
    echo "Checking for clippy warnings..."
    if cargo clippy --all-targets --all-features -- -D warnings; then
        echo -e "${GREEN}✓ No clippy warnings found${NC}"
    else
        echo -e "${RED}✗ Clippy warnings found${NC}"
        echo -e "${BLUE}Run './scripts/clippy.sh --fix' to auto-fix some issues${NC}"
        exit 1
    fi
fi


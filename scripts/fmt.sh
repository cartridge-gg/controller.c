#!/bin/bash
# Format Rust code with rustfmt

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Running rustfmt ===${NC}"
echo ""

cd "$PROJECT_ROOT"

# Check if we should just check or actually format
if [ "$1" = "--check" ]; then
    echo "Checking formatting..."
    if cargo fmt --all -- --check; then
        echo -e "${GREEN}✓ Code is properly formatted${NC}"
    else
        echo -e "${RED}✗ Code formatting issues found${NC}"
        echo -e "${BLUE}Run './scripts/fmt.sh' to fix${NC}"
        exit 1
    fi
else
    echo "Formatting code..."
    cargo fmt --all
    echo -e "${GREEN}✓ Code formatted successfully${NC}"
fi

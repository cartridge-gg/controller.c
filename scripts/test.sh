#!/bin/bash
# Run tests with optional coverage

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Running Tests ===${NC}"
echo ""

cd "$PROJECT_ROOT"

# Check for flags
VERBOSE=""
NOCAPTURE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        --nocapture)
            NOCAPTURE="-- --nocapture"
            shift
            ;;
        *)
            echo -e "${YELLOW}Unknown option: $1${NC}"
            shift
            ;;
    esac
done

# Run tests
if cargo test --all $VERBOSE $NOCAPTURE; then
    echo ""
    echo -e "${GREEN}✓ All tests passed${NC}"
else
    echo ""
    echo -e "${RED}✗ Tests failed${NC}"
    exit 1
fi

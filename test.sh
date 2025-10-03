#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}Controller SDK Test Suite${NC}"
echo "================================"

# Parse command line arguments
TEST_TARGET="${1:-all}"
VERBOSE="${2:-false}"

# Function to run tests for a specific target
run_tests() {
    local target=$1
    echo -e "\n${YELLOW}Testing $target bindings...${NC}"

    case $target in
        c)
            echo "Building C bindings..."
            ./scripts/build.sh c

            echo "Running C example tests..."
            ./examples/run.sh
            echo -e "${GREEN}✓ C tests passed${NC}"
            ;;

        python|py)
            echo "Building Python bindings..."
            ./scripts/build.sh py

            echo "Setting up Python environment..."
            cd examples/python
            if [ ! -d "venv" ]; then
                python3 -m venv venv
            fi
            source venv/bin/activate
            pip install -q -r requirements.txt

            echo "Running Python tests..."
            python test_controller.py
            deactivate
            cd ../..
            echo -e "${GREEN}✓ Python tests passed${NC}"
            ;;

        swift)
            echo "Building Swift bindings..."
            ./scripts/build.sh swift

            echo "Running Swift unit tests..."
            cd bindings/swift/ControllerSDK
            if [ "$VERBOSE" = "true" ]; then
                swift test --verbose
            else
                swift test
            fi
            cd ../../..

            echo "Running Swift integration tests..."
            export RUN_INTEGRATION_TESTS=true
            cd bindings/swift/ControllerSDK
            swift test --filter Integration
            unset RUN_INTEGRATION_TESTS
            cd ../../..

            echo -e "${GREEN}✓ Swift tests passed${NC}"
            ;;

        *)
            echo -e "${RED}Unknown target: $target${NC}"
            echo "Valid targets: c, python, py, swift, all"
            exit 1
            ;;
    esac
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()

    # Check for Rust
    if ! command -v cargo &> /dev/null; then
        missing_deps+=("Rust/Cargo")
    fi

    # Check for target-specific dependencies
    case $TEST_TARGET in
        python|py|all)
            if ! command -v python3 &> /dev/null; then
                missing_deps+=("Python 3")
            fi
            ;;
        swift|all)
            if ! command -v swift &> /dev/null; then
                missing_deps+=("Swift")
            fi
            ;;
    esac

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Missing dependencies:${NC}"
        printf '%s\n' "${missing_deps[@]}"
        exit 1
    fi
}

# Function to run linting
run_linting() {
    echo -e "\n${YELLOW}Running linters...${NC}"

    # Rust linting
    if command -v cargo &> /dev/null; then
        echo "Checking Rust formatting..."
        cargo fmt -- --check || echo -e "${YELLOW}Warning: Rust formatting issues found${NC}"

        echo "Running Clippy..."
        cargo clippy -- -D warnings || echo -e "${YELLOW}Warning: Clippy warnings found${NC}"
    fi

    # Swift linting (if swiftformat is installed)
    if command -v swiftformat &> /dev/null; then
        echo "Checking Swift formatting..."
        swiftformat --lint bindings/swift/ControllerSDK || echo -e "${YELLOW}Warning: Swift formatting issues found${NC}"
    fi

    echo -e "${GREEN}✓ Linting complete${NC}"
}

# Function to generate coverage report
generate_coverage() {
    echo -e "\n${YELLOW}Generating coverage report...${NC}"

    # Swift coverage
    if [ "$TEST_TARGET" = "swift" ] || [ "$TEST_TARGET" = "all" ]; then
        echo "Generating Swift coverage..."
        cd bindings/swift/ControllerSDK
        swift test --enable-code-coverage
        cd ../../..
    fi

    echo -e "${GREEN}✓ Coverage report generated${NC}"
}

# Main execution
cd "$PROJECT_ROOT"

# Check dependencies
check_dependencies

# Run tests based on target
if [ "$TEST_TARGET" = "all" ]; then
    run_tests c
    run_tests python
    run_tests swift
    run_linting
else
    run_tests "$TEST_TARGET"
fi

# Generate coverage if requested
if [ "$3" = "--coverage" ]; then
    generate_coverage
fi

echo -e "\n${GREEN}All tests completed successfully!${NC}"
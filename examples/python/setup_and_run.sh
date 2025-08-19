#!/bin/bash

# Controller Python Example - Complete Setup and Run Script
# This script handles everything needed to build, setup, and run the Python example

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "\n${BLUE}🔧 $1${NC}"
    echo "$(printf '=%.0s' {1..50})"
}

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PYTHON_DIR="$SCRIPT_DIR"
BINDINGS_DIR="$PROJECT_ROOT/bindings/py"

log_info "Controller Python Example Setup"
log_info "Script directory: $SCRIPT_DIR"
log_info "Project root: $PROJECT_ROOT"
log_info "Python example directory: $PYTHON_DIR"
log_info "Bindings directory: $BINDINGS_DIR"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Python version
check_python() {
    if ! command_exists python3; then
        log_error "Python 3 is required but not found"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    log_success "Found Python $PYTHON_VERSION"
    
    # Check if version is 3.8+
    if python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)"; then
        log_success "Python version is compatible"
    else
        log_error "Python 3.8 or higher is required"
        exit 1
    fi
}

# Function to check Rust and Cargo
check_rust() {
    if ! command_exists cargo; then
        log_error "Rust and Cargo are required but not found"
        log_info "Install Rust from: https://rustup.rs/"
        exit 1
    fi
    
    RUST_VERSION=$(cargo --version)
    log_success "Found $RUST_VERSION"
}

# Function to setup virtual environment and install Python dependencies
install_python_deps() {
    log_step "Setting up Virtual Environment and Installing Dependencies"
    
    cd "$PYTHON_DIR"
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "venv" ]]; then
        log_info "Creating virtual environment..."
        python3 -m venv venv
        log_success "Virtual environment created"
    else
        log_info "Virtual environment already exists"
    fi
    
    # Activate virtual environment
    log_info "Activating virtual environment..."
    source venv/bin/activate
    
    # Upgrade pip in the venv
    log_info "Upgrading pip..."
    pip install --upgrade pip
    
    # Install requirements
    log_info "Installing Python packages in virtual environment..."
    pip install -r requirements.txt
    
    log_success "Python dependencies installed in virtual environment"
}

# Function to build the Rust library and generate bindings
build_library() {
    log_step "Building Rust Library and Generating Bindings"
    
    cd "$PROJECT_ROOT"
    
    # Run the build script
    log_info "Running build script..."
    if [[ -x "scripts/build.sh" ]]; then
        ./scripts/build.sh
    else
        log_error "Build script not found or not executable"
        exit 1
    fi
    
    # Check if the library was created
    DYLIB_PATH="$PROJECT_ROOT/target/release/libcontroller_c.dylib"
    if [[ -f "$DYLIB_PATH" ]]; then
        log_success "Library built successfully: $DYLIB_PATH"
    else
        log_error "Library not found after build: $DYLIB_PATH"
        exit 1
    fi
    
    # Check if bindings were generated
    if [[ -d "$BINDINGS_DIR" && -f "$BINDINGS_DIR/controller_c_ext.cpp" ]]; then
        log_success "Python bindings generated successfully"
    else
        log_error "Python bindings not found: $BINDINGS_DIR"
        exit 1
    fi
}

# Function to build the Python extension
build_python_extension() {
    log_step "Building Python Extension"
    
    cd "$BINDINGS_DIR"
    
    # Activate virtual environment
    log_info "Activating virtual environment for building..."
    source "$PYTHON_DIR/venv/bin/activate"
    
    # Create setup.py if it doesn't exist
    if [[ ! -f "setup.py" ]]; then
        log_info "Creating setup.py..."
        cat > setup.py << 'EOF'
import nanobind
from pathlib import Path
from setuptools import setup, Extension
from pybind11.setup_helpers import build_ext
import sys
import os

# Add the target/release directory to library path for linking
project_root = Path(__file__).parent.parent.parent
lib_dir = project_root / "target" / "release"

ext_modules = [
    Extension(
        "controller_c",
        [
            "controller_c_ext.cpp",
        ] + [str(p) for p in Path("sub_modules").glob("*.cpp")],
        include_dirs=[
            "include",
            nanobind.include_dir(),
        ],
        libraries=["controller_c"],
        library_dirs=[str(lib_dir)],
        language="c++",
        extra_compile_args=["-std=c++17"],
        extra_link_args=[],
    ),
]

if __name__ == "__main__":
    setup(
        name="controller_c",
        ext_modules=ext_modules,
        cmdclass={"build_ext": build_ext},
        zip_safe=False,
        python_requires=">=3.8",
    )
EOF
    fi
    
    # Build the extension
    log_info "Building nanobind extension..."
    python3 setup.py build_ext --inplace
    
    # Check if the extension was built
    if ls controller_c*.so >/dev/null 2>&1 || ls controller_c*.pyd >/dev/null 2>&1; then
        log_success "Python extension built successfully"
    else
        log_error "Python extension build failed"
        exit 1
    fi
}

# Function to test the installation
test_installation() {
    log_step "Testing Installation"
    
    cd "$BINDINGS_DIR"
    
    # Activate virtual environment
    log_info "Activating virtual environment for testing..."
    source "$PYTHON_DIR/venv/bin/activate"
    
    # Test basic import
    log_info "Testing basic import..."
    if python3 -c "
import sys
sys.path.insert(0, '.')
import controller_c
print('✅ controller_c imported successfully')

# Test enums
version = controller_c.Version.LATEST
print(f'✅ Version enum: {version}')

signer_type = controller_c.SignerType.Starknet  
print(f'✅ SignerType enum: {signer_type}')

print('✅ All basic tests passed')
"; then
        log_success "Installation test passed"
    else
        log_error "Installation test failed"
        exit 1
    fi
}

# Function to run the example
run_example() {
    log_step "Running Python Example"
    
    cd "$PYTHON_DIR"
    
    # Activate virtual environment
    log_info "Activating virtual environment for running example..."
    source venv/bin/activate
    
    # Set up environment
    export PYTHONPATH="$BINDINGS_DIR:$PYTHONPATH"
    
    # Set library path based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        export DYLD_LIBRARY_PATH="$PROJECT_ROOT/target/release:$DYLD_LIBRARY_PATH"
    else
        export LD_LIBRARY_PATH="$PROJECT_ROOT/target/release:$LD_LIBRARY_PATH"
    fi
    
    log_info "Environment variables set:"
    log_info "PYTHONPATH: $PYTHONPATH"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "DYLD_LIBRARY_PATH: $DYLD_LIBRARY_PATH"
    else
        log_info "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
    fi
    
    # Run the example
    log_info "Running test_controller.py..."
    python3 test_controller.py
    
    log_success "Example completed!"
}

# Function to clean up build artifacts
clean() {
    log_step "Cleaning Build Artifacts"
    
    cd "$PROJECT_ROOT"
    
    # Clean Rust build
    log_info "Cleaning Rust build artifacts..."
    cargo clean
    
    # Clean Python build artifacts
    if [[ -d "$BINDINGS_DIR" ]]; then
        cd "$BINDINGS_DIR"
        log_info "Cleaning Python build artifacts..."
        rm -rf build/
        rm -rf *.egg-info/
        rm -f controller_c*.so
        rm -f controller_c*.pyd
        rm -f setup.py
    fi
    
    # Clean virtual environment
    if [[ -d "$PYTHON_DIR/venv" ]]; then
        log_info "Cleaning virtual environment..."
        rm -rf "$PYTHON_DIR/venv"
    fi
    
    log_success "Clean completed"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --clean        Clean build artifacts and exit"
    echo "  --no-run       Setup everything but don't run the example"
    echo "  --deps-only    Only install Python dependencies"
    echo "  --build-only   Only build the library and extension"
    echo "  --test-only    Only test the installation"
    echo ""
    echo "Default behavior: Complete setup and run the example"
}

# Parse command line arguments
CLEAN_ONLY=false
NO_RUN=false
DEPS_ONLY=false
BUILD_ONLY=false
TEST_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_usage
            exit 0
            ;;
        --clean)
            CLEAN_ONLY=true
            shift
            ;;
        --no-run)
            NO_RUN=true
            shift
            ;;
        --deps-only)
            DEPS_ONLY=true
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --test-only)
            TEST_ONLY=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    log_info "🐍 Controller Python Example - Complete Setup"
    log_info "=============================================="
    
    if [[ "$CLEAN_ONLY" == true ]]; then
        clean
        exit 0
    fi
    
    # Always check prerequisites
    check_python
    check_rust
    
    if [[ "$DEPS_ONLY" == true ]]; then
        install_python_deps
        exit 0
    fi
    
    if [[ "$BUILD_ONLY" == true ]]; then
        build_library
        build_python_extension
        exit 0
    fi
    
    if [[ "$TEST_ONLY" == true ]]; then
        test_installation
        exit 0
    fi
    
    # Full setup process
    install_python_deps
    build_library
    build_python_extension
    test_installation
    
    if [[ "$NO_RUN" != true ]]; then
        run_example
    fi
    
    log_success "🎉 Setup completed successfully!"
    
    if [[ "$NO_RUN" == true ]]; then
        echo ""
        log_info "To run the example manually:"
        log_info "cd examples/python"
        log_info "source venv/bin/activate"
        log_info "export PYTHONPATH=\"$BINDINGS_DIR:\$PYTHONPATH\""
        if [[ "$OSTYPE" == "darwin"* ]]; then
            log_info "export DYLD_LIBRARY_PATH=\"$PROJECT_ROOT/target/release:\$DYLD_LIBRARY_PATH\""
        else
            log_info "export LD_LIBRARY_PATH=\"$PROJECT_ROOT/target/release:\$LD_LIBRARY_PATH\""
        fi
        log_info "python3 test_controller.py"
    fi
}

# Error handling
trap 'log_error "Script failed at line $LINENO"' ERR

# Run main function
main "$@"

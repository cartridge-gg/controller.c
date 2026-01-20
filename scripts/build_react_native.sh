#!/bin/bash
#
# Build React Native bindings for controller.c
#
# This script handles the complete process of:
# 1. Building the Rust library
# 2. Generating React Native bindings via uniffi-bindgen-react-native
# 3. Building Android native libraries (optional)
# 4. Copying bindings to the example project
#
# Usage:
#   ./scripts/build_react_native.sh [OPTIONS]
#
# Options:
#   --skip-android    Skip building Android native libraries
#   --skip-bindings   Skip generating TypeScript/C++ bindings (just build libs)
#   --android-only    Only build Android libraries
#   --bindings-only   Only generate bindings (don't build Android)
#   --help            Show this help message
#
# Requirements:
#   - Rust toolchain
#   - uniffi-bindgen-react-native (see installation below)
#   - cargo-ndk (for Android builds)
#   - Android NDK (for Android builds)
#
# Installation:
#   cargo install --git https://github.com/Larkooo/uniffi-bindgen-react-native --branch update-uniffi-0.30 uniffi-bindgen-react-native
#   cargo install cargo-ndk
#   rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Paths
RN_MODULE_DIR="${PROJECT_ROOT}/examples/react-native/modules/controller"
BINDINGS_OUT_DIR="${PROJECT_ROOT}/bindings/react-native"

# Options
SKIP_ANDROID=false
SKIP_BINDINGS=false
ANDROID_ONLY=false
BINDINGS_ONLY=false

print_header() {
    echo -e "\n${BLUE}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${GREEN}▶${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✖${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

show_help() {
    cat << EOF
Build React Native bindings for controller.c

USAGE:
    ./scripts/build_react_native.sh [OPTIONS]

OPTIONS:
    --skip-android    Skip building Android native libraries
    --skip-bindings   Skip generating TypeScript/C++ bindings (just build libs)
    --android-only    Only build Android libraries
    --bindings-only   Only generate bindings (don't build Android)
    --help            Show this help message

REQUIREMENTS:
    - Rust toolchain (rustc, cargo)
    - uniffi-bindgen-react-native tool

    For Android builds:
    - cargo-ndk
    - Android NDK
    - Rust Android targets

INSTALLATION:

    1. Install uniffi-bindgen-react-native:
       cargo install --git https://github.com/Larkooo/uniffi-bindgen-react-native \\
           --branch update-uniffi-0.30 uniffi-bindgen-react-native

    2. For Android support, install cargo-ndk:
       cargo install cargo-ndk

    3. Add Android targets:
       rustup target add aarch64-linux-android armv7-linux-androideabi \\
           i686-linux-android x86_64-linux-android

    4. Set up Android NDK (via Android Studio SDK Manager):
       export ANDROID_NDK_HOME=\$HOME/Library/Android/sdk/ndk/<version>

EXAMPLES:

    # Full build (bindings + Android + copy to example)
    ./scripts/build_react_native.sh

    # Generate bindings only (no Android build)
    ./scripts/build_react_native.sh --bindings-only

    # Build Android libraries only
    ./scripts/build_react_native.sh --android-only

    # Skip Android (useful on CI or when NDK not available)
    ./scripts/build_react_native.sh --skip-android

WORKFLOW:

    After making Rust code changes:

    1. Generate new bindings:
       ./scripts/build_react_native.sh

    2. Rebuild native projects:
       cd examples/react-native
       pnpm exec expo prebuild --clean
       pnpm ios    # or pnpm android

OUTPUT:

    Bindings are generated in:
    - bindings/react-native/            (intermediate output)
    - examples/react-native/modules/controller/src/generated/
    - examples/react-native/modules/controller/cpp/generated/

    Android libraries are built to:
    - examples/react-native/modules/controller/android/src/main/jniLibs/

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-android)
            SKIP_ANDROID=true
            shift
            ;;
        --skip-bindings)
            SKIP_BINDINGS=true
            shift
            ;;
        --android-only)
            ANDROID_ONLY=true
            shift
            ;;
        --bindings-only)
            BINDINGS_ONLY=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Run with --help for usage information"
            exit 1
            ;;
    esac
done

# Validate options
if [[ "$ANDROID_ONLY" == true && "$BINDINGS_ONLY" == true ]]; then
    print_error "Cannot use --android-only and --bindings-only together"
    exit 1
fi

cd "${PROJECT_ROOT}"

print_header "React Native Bindings Generator"

# ============================================================================
# Step 1: Check prerequisites
# ============================================================================

print_step "Checking prerequisites..."

if ! command -v cargo &> /dev/null; then
    print_error "cargo not found. Please install Rust: https://rustup.rs"
    exit 1
fi
print_success "cargo found"

if [[ "$ANDROID_ONLY" != true ]]; then
    if ! command -v uniffi-bindgen-react-native &> /dev/null; then
        print_error "uniffi-bindgen-react-native not found"
        echo ""
        echo "Install it with:"
        echo "  cargo install --git https://github.com/Larkooo/uniffi-bindgen-react-native \\"
        echo "      --branch update-uniffi-0.30 uniffi-bindgen-react-native"
        echo ""
        exit 1
    fi
    print_success "uniffi-bindgen-react-native found"
fi

if [[ "$BINDINGS_ONLY" != true && "$SKIP_ANDROID" != true ]]; then
    if ! command -v cargo-ndk &> /dev/null; then
        print_warning "cargo-ndk not found - Android builds will be skipped"
        print_warning "Install with: cargo install cargo-ndk"
        SKIP_ANDROID=true
    else
        print_success "cargo-ndk found"
    fi
fi

# ============================================================================
# Step 2: Build the Rust library
# ============================================================================

if [[ "$ANDROID_ONLY" != true ]]; then
    print_header "Building Rust Library"
    
    print_step "Building release library..."
    cargo build --release -p controller-uniffi
    
    # Determine library extension
    if [[ "$OSTYPE" == "darwin"* ]]; then
        LIB_EXT="dylib"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        LIB_EXT="dll"
    else
        LIB_EXT="so"
    fi
    
    LIB_PATH="${PROJECT_ROOT}/target/release/libcontroller_uniffi.${LIB_EXT}"
    
    if [[ ! -f "$LIB_PATH" ]]; then
        print_error "Library not found: $LIB_PATH"
        exit 1
    fi
    print_success "Library built: $LIB_PATH"
fi

# ============================================================================
# Step 3: Generate React Native bindings
# ============================================================================

if [[ "$SKIP_BINDINGS" != true && "$ANDROID_ONLY" != true ]]; then
    print_header "Generating React Native Bindings"
    
    print_step "Creating output directories..."
    mkdir -p "${BINDINGS_OUT_DIR}/src"
    mkdir -p "${BINDINGS_OUT_DIR}/cpp"
    
    print_step "Running uniffi-bindgen-react-native..."
    # New CLI: uniffi-bindgen-react-native generate jsi bindings --library --ts-dir <DIR> --cpp-dir <DIR> <SOURCE>
    uniffi-bindgen-react-native generate jsi bindings \
        --library \
        --ts-dir "${BINDINGS_OUT_DIR}/src" \
        --cpp-dir "${BINDINGS_OUT_DIR}/cpp" \
        "${LIB_PATH}"
    
    print_success "Bindings generated in: ${BINDINGS_OUT_DIR}"
    
    # Copy bindings to example project
    print_step "Copying bindings to example project..."
    
    # TypeScript bindings
    if [[ -d "${BINDINGS_OUT_DIR}/src" ]]; then
        mkdir -p "${RN_MODULE_DIR}/src/generated"
        cp -r "${BINDINGS_OUT_DIR}/src/"* "${RN_MODULE_DIR}/src/generated/"
        print_success "TypeScript bindings copied to: ${RN_MODULE_DIR}/src/generated/"
    fi
    
    # C++ bindings
    if [[ -d "${BINDINGS_OUT_DIR}/cpp" ]]; then
        mkdir -p "${RN_MODULE_DIR}/cpp/generated"
        cp -r "${BINDINGS_OUT_DIR}/cpp/"* "${RN_MODULE_DIR}/cpp/generated/"
        print_success "C++ bindings copied to: ${RN_MODULE_DIR}/cpp/generated/"
    fi
fi

# ============================================================================
# Step 4: Build Android native libraries
# ============================================================================

if [[ "$SKIP_ANDROID" != true && "$BINDINGS_ONLY" != true ]]; then
    print_header "Building Android Native Libraries"
    
    # Check for NDK
    if [[ -z "$ANDROID_NDK_HOME" && -z "$NDK_HOME" ]]; then
        # Try to find NDK automatically
        if [[ -d "$HOME/Library/Android/sdk/ndk" ]]; then
            NDK_DIR=$(ls -d "$HOME/Library/Android/sdk/ndk/"* 2>/dev/null | head -n1)
            if [[ -n "$NDK_DIR" ]]; then
                export ANDROID_NDK_HOME="$NDK_DIR"
                print_success "Found Android NDK: $NDK_DIR"
            fi
        fi
    fi
    
    if [[ -z "$ANDROID_NDK_HOME" && -z "$NDK_HOME" ]]; then
        print_warning "Android NDK not found - skipping Android build"
        print_warning "Set ANDROID_NDK_HOME or install via Android Studio"
    else
        "${SCRIPT_DIR}/build_android.sh" "${RN_MODULE_DIR}/android/src/main/jniLibs"
        print_success "Android libraries built"
    fi
fi

# ============================================================================
# Summary
# ============================================================================

print_header "Build Complete!"

echo "Generated files:"
if [[ "$SKIP_BINDINGS" != true && "$ANDROID_ONLY" != true ]]; then
    echo "  • TypeScript: ${RN_MODULE_DIR}/src/generated/"
    echo "  • C++:        ${RN_MODULE_DIR}/cpp/generated/"
fi
if [[ "$SKIP_ANDROID" != true && "$BINDINGS_ONLY" != true ]]; then
    echo "  • Android:    ${RN_MODULE_DIR}/android/src/main/jniLibs/"
fi

echo ""
echo "Next steps:"
echo "  1. cd examples/react-native"
echo "  2. pnpm exec expo prebuild --clean"
echo "  3. pnpm ios    # or pnpm android"
echo ""

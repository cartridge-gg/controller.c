#!/bin/bash
set -e

echo "Building Android native libraries for controller-uniffi..."

# Check for required tools
if ! command -v cargo-ndk &> /dev/null; then
    echo "Error: cargo-ndk is not installed."
    echo "Install it with: cargo install cargo-ndk"
    exit 1
fi

if [ -z "$ANDROID_NDK_HOME" ] && [ -z "$NDK_HOME" ]; then
    echo "Warning: ANDROID_NDK_HOME or NDK_HOME is not set."
    echo "cargo-ndk will try to find the NDK automatically."
fi

# Add Android targets if not already installed
echo "Ensuring Android targets are installed..."
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android 2>/dev/null || true

# Output directory
OUTPUT_DIR="${1:-examples/react-native/modules/controller/android/src/main/jniLibs}"

echo "Building for Android targets..."
echo "Output directory: $OUTPUT_DIR"

# Build for all Android ABIs
# Set SONAME so the library can be found at runtime
RUSTFLAGS="-C link-arg=-Wl,-soname,libcontroller_uniffi.so" cargo ndk \
    -t arm64-v8a \
    -t armeabi-v7a \
    -t x86 \
    -t x86_64 \
    -o "$OUTPUT_DIR" \
    build --release -p controller-uniffi

echo ""
echo "✓ Android native libraries built successfully!"
echo ""
echo "Libraries are located at:"
echo "  $OUTPUT_DIR/arm64-v8a/libcontroller_uniffi.so"
echo "  $OUTPUT_DIR/armeabi-v7a/libcontroller_uniffi.so"
echo "  $OUTPUT_DIR/x86/libcontroller_uniffi.so"
echo "  $OUTPUT_DIR/x86_64/libcontroller_uniffi.so"

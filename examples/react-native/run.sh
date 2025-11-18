#!/bin/bash

set -e

echo "🚀 Controller.c React Native Example Setup"
echo "==========================================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Must run from examples/react-native directory"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed"
    echo "Please install Node.js >= 20 from https://nodejs.org/"
    exit 1
fi

echo "✓ Node.js version: $(node --version)"

# Check if XCFramework is built
XCFRAMEWORK_PATH="../../target/controller_uniffi.xcframework"
if [ ! -d "$XCFRAMEWORK_PATH" ]; then
    echo ""
    echo "⚠️  XCFramework not found at $XCFRAMEWORK_PATH"
    echo "Building XCFramework..."
    echo ""
    
    cd ../..
    ./scripts/build_ios.sh
    cd examples/react-native
    
    echo ""
    echo "✓ XCFramework built successfully"
fi

# Install pnpm dependencies
echo ""
echo "📦 Installing pnpm dependencies..."
pnpm install

# Prebuild if ios directory doesn't exist
if [ ! -d "ios" ]; then
    echo ""
    echo "📱 Running Expo prebuild to generate native projects..."
    npx expo prebuild
fi

# Install pods
echo ""
echo "📦 Installing CocoaPods dependencies..."
cd ios
pod install
cd ..

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the app:"
echo "  pnpm start         # Start Metro bundler"
echo "  pnpm run ios       # Run on iOS"
echo ""


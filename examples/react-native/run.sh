#!/bin/bash

# Controller.c React Native Example - Setup & Run Script
set -e

echo "🚀 Controller.c React Native Example Setup"
echo ""

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    echo "❌ pnpm is not installed. Please install it first:"
    echo "   npm install -g pnpm"
    exit 1
fi

# Install pnpm dependencies
echo "📦 Installing dependencies..."
pnpm install

# Prebuild if ios directory doesn't exist
if [ ! -d "ios" ]; then
    echo ""
    echo "📱 Running Expo prebuild to generate native projects..."
    pnpm exec expo prebuild
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the app:"
echo "  iOS:     pnpm run ios"
echo "  Android: pnpm run android"
echo "  Start:   pnpm start"
echo ""


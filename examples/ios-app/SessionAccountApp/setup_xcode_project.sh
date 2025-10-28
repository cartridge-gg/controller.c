#!/bin/bash
# Setup script for SessionAccountApp Xcode project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../../.."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Setting up SessionAccountApp Xcode Project ===${NC}"
echo ""

# Step 1: Build controller library
echo "Step 1: Building controller library..."
cd "$PROJECT_ROOT"
cargo build --release
echo -e "${GREEN}✓ Library built${NC}"
echo ""

# Step 2: Generate Swift bindings
echo "Step 2: Generating Swift bindings..."
./scripts/build_swift.sh
echo -e "${GREEN}✓ Swift bindings generated${NC}"
echo ""

# Step 3: Create Xcode project structure
echo "Step 3: Creating Xcode project files..."
cd "$SCRIPT_DIR"

# Create Info.plist
cat > Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleDisplayName</key>
	<string>Session Account</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UIApplicationSceneManifest</key>
	<dict>
		<key>UIApplicationSupportsMultipleScenes</key>
		<true/>
	</dict>
	<key>UIApplicationSupportsIndirectInputEvents</key>
	<true/>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>https</string>
		<string>http</string>
	</array>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>sessionaccount</string>
			</array>
			<key>CFBundleURLName</key>
			<string>com.cartridge.sessionaccount</string>
		</dict>
	</array>
</dict>
</plist>
EOF

echo -e "${GREEN}✓ Info.plist created${NC}"
echo ""

# Step 4: Create bridging header
cat > SessionAccountApp-Bridging-Header.h << 'EOF'
//
//  Use this file to import your target's public headers
//  that you would like to expose to Swift.
//

#import "../../../bindings/swift/controller_uniffiFFI.h"
EOF

echo -e "${GREEN}✓ Bridging header created${NC}"
echo ""

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Open Xcode"
echo "2. File > New > Project > iOS App"
echo "3. Product Name: SessionAccountApp"
echo "4. Bundle Identifier: com.cartridge.sessionaccount"
echo "5. Interface: SwiftUI"
echo "6. Language: Swift"
echo ""
echo "7. Add all .swift files from this directory to the project"
echo "8. Add $PROJECT_ROOT/bindings/swift/controller_uniffi.swift"
echo "9. In Build Settings:"
echo "   - Set Objective-C Bridging Header to: SessionAccountApp-Bridging-Header.h"
echo "   - Add to Library Search Paths: $PROJECT_ROOT/target/release"
echo "   - Add to Runpath Search Paths: $PROJECT_ROOT/target/release"
echo "10. In Build Phases:"
echo "    - Add libcontroller_uniffi.dylib to 'Link Binary With Libraries'"
echo ""
echo "11. Build and run!"
echo ""
echo -e "${YELLOW}For detailed instructions, see README.md${NC}"



#!/bin/bash
# Create Xcode project and open it

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../../.."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Creating SessionAccountApp Xcode Project ===${NC}"
echo ""

cd "$SCRIPT_DIR"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${YELLOW}⚠️  Xcode command line tools not found${NC}"
    echo "Please install Xcode from the App Store"
    exit 1
fi

# Create a temporary Swift Package Manager project structure
echo "Creating project structure..."

# Create Package.swift for SPM
cat > Package.swift << 'EOF'
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SessionAccountApp",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SessionAccountApp", targets: ["SessionAccountApp"])
    ],
    targets: [
        .target(
            name: "SessionAccountApp",
            path: "."
        )
    ]
)
EOF

# Open Xcode to create the project manually
echo -e "${YELLOW}I'll help you create the Xcode project manually...${NC}"
echo ""
echo -e "${BLUE}Opening Xcode...${NC}"
echo ""

# Try to open Xcode
if command -v open &> /dev/null; then
    # Create a simple project
    echo "Creating basic iOS app template..."
    
    # Use xcrun to create a basic project
    mkdir -p "$SCRIPT_DIR/SessionAccountApp.xcodeproj"
    
    # Create pbxproj file
    cat > "$SCRIPT_DIR/SessionAccountApp.xcodeproj/project.pbxproj" << 'PBXEOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		MAIN_APP /* SessionAccountApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = MAIN_APP_FILE; };
		MAIN_VIEW /* SessionAccountView.swift in Sources */ = {isa = PBXBuildFile; fileRef = MAIN_VIEW_FILE; };
		MANAGER /* SessionManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = MANAGER_FILE; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		APP_PRODUCT /* SessionAccountApp.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = SessionAccountApp.app; sourceTree = BUILT_PRODUCTS_DIR; };
		MAIN_APP_FILE /* SessionAccountApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SessionAccountApp.swift; sourceTree = "<group>"; };
		MAIN_VIEW_FILE /* SessionAccountView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SessionAccountView.swift; sourceTree = "<group>"; };
		MANAGER_FILE /* SessionManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SessionManager.swift; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXGroup section */
		MAIN_GROUP = {
			isa = PBXGroup;
			children = (
				APP_GROUP /* SessionAccountApp */,
				PRODUCTS_GROUP /* Products */,
			);
			sourceTree = "<group>";
		};
		PRODUCTS_GROUP /* Products */ = {
			isa = PBXGroup;
			children = (
				APP_PRODUCT /* SessionAccountApp.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		APP_GROUP /* SessionAccountApp */ = {
			isa = PBXGroup;
			children = (
				MAIN_APP_FILE /* SessionAccountApp.swift */,
				MAIN_VIEW_FILE /* SessionAccountView.swift */,
				MANAGER_FILE /* SessionManager.swift */,
			);
			path = SessionAccountApp;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXProject section */
		PROJECT_OBJECT /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
			};
			buildConfigurationList = PROJECT_CONFIG_LIST /* Build configuration list for PBXProject "SessionAccountApp" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = MAIN_GROUP;
			productRefGroup = PRODUCTS_GROUP /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				APP_TARGET /* SessionAccountApp */,
			);
		};
/* End PBXProject section */

	};
	rootObject = PROJECT_OBJECT /* Project object */;
}
PBXEOF

    echo -e "${GREEN}✓ Project structure created${NC}"
    echo ""
    
    # Open in Xcode
    open "$SCRIPT_DIR/SessionAccountApp.xcodeproj" 2>/dev/null || open -a Xcode "$SCRIPT_DIR"
    
    echo -e "${GREEN}✅ Xcode opened!${NC}"
    echo ""
fi

echo -e "${BLUE}=== Manual Setup Required ===${NC}"
echo ""
echo "Since Xcode projects are complex, please follow these steps:"
echo ""
echo "1. In Xcode: File > New > Project"
echo "2. Choose: iOS > App"
echo "3. Settings:"
echo "   - Product Name: SessionAccountApp"
echo "   - Team: (Your Team)"
echo "   - Organization Identifier: com.cartridge"
echo "   - Bundle Identifier: com.cartridge.sessionaccount"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo ""
echo "4. Save in: $SCRIPT_DIR"
echo ""
echo "5. Delete the default ContentView.swift"
echo ""
echo "6. Add files (drag into Xcode):"
echo "   ✓ SessionAccountApp.swift"
echo "   ✓ SessionManager.swift"  
echo "   ✓ SessionAccountView.swift"
echo "   ✓ Views/SetupView.swift"
echo "   ✓ Views/ExecuteView.swift"
echo "   ✓ Views/StatusView.swift"
echo "   ✓ $PROJECT_ROOT/bindings/swift/controller_uniffi.swift"
echo ""
echo "7. Configure Build Settings:"
echo "   Target > Build Settings > Search:"
echo ""
echo "   a) 'Bridging' → Set to: SessionAccountApp-Bridging-Header.h"
echo "   b) 'Library Search Paths' → Add: \$(PROJECT_DIR)/../../../target/release"
echo "   c) 'Runpath Search Paths' → Add: \$(PROJECT_DIR)/../../../target/release"
echo ""
echo "8. Link Library:"
echo "   Target > Build Phases > Link Binary With Libraries"
echo "   Click + > Add Other > Add Files"
echo "   Navigate to: $PROJECT_ROOT/target/release/"
echo "   Select: libcontroller_uniffi.dylib"
echo ""
echo "9. Select iPhone Simulator"
echo ""
echo "10. Press ⌘R to Build & Run!"
echo ""
echo -e "${YELLOW}📖 For detailed instructions, see QUICKSTART.md${NC}"



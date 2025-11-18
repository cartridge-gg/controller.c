#!/bin/bash
# Download and extract release artifacts

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if version and platform are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Error: Version and platform required${NC}"
    echo "Usage: $0 <version> <platform>"
    echo ""
    echo "Available platforms:"
    echo "  - macos-arm64"
    echo "  - macos-x86_64"
    echo "  - ios (XCFramework + Swift bindings)"
    echo "  - linux-x86_64"
    echo "  - linux-aarch64"
    echo "  - bindings (all language bindings)"
    echo ""
    echo "Example: $0 v1.0.0 ios"
    exit 1
fi

VERSION=$1
PLATFORM=$2
REPO="cartridge-gg/controller.c"  # Update with your repo

# Map platform to artifact name
case $PLATFORM in
    macos-arm64)
        ARTIFACT="controller_uniffi-macos-arm64.tar.gz"
        ;;
    macos-x86_64)
        ARTIFACT="controller_uniffi-macos-x86_64.tar.gz"
        ;;
    ios)
        ARTIFACT="controller_uniffi_ios.tar.gz"
        ;;
    linux-x86_64)
        ARTIFACT="controller_uniffi-linux-x86_64.tar.gz"
        ;;
    linux-aarch64)
        ARTIFACT="controller_uniffi-linux-aarch64.tar.gz"
        ;;
    bindings)
        ARTIFACT="controller_uniffi_bindings.tar.gz"
        ;;
    *)
        echo -e "${RED}Error: Unknown platform '$PLATFORM'${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}=== Downloading Release $VERSION for $PLATFORM ===${NC}"
echo ""

# Download URL
URL="https://github.com/$REPO/releases/download/$VERSION/$ARTIFACT"

echo "Downloading from: $URL"
echo ""

# Download
if ! curl -L -o "$ARTIFACT" "$URL"; then
    echo -e "${RED}✗ Download failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Downloaded $ARTIFACT${NC}"
echo ""

# Extract
echo "Extracting..."
tar xzf "$ARTIFACT"
echo -e "${GREEN}✓ Extracted${NC}"
echo ""

# Verify checksum if available
CHECKSUM_URL="https://github.com/$REPO/releases/download/$VERSION/CHECKSUMS.txt"
if curl -L -s -o CHECKSUMS.txt "$CHECKSUM_URL" 2>/dev/null; then
    EXPECTED_CHECKSUM=$(grep "$ARTIFACT" CHECKSUMS.txt | awk '{print $1}')
    ACTUAL_CHECKSUM=$(shasum -a 256 "$ARTIFACT" | awk '{print $1}')
    
    if [ "$EXPECTED_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
        echo -e "${GREEN}✓ Checksum verified${NC}"
    else
        echo -e "${YELLOW}⚠ Checksum mismatch${NC}"
    fi
    rm CHECKSUMS.txt
fi

echo ""
echo -e "${GREEN}✅ Release artifacts ready!${NC}"
echo ""
echo "Downloaded: $ARTIFACT"
echo "Extracted to: ${ARTIFACT%.tar.gz}"

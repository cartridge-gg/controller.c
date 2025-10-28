#!/bin/bash
# Prepare and create a release

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if version is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.0.0"
    exit 1
fi

VERSION=$1

# Validate version format
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format${NC}"
    echo "Version must be in format: v1.0.0"
    exit 1
fi

echo -e "${BLUE}=== Preparing Release $VERSION ===${NC}"
echo ""

cd "$PROJECT_ROOT"

# Step 1: Check if working directory is clean
echo -e "${YELLOW}Step 1/7:${NC} Checking git status..."
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}✗ Working directory is not clean${NC}"
    echo "Please commit or stash your changes first"
    exit 1
fi
echo -e "${GREEN}✓ Working directory is clean${NC}"
echo ""

# Step 2: Run all checks
echo -e "${YELLOW}Step 2/7:${NC} Running CI checks..."
if ! ./scripts/check.sh; then
    echo -e "${RED}✗ CI checks failed${NC}"
    exit 1
fi
echo ""

# Step 3: Update version in Cargo.toml if needed
echo -e "${YELLOW}Step 3/7:${NC} Checking Cargo.toml version..."
CARGO_VERSION=$(grep '^version = ' crates/bridge/Cargo.toml | head -1 | sed 's/version = "\(.*\)"/\1/')
VERSION_NUMBER=${VERSION#v}
if [ "$CARGO_VERSION" != "$VERSION_NUMBER" ]; then
    echo -e "${YELLOW}⚠ Cargo.toml version ($CARGO_VERSION) doesn't match release version ($VERSION_NUMBER)${NC}"
    read -p "Update Cargo.toml? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sed -i.bak "s/^version = \".*\"/version = \"$VERSION_NUMBER\"/" crates/bridge/Cargo.toml
        rm crates/bridge/Cargo.toml.bak
        echo -e "${GREEN}✓ Updated Cargo.toml${NC}"
    fi
else
    echo -e "${GREEN}✓ Version matches${NC}"
fi
echo ""

# Step 4: Build all targets locally
echo -e "${YELLOW}Step 4/7:${NC} Building all targets..."
echo "This may take a while..."

# Build iOS
if ! ./scripts/build_ios.sh > /dev/null 2>&1; then
    echo -e "${RED}✗ iOS build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ iOS targets built${NC}"

# Build release
if ! cargo build --release > /dev/null 2>&1; then
    echo -e "${RED}✗ Release build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Release build complete${NC}"
echo ""

# Step 5: Generate changelog
echo -e "${YELLOW}Step 5/7:${NC} Generating changelog..."
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -n "$LAST_TAG" ]; then
    echo "Changes since $LAST_TAG:" > CHANGELOG_DRAFT.md
    echo "" >> CHANGELOG_DRAFT.md
    git log $LAST_TAG..HEAD --pretty=format:"- %s" >> CHANGELOG_DRAFT.md
    echo -e "${GREEN}✓ Changelog generated (CHANGELOG_DRAFT.md)${NC}"
else
    echo -e "${YELLOW}⚠ No previous tag found, skipping changelog${NC}"
fi
echo ""

# Step 6: Create and push tag
echo -e "${YELLOW}Step 6/7:${NC} Creating git tag..."
read -p "Create and push tag $VERSION? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}✗ Release cancelled${NC}"
    exit 1
fi

git tag -a "$VERSION" -m "Release $VERSION"
git push origin "$VERSION"
echo -e "${GREEN}✓ Tag created and pushed${NC}"
echo ""

# Step 7: Trigger GitHub release workflow
echo -e "${YELLOW}Step 7/7:${NC} GitHub Actions will now build release artifacts"
echo ""
echo -e "${GREEN}✅ Release $VERSION initiated!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Monitor GitHub Actions: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
echo "2. Once complete, edit the release notes on GitHub"
echo "3. Add CHANGELOG_DRAFT.md content to the release description"
echo ""
echo -e "${YELLOW}Release artifacts will include:${NC}"
echo "  • macOS binaries (arm64, x86_64)"
echo "  • iOS XCFramework with Swift bindings"
echo "  • Linux binaries (x86_64, aarch64)"
echo "  • Language bindings (Swift, Kotlin, Python, C++)"
echo "  • Checksums"


# Release Process

This document describes how to create and publish releases for controller.c.

## Quick Release

```bash
./scripts/release.sh v1.0.0
```

This automates the entire release process!

## What Gets Released

### 📦 Binaries

**Apple Platforms:**
- `controller_uniffi-macos-arm64.tar.gz` - macOS Apple Silicon
- `controller_uniffi-macos-x86_64.tar.gz` - macOS Intel
- `controller_uniffi_ios.tar.gz` - iOS XCFramework + Swift bindings

**Linux:**
- `controller_uniffi-linux-x86_64.tar.gz` - Linux x86_64
- `controller_uniffi-linux-aarch64.tar.gz` - Linux ARM64

### 🔧 Language Bindings

`controller_uniffi_bindings.tar.gz` includes:
- Swift bindings + headers
- Kotlin bindings
- Python bindings
- C++ bindings

### 🔐 Security

`CHECKSUMS.txt` - SHA256 checksums for all artifacts

## Manual Release Process

### 1. Prepare

```bash
# Ensure working directory is clean
git status

# Run all checks
./scripts/check.sh

# Update version in Cargo.toml if needed
vim Cargo.toml
```

### 2. Create Tag

```bash
# Create and push tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 3. Monitor GitHub Actions

The release workflow will automatically:
1. ✅ Create GitHub release
2. ✅ Build all platform binaries
3. ✅ Generate language bindings
4. ✅ Upload all artifacts
5. ✅ Generate checksums

Visit: `https://github.com/YOUR_REPO/actions`

### 4. Edit Release Notes

Once the workflow completes:
1. Go to the release on GitHub
2. Add changelog and release notes
3. Publish the release

## Triggering Releases

### Automatic (Recommended)

Push a version tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Manual Trigger

Use GitHub UI:
1. Go to Actions → Release
2. Click "Run workflow"
3. Enter version (e.g., v1.0.0)
4. Click "Run workflow"

## Release Workflow Details

### Jobs

1. **create-release** - Creates GitHub release
2. **build-apple** - Builds for macOS (arm64, x86_64) and iOS
3. **build-xcframework** - Creates iOS XCFramework with Swift bindings
4. **build-linux** - Builds for Linux (x86_64, aarch64)
5. **build-bindings** - Generates all language bindings
6. **publish-checksums** - Generates and uploads checksums

### Artifacts

Each job uploads its artifacts to the GitHub release:
- Binaries are packaged as `.tar.gz`
- Includes both static (`.a`) and dynamic (`.dylib`/`.so`) libraries
- XCFramework includes modulemap and headers

## Using Released Binaries

### iOS Development

```bash
# Download iOS XCFramework
./scripts/download-release.sh v1.0.0 ios

# Extract
cd controller_uniffi_ios

# Copy to your Xcode project
cp -r controller_uniffi.xcframework /path/to/your/project/
cp controller_uniffi.swift /path/to/your/project/
cp controller_uniffiFFI.h /path/to/your/project/
```

### macOS Development

```bash
# Download macOS binary
./scripts/download-release.sh v1.0.0 macos-arm64

# Link against the library
# -L path/to/lib -lcontroller_uniffi
```

### Language Bindings

```bash
# Download all bindings
./scripts/download-release.sh v1.0.0 bindings

# Use the appropriate binding for your language
```

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (v2.0.0) - Breaking changes
- **MINOR** (v1.1.0) - New features, backwards compatible
- **PATCH** (v1.0.1) - Bug fixes, backwards compatible

Examples:
- `v1.0.0` - Initial release
- `v1.1.0` - Added new feature
- `v1.1.1` - Bug fix
- `v2.0.0` - Breaking API change

## Pre-release

For beta/alpha releases:

```bash
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1
```

Mark as "pre-release" on GitHub.

## Hotfix Release

For urgent fixes:

```bash
# Create hotfix branch
git checkout -b hotfix/v1.0.1 v1.0.0

# Make fixes
git commit -m "Fix critical bug"

# Tag and release
git tag v1.0.1
git push origin v1.0.1
```

## Troubleshooting

### Release workflow failed

1. Check the Actions logs
2. Common issues:
   - Build errors (fix in code)
   - Missing targets (install with rustup)
   - Permission errors (check GITHUB_TOKEN)

### Artifact upload failed

Re-run the specific job in GitHub Actions.

### Tag already exists

```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0

# Recreate
git tag v1.0.0
git push origin v1.0.0
```

## Checklist

Before releasing:

- [ ] All tests pass (`./scripts/test.sh`)
- [ ] Code is formatted (`./scripts/fmt.sh`)
- [ ] No clippy warnings (`./scripts/clippy.sh`)
- [ ] Version updated in Cargo.toml
- [ ] Changelog prepared
- [ ] Release notes drafted

After releasing:

- [ ] All artifacts uploaded successfully
- [ ] Checksums generated
- [ ] Release notes added to GitHub
- [ ] Announcement made (if applicable)
- [ ] Documentation updated


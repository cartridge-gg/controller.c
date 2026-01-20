# Development Scripts

Convenience scripts for development and CI checks.

## 📋 Available Scripts

### Format & Linting

#### `./scripts/fmt.sh`
Format all Rust code with rustfmt.

```bash
# Format code
./scripts/fmt.sh

# Just check formatting (CI mode)
./scripts/fmt.sh --check
```

#### `./scripts/clippy.sh`
Run clippy linter.

```bash
# Check for warnings
./scripts/clippy.sh

# Auto-fix issues
./scripts/clippy.sh --fix
```

### Testing

#### `./scripts/test.sh`
Run test suite.

```bash
# Run tests
./scripts/test.sh

# Verbose output
./scripts/test.sh --verbose

# Show println! output
./scripts/test.sh --nocapture
```

### All Checks

#### `./scripts/check.sh`
Run all CI checks locally (format, clippy, tests, build).

```bash
./scripts/check.sh
```

This is what you should run before pushing to ensure CI will pass!

### Release

#### `./scripts/release.sh <version>`
Prepare and create a new release.

```bash
# Create a new release
./scripts/release.sh v1.0.0
```

This will:
- Run all CI checks
- Build all targets locally
- Generate changelog
- Create and push git tag
- Trigger GitHub Actions release workflow

#### `./scripts/download-release.sh <version> <platform>`
Download release artifacts.

```bash
# Download iOS XCFramework
./scripts/download-release.sh v1.0.0 ios

# Download macOS binary
./scripts/download-release.sh v1.0.0 macos-arm64

# Download all language bindings
./scripts/download-release.sh v1.0.0 bindings
```

### Building

#### `./scripts/build_ios.sh`
Build for iOS targets and create XCFramework.

```bash
./scripts/build_ios.sh
```

Includes:
- iOS device build (aarch64-apple-ios)
- iOS simulator build (aarch64-apple-ios-sim)
- Swift bindings generation
- XCFramework creation

#### `./scripts/build_swift.sh`
Generate Swift bindings only.

```bash
./scripts/build_swift.sh
```

#### `./scripts/build_kotlin.sh`
Generate Kotlin bindings.

```bash
./scripts/build_kotlin.sh
```

#### `./scripts/build_python.sh`
Generate Python bindings.

```bash
./scripts/build_python.sh
```

#### `./scripts/build_cpp.sh`
Generate C++ bindings.

```bash
./scripts/build_cpp.sh
```

#### `./scripts/build_android.sh`
Build native libraries for Android (React Native).

```bash
# Build for all ABIs
./scripts/build_android.sh

# Specify custom output directory
./scripts/build_android.sh path/to/jniLibs
```

Requires:
- `cargo-ndk` (`cargo install cargo-ndk`)
- Android NDK (via Android Studio)
- Rust Android targets (`rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android`)

#### `./scripts/build_react_native.sh`
Complete build script for React Native bindings (TypeScript, C++, and Android).

```bash
# Full build (bindings + Android + copy to example)
./scripts/build_react_native.sh

# Generate bindings only (no Android build)
./scripts/build_react_native.sh --bindings-only

# Build Android libraries only
./scripts/build_react_native.sh --android-only

# Skip Android (when NDK not available)
./scripts/build_react_native.sh --skip-android
```

Requires:
- `uniffi-bindgen-react-native` (see installation below)
- `cargo-ndk` (for Android builds)
- Android NDK (for Android builds)

Install `uniffi-bindgen-react-native`:
```bash
cargo install --git https://github.com/Larkooo/uniffi-bindgen-react-native \
    --branch update-uniffi-0.30 uniffi-bindgen-react-native
```

## 🔄 Typical Workflow

### Before Committing

```bash
# Run all checks
./scripts/check.sh
```

### After Rust Changes

```bash
# Format code
./scripts/fmt.sh

# Check lints
./scripts/clippy.sh

# Run tests
./scripts/test.sh
```

### After iOS-related Changes

```bash
# Rebuild iOS framework
./scripts/build_ios.sh

# Then build in Xcode
# Clean build folder (Cmd+Shift+K)
# Build and run (Cmd+R)
```

### After React Native Changes

```bash
# Regenerate bindings and build Android libs
./scripts/build_react_native.sh

# Then rebuild the example
cd examples/react-native
pnpm exec expo prebuild --clean
pnpm ios    # or pnpm android
```

## 🎯 Quick Reference

| Command | What it does |
|---------|-------------|
| `fmt.sh` | Format code |
| `fmt.sh --check` | Check formatting only |
| `clippy.sh` | Lint code |
| `clippy.sh --fix` | Auto-fix lints |
| `test.sh` | Run tests |
| `check.sh` | Run all CI checks |
| `build_ios.sh` | Build iOS framework |
| `build_android.sh` | Build Android native libs |
| `build_react_native.sh` | Build React Native bindings |
| `release.sh <version>` | Create a new release |
| `download-release.sh` | Download release artifacts |

## 💡 Tips

1. **Before every commit:** Run `./scripts/check.sh`
2. **Auto-fix lints:** Use `./scripts/clippy.sh --fix` then review changes
3. **Fast iteration:** Use `./scripts/fmt.sh && ./scripts/test.sh`
4. **iOS development:** Run `./scripts/build_ios.sh` after Rust changes
5. **Android development:** Run `./scripts/build_android.sh` after Rust changes
6. **React Native development:** Run `./scripts/build_react_native.sh` after Rust changes

## 🚨 CI Will Fail If...

- ❌ Code is not formatted (`fmt.sh --check` fails)
- ❌ Clippy warnings exist (`clippy.sh` fails)
- ❌ Tests fail (`test.sh` fails)
- ❌ Build fails

Run `./scripts/check.sh` to catch these locally!

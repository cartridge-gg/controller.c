# Controller.c Examples

This directory contains examples demonstrating how to use Controller.c in various programming languages and platforms.

## Available Examples

### 1. C Examples
Basic C examples showing low-level FFI usage.

- `test_controller.c` - Basic controller operations
- `test_session_account.c` - Session account management

**Run:**
```bash
./run.sh
```

### 2. C++ Example
Complete C++ implementation with CMake build system.

**Location:** `cpp/`

**Run:**
```bash
cd cpp
./run.sh
```

**Documentation:** [cpp/README.md](cpp/README.md)

### 3. Python Example
Python bindings demonstration using UniFFI Python bindings.

**Location:** `python/`

**Run:**
```bash
cd python
./run.sh
```

**Documentation:** [python/README.md](python/README.md)

### 4. Swift Examples
Swift implementations for macOS and iOS.

**Location:** `swift/`

**Examples:**
- Controller operations (`controller.swift`)
- Session account management (`session_account.swift`)
- iOS app with full UI (`ios-app/`)

**Run:**
```bash
cd swift
./run.sh  # Run controller example
./run_session_account.sh  # Run session account example
```

**Documentation:** [swift/README.md](swift/README.md)

### 5. React Native Example (New!)
Full React Native/Expo application demonstrating mobile integration.

**Location:** `react-native/`

**Features:**
- ✨ Key pair generation
- 🔐 Session account creation
- ✍️ Message signing
- 🔗 Starknet integration
- 📱 iOS support (Android coming soon)

**Quick Start:**
```bash
cd react-native
chmod +x run.sh
./run.sh
npm start
```

**Documentation:**
- [react-native/QUICKSTART.md](react-native/QUICKSTART.md) - Get started in 5 minutes
- [react-native/README.md](react-native/README.md) - Full documentation

## Building Prerequisites

Most examples require building the Controller.c bindings first:

### For C/C++/Python
```bash
cargo build
```

### For Swift/iOS
```bash
./scripts/build_ios.sh
```

### For React Native
```bash
./scripts/build_ios.sh  # Builds the XCFramework
```

## Example Structure

Each example typically includes:

- Source code demonstrating Controller usage
- Build/run scripts
- README with specific instructions
- Configuration files

## Testing Your Changes

After making changes to Controller.c:

1. Rebuild the library:
   ```bash
   cargo build
   ```

2. Regenerate bindings (if needed):
   ```bash
   # Example for React Native
   cargo uniffi-bindgen generate \
     --library target/debug/libcontroller_uniffi.dylib \
     --language react-native \
     --out-dir bindings/react-native
   ```

3. Run the relevant example to test

## Platform Support

| Example      | macOS | Linux | iOS | Android | Web |
|--------------|-------|-------|-----|---------|-----|
| C            | ✅     | ✅     | ❌   | ❌       | ❌   |
| C++          | ✅     | ✅     | ❌   | ❌       | ❌   |
| Python       | ✅     | ✅     | ❌   | ❌       | ❌   |
| Swift        | ✅     | ❌     | ✅   | ❌       | ❌   |
| React Native | ✅*    | ❌     | ✅   | 🚧      | ❌   |

*macOS support via iOS simulator

## Need Help?

- Check the README in each example directory
- [Main Controller.c Documentation](../README.md)
- [Open an issue](https://github.com/cartridge-gg/controller.c/issues)

## Contributing

Found a bug or want to add an example for another language? Contributions are welcome!

1. Fork the repository
2. Create your feature branch
3. Add your example with documentation
4. Submit a pull request


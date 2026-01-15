# Controller.c React Native Example

A minimal React Native example demonstrating how to use the Controller.c library with Expo and the New Architecture.

## Features

- ✅ Works with Expo
- ✅ React Native New Architecture (TurboModules/JSI)
- ✅ Simple session account example
- ✅ Key generation and felt validation
- ✅ iOS and Android support

## Prerequisites

- Node.js >= 20
- pnpm
- Xcode (for iOS)
- CocoaPods (for iOS)
- Android Studio with NDK (for Android)
- Rust with Android targets (for building Android native libs)

## Quick Start

1. Install dependencies:
```bash
pnpm install
```

2. Generate native projects:
```bash
pnpm exec expo prebuild
```

3. Run:
```bash
# iOS
pnpm run ios

# Android
pnpm run android
```

> **Note:** Pre-built native libraries are included in the repository for both iOS (`Controller.xcframework`) and Android (`jniLibs/*.so`).

## Rebuilding Android Native Libraries (Optional)

If you need to rebuild the Android native libraries (e.g., after Rust code changes):

### Prerequisites

1. Install `cargo-ndk`:
```bash
cargo install cargo-ndk
```

2. Install Android targets:
```bash
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
```

3. Set up Android NDK (Android Studio > SDK Manager > SDK Tools > NDK):
```bash
export ANDROID_NDK_HOME=$HOME/Library/Android/sdk/ndk/<version>
# or
export NDK_HOME=$HOME/Library/Android/sdk/ndk/<version>
```

### Build

```bash
./scripts/build_android.sh
```

This will build `libcontroller_uniffi.so` for all Android ABIs and place them in:
- `modules/controller/android/src/main/jniLibs/arm64-v8a/`
- `modules/controller/android/src/main/jniLibs/armeabi-v7a/`
- `modules/controller/android/src/main/jniLibs/x86/`
- `modules/controller/android/src/main/jniLibs/x86_64/`

## Running

### iOS
```bash
pnpm run ios
```

### Android
```bash
pnpm run android
```

### Development Server
```bash
pnpm start
```

## Project Structure

```
react-native/
├── app/                    # Expo Router app directory
│   ├── _layout.tsx         # Root layout
│   └── index.tsx           # Main screen
├── modules/
│   └── controller/         # Controller native module
│       ├── ios/            # iOS native code (Obj-C++)
│       ├── android/        # Android native code (Kotlin)
│       ├── cpp/            # Shared C++ bindings
│       ├── src/            # JS/TS module code
│       ├── Controller.podspec      # iOS CocoaPods config
│       ├── Controller.xcframework/ # iOS pre-built libs
│       └── package.json
├── ios/                    # iOS native project
├── android/                # Android native project
├── package.json
└── app.json               # Expo config
```

## How It Works

### iOS
1. The native Controller module is built as a CocoaPod
2. Pre-built static libraries are in `Controller.xcframework`
3. TurboModules via `ios/Controller.mm`

### Android
1. The native Controller module is built via Gradle/CMake
2. Pre-built shared libraries are in `android/src/main/jniLibs/`
3. TurboModules via Kotlin (`ControllerModule.kt`)

### Both Platforms
1. Uses TurboModules (React Native New Architecture) for performance
2. The Rust FFI is exposed via uniffi-bindgen-react-native
3. JSI (JavaScript Interface) provides direct JS <-> Native communication

## Troubleshooting

### iOS: Clean Build
```bash
# Clean everything
pnpm prebuild:clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
```

### iOS: Clean Xcode Cache
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Android: Clean Build
```bash
cd android && ./gradlew clean && cd ..
```

### Android: Clear Gradle Cache
```bash
rm -rf ~/.gradle/caches
```

## Example Code

See `app/index.tsx` for a simple example that demonstrates:
- Generating key pairs
- Validating felt values
- Using the Controller native module

## Related

- [uniffi-bindgen-react-native](https://github.com/Larkooo/uniffi-bindgen-react-native)
- [controller.c](https://github.com/cartridge-gg/controller.c)

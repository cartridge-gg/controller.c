# Controller.c React Native Example

A minimal React Native example demonstrating how to use the Controller.c library with Expo and the New Architecture.

## Features

- ✅ Works with Expo
- ✅ React Native New Architecture (TurboModules/JSI)
- ✅ Simple session account example
- ✅ Key generation and felt validation

## Prerequisites

- Node.js >= 20
- pnpm
- Xcode (for iOS)
- CocoaPods

## Setup

1. Install dependencies:
```bash
pnpm install
```

2. Generate native projects:
```bash
pnpm exec expo prebuild
```

3. (iOS only) Install CocoaPods:
```bash
cd ios && pod install && cd ..
```

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
│       ├── cpp/            # C++ bindings
│       ├── src/            # JS/TS module code
│       ├── Controller.podspec
│       └── package.json
├── ios/                    # iOS native project
├── package.json
└── app.json               # Expo config
```

## How It Works

1. The native Controller module is built as a CocoaPod
2. It uses TurboModules (React Native New Architecture) for performance
3. The Rust FFI is exposed via uniffi-bindgen-react-native
4. JSI (JavaScript Interface) provides direct JS <-> Native communication

## Troubleshooting

### Clean Build
```bash
# Clean everything
pnpm prebuild:clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
```

### Clean Xcode Cache
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

## Example Code

See `app/index.tsx` for a simple example that demonstrates:
- Generating key pairs
- Validating felt values
- Using the Controller native module

## Related

- [uniffi-bindgen-react-native](https://github.com/Larkooo/uniffi-bindgen-react-native)
- [controller.c](https://github.com/cartridge-gg/controller.c)

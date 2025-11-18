# Quick Start Guide

Get the Controller.c React Native example running in 5 minutes!

## Prerequisites

- macOS with Xcode installed
- Node.js >= 20
- pnpm (`npm install -g pnpm`)
- CocoaPods (`sudo gem install cocoapods`)

## Quick Setup

```bash
# 1. Navigate to the example directory
cd examples/react-native

# 2. Make the run script executable
chmod +x run.sh

# 3. Run the setup script (builds XCFramework, installs dependencies)
./run.sh

# 4. Start the app
pnpm start
# Then press 'i' for iOS simulator
```

## Manual Setup (Alternative)

If the script doesn't work, follow these steps:

```bash
# 1. Build the XCFramework
cd ../..  # Go to controller.c root
./scripts/build_ios.sh
cd examples/react-native

# 2. Install dependencies
pnpm install

# 3. Prebuild Expo project
pnpm exec expo prebuild

# 4. Install iOS pods
cd ios
pod install
cd ..

# 5. Run the app
pnpm run ios
```

## What You'll See

The example app demonstrates:

1. **Key Generation** - Generate cryptographic keypairs
2. **Session Creation** - Create Starknet session accounts
3. **Message Signing** - Sign messages with your keys
4. **RPC Integration** - Connect to Starknet networks

## Troubleshooting

### Build fails with "XCFramework not found"

Make sure the XCFramework is built:

```bash
cd /path/to/controller.c
./scripts/build_ios.sh
```

### Pod install fails

Try updating CocoaPods:

```bash
sudo gem install cocoapods
pod repo update
```

### Metro bundler won't start

Clear the cache:

```bash
pnpm start -- --reset-cache
```

## Next Steps

- Check out the full [README.md](./README.md) for detailed documentation
- Explore the code in `app/index.tsx` to see how the Controller is used
- Modify the example to test your own use cases

## Need Help?

- [Controller.c Repository](https://github.com/cartridge-gg/controller.c)
- [Open an Issue](https://github.com/cartridge-gg/controller.c/issues)


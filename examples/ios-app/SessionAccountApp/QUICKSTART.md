# Quick Start Guide - Session Account iOS App

Get the app running in 5 minutes!

## 🚀 Quick Setup

### 1. Run Setup Script

```bash
cd controller.c/examples/ios-app/SessionAccountApp
./setup_xcode_project.sh
```

This will:
- Build the controller library
- Generate Swift bindings
- Create Info.plist
- Create bridging header

### 2. Create Xcode Project

Open Xcode and create a new iOS App project:

```
File > New > Project > iOS > App

Settings:
- Product Name: SessionAccountApp
- Team: [Your Team]
- Organization Identifier: com.cartridge
- Bundle Identifier: com.cartridge.sessionaccount
- Interface: SwiftUI
- Language: Swift
- Storage: None
- Include Tests: Optional
```

### 3. Add Files to Project

**Drag these files into your Xcode project:**

From `SessionAccountApp/`:
- ✅ SessionAccountApp.swift
- ✅ SessionManager.swift
- ✅ SessionAccountView.swift
- ✅ Views/SetupView.swift
- ✅ Views/ExecuteView.swift
- ✅ Views/StatusView.swift

From `bindings/swift/`:
- ✅ controller_uniffi.swift

### 4. Configure Build Settings

**Target > Build Settings:**

1. **Search for "Bridging"**:
   - Objective-C Bridging Header: `SessionAccountApp-Bridging-Header.h`

2. **Search for "Library Search Paths"**:
   - Add: `$(PROJECT_DIR)/../../../target/release`

3. **Search for "Runpath Search Paths"**:
   - Add: `$(PROJECT_DIR)/../../../target/release`
   - Add: `@executable_path/Frameworks`

### 5. Link Library

**Target > Build Phases > Link Binary With Libraries:**

1. Click `+`
2. Click "Add Other..." > "Add Files..."
3. Navigate to `controller.c/target/release/`
4. Select `libcontroller_uniffi.dylib`
5. Click "Add"

### 6. Build & Run! 🎉

- Select iPhone Simulator
- Hit ⌘R to run
- App should launch successfully!

## 📱 Using the App

### Create Your First Session

1. **Setup Tab**:
   - Default policies are already configured
   - Click "Open Browser to Authorize"
   - Complete authorization in Safari
   - Return to app
   - Click "Subscribe & Create Session"

2. **Execute Tab**:
   - Click "Custom Contract Call"
   - Select "transfer" policy
   - Click "Fill Transfer Example"
   - Click "Execute Transaction"

3. **Status Tab**:
   - View transaction hash
   - Click "View on Starkscan"

### Add Custom Policies

1. Go to Setup tab
2. Click "Add Policy"
3. Choose contract (ETH, STRK, or custom)
4. Choose method (transfer, approve, etc.)
5. Click "Add Policy"
6. Toggle to enable/disable

## 🔧 Troubleshooting

### "Library not loaded" error

**Solution**: Check Library Search Paths and Runpath Search Paths in Build Settings

### "Missing bridging header" error

**Solution**: 
1. Verify `SessionAccountApp-Bridging-Header.h` exists
2. Check path in Build Settings
3. Make sure it references `controller_uniffiFFI.h` correctly

### "Undefined symbols" error

**Solution**: Make sure `libcontroller_uniffi.dylib` is linked in Build Phases

### Build succeeds but app crashes on launch

**Solution**: 
1. Check Info.plist is included in bundle
2. Verify library is in Runpath Search Paths
3. Check Console for detailed error

## 📂 Expected Project Structure

```
SessionAccountApp.xcodeproj
SessionAccountApp/
├── SessionAccountApp.swift
├── SessionManager.swift
├── SessionAccountView.swift
├── Views/
│   ├── SetupView.swift
│   ├── ExecuteView.swift
│   └── StatusView.swift
├── controller_uniffi.swift (from bindings/)
├── SessionAccountApp-Bridging-Header.h
├── Info.plist
└── Assets.xcassets/
```

## 🎯 Common Tasks

### Change Network

Edit `SessionManager.swift`:
```swift
let rpcUrl = "https://api.cartridge.gg/x/starknet/mainnet"  // For mainnet
// or
let rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia"   // For testnet
```

### Add More Contracts

Edit `SessionManager.swift`:
```swift
let commonContracts = [
    ("ETH Token", "0x049d36..."),
    ("STRK Token", "0x04718f..."),
    ("My Game", "0x..."),  // Add your contract
]
```

### Debug Mode

Enable detailed logging:
```swift
// In SessionManager.swift, add:
func log(_ message: String) {
    print("🔍 SessionManager: \(message)")
}
```

## 📚 Next Steps

- [ ] Read full README.md
- [ ] Test on physical device
- [ ] Implement secure key storage
- [ ] Add error handling
- [ ] Customize UI
- [ ] Add more contract presets
- [ ] Implement session expiration

## 💡 Tips

- Use Simulator for initial testing
- Test with Sepolia testnet first
- Keep transaction amounts small during testing
- Check Starkscan for transaction status
- Save your private key for testing (dev only!)

## 🆘 Need Help?

- Check README.md for detailed information
- Review [Cartridge Docs](https://docs.cartridge.gg)
- Check iOS console logs for errors
- Verify controller library is built correctly

---

**Ready to build amazing Web3 experiences on iOS! 🚀**



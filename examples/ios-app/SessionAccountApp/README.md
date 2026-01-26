# Session Account iOS App

A complete iOS app demonstrating how to create and use Cartridge Controller Session Accounts with a visual interface.

## Features

✨ **Complete Session Management**
- Generate or import private keys
- Create custom session policies
- Visual policy builder with common contracts and methods
- Open browser for session authorization
- Subscribe and create session from API

🎯 **Transaction Execution**
- Execute transactions using session
- Pre-filled templates for common operations (transfer, approve)
- Custom contract call interface
- Real-time transaction status

📊 **Status Dashboard**
- Session information and status
- Active policies overview
- Transaction history
- Quick links to blockchain explorers

## Screenshots

### Setup Tab
- Configure private/public keys
- Build custom policies for your session
- Add/remove policies with enabled/disabled toggle
- Open browser to authorize
- Subscribe to create session

### Execute Tab
- Quick actions for common operations
- Browse available policies
- Custom contract call builder
- Execute transactions with your session

### Status Tab
- Session status and info
- Active policies list
- Last transaction details with Voyager link
- Configuration details

## How It Works

### 1. Setup Session (Setup Tab)

1. **Generate Keys**: App generates a private key or use existing one
2. **Configure Policies**: Add policies specifying:
   - Contract address (ETH, STRK, or custom)
   - Method/entrypoint name (transfer, approve, etc.)
3. **Open Browser**: Click to open Keychain in Safari
4. **Authorize**: Complete session creation in browser
5. **Subscribe**: Return to app and click "Subscribe & Create Session"

### 2. Execute Transactions (Execute Tab)

1. Select a policy to use
2. Fill in calldata (arguments)
3. Use presets for common operations
4. Execute the transaction
5. View transaction hash in Status tab

### 3. Monitor Status (Status Tab)

- View session status
- Check active policies
- Copy transaction hashes
- Open transactions in Voyager

## Building the App

### Prerequisites

- Xcode 15 or later
- iOS 17 SDK or later
- Controller UniFFI bindings built

### Build Steps

1. **Build Controller Library**:
   ```bash
   cd controller.c
   cargo build --release
   ./scripts/build_swift.sh
   ```

2. **Create Xcode Project**:
   ```bash
   cd examples/ios-app/SessionAccountApp
   ```

3. **In Xcode**:
   - Open `SessionAccountApp` folder
   - Add Swift files to project
   - Link `libcontroller_uniffi.dylib` from `controller.c/target/release/`
   - Add bridging header for `controller_uniffiFFI.h`
   - Add `controller_uniffi.swift` to project

4. **Configure Info.plist**:
   ```xml
   <key>LSApplicationQueriesSchemes</key>
   <array>
       <string>https</string>
   </array>
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

5. **Run on Simulator or Device**

## Project Structure

```
SessionAccountApp/
├── SessionAccountApp.swift          # App entry point
├── SessionManager.swift              # Core session logic
├── SessionAccountView.swift          # Main tab view
└── Views/
    ├── SetupView.swift               # Policy config & session creation
    ├── ExecuteView.swift             # Transaction execution
    └── StatusView.swift              # Status dashboard
```

## Usage Example

### Creating a Transfer Session

1. **Setup**:
   - Go to Setup tab
   - Default ETH transfer policy is already added
   - Click "Open Browser to Authorize"
   - Complete authorization in browser
   - Return and click "Subscribe & Create Session"

2. **Execute**:
   - Go to Execute tab
   - Select "transfer" policy
   - Click "Fill Transfer Example" for sample data
   - Or enter custom recipient and amount
   - Click "Execute Transaction"

3. **Verify**:
   - Go to Status tab
   - See transaction hash
   - Click "View on Voyager"

### Adding Custom Policies

1. In Setup tab, click "Add Policy"
2. Select contract:
   - ETH Token
   - STRK Token
   - Or enter custom address
3. Select method:
   - transfer, approve, transfer_from, mint, burn
   - Or enter custom method name
4. Click "Add Policy"

### Common Use Cases

**Gaming Session**:
```
Contract: [Your Game Contract]
Methods: move_player, attack, claim_reward
```

**DeFi Session**:
```
Contract: [DEX Contract]
Methods: swap, add_liquidity, remove_liquidity
```

**NFT Session**:
```
Contract: [NFT Contract]
Methods: mint, transfer, approve
```

## Security Notes

⚠️ **Important**:
- Private keys are stored in UserDefaults (for demo only)
- **Production apps should use Keychain or Secure Enclave**
- Session keys have limited permissions (only approved contracts/methods)
- Sessions should have expiration times
- Always validate transaction details before execution

## Production Checklist

Before deploying to production:

- [ ] Implement secure key storage (Keychain/Secure Enclave)
- [ ] Add biometric authentication
- [ ] Implement session expiration handling
- [ ] Add transaction confirmation dialogs
- [ ] Implement proper error handling and recovery
- [ ] Add analytics and monitoring
- [ ] Test on multiple iOS versions
- [ ] Add accessibility features
- [ ] Implement offline support
- [ ] Add unit and UI tests

## Troubleshooting

**"Failed to create session"**
- Ensure you completed browser authorization
- Check network connection
- Verify public key matches

**"Transaction failed"**
- Verify account has sufficient balance
- Check policy includes the method
- Ensure contract address is correct

**"No session available"**
- Create session in Setup tab first
- Check session hasn't expired

## Network Configuration

Currently configured for **Sepolia testnet**. To switch networks:

1. Update `SessionManager.swift`:
   ```swift
   let rpcUrl = "https://api.cartridge.gg/x/starknet/mainnet"
   // or
   let rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia"
   ```

2. Rebuild and restart app

## Resources

- [Cartridge Controller Docs](https://docs.cartridge.gg/controller/overview)
- [Session Management](https://docs.cartridge.gg/controller/sessions)
- [Starknet Docs](https://docs.starknet.io)
- [Voyager Explorer](https://voyager.online)

## License

See main project LICENSE.



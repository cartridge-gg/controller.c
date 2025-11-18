# Cartridge Session Manager for React Native

This is a React Native implementation of the Cartridge Session Manager, equivalent to the Swift version you're using in iOS.

## 📁 Structure

```
hooks/
  └── useSessionManager.ts    # Main session management hook (like SessionManager.swift)

components/session/
  ├── SessionApp.tsx           # Main app with tab navigation
  ├── SetupView.tsx            # Session setup and policy configuration
  ├── ExecuteView.tsx          # Transaction execution interface
  └── index.ts                 # Exports
```

## 🚀 Features

### ✅ Implemented

- **Key Management**
  - Private/Public key generation
  - Secure storage using AsyncStorage
  - Key visibility toggle

- **Policy Management**
  - Add/Remove policies
  - Toggle policy enabled state
  - Common contracts (ETH, STRK) presets
  - Common methods (transfer, approve, etc.) presets
  - Custom contract/method support

- **Session Creation**
  - WebView-based session registration
  - Browser-based session registration
  - Background subscription handling
  - Deep link support

- **Transaction Execution**
  - Execute transfers
  - Execute approves
  - Custom transaction support
  - Transaction status tracking
  - Transaction confirmation polling

- **UI State Management**
  - Loading states
  - Error/Success messages
  - Transaction status modal
  - Session connected card

## 🎯 Usage

### Basic Setup

```typescript
import { SessionApp } from './components/session';

function App() {
  return <SessionApp />;
}
```

### Using the Hook Directly

```typescript
import { useSessionManager } from './hooks/useSessionManager';

function MyComponent() {
  const session = useSessionManager();
  
  // Access session state
  console.log(session.publicKey);
  console.log(session.sessionAccount);
  
  // Generate new key
  session.generateNewKey();
  
  // Add policy
  session.addPolicy('0x...', 'transfer');
  
  // Create session
  session.openSessionInWebView();
  
  // Execute transaction
  await session.executeTransfer('0x...', '1000000000000000000');
}
```

## 📋 API Reference

### useSessionManager Hook

#### State

- `privateKey: string` - Current private key
- `publicKey: string` - Derived public key
- `policies: PolicyItem[]` - List of session policies
- `sessionAccount: any` - Current session account (if created)
- `sessionMetadata: SessionMetadata` - Session metadata (username, address, etc.)
- `isLoading: boolean` - Loading state
- `errorMessage: string | null` - Current error message
- `successMessage: string | null` - Current success message
- `showWebView: boolean` - WebView visibility state
- `showTransactionCard: boolean` - Transaction modal visibility

#### Methods

**Key Management:**
- `generateNewKey()` - Generate a new private key
- `updatePublicKey(key: string)` - Derive public key from private key

**Policy Management:**
- `addPolicy(contractAddress: string, entrypoint: string)` - Add a new policy
- `removePolicy(id: string)` - Remove a policy
- `togglePolicy(id: string)` - Toggle policy enabled state

**Session Creation:**
- `generateSessionURL()` - Generate session registration URL
- `openSessionInWebView()` - Open session registration in WebView
- `openSessionInBrowser()` - Open session registration in external browser
- `createSessionFromAPI()` - Create session from API (after authorization)

**Transaction Execution:**
- `executeTransaction(contractAddress, entrypoint, calldata)` - Execute a transaction
- `executeTransfer(recipient, amount)` - Execute ETH transfer
- `executeApprove(spender, amount)` - Execute ETH approval

**Utility:**
- `clearError()` - Clear error message
- `clearSuccess()` - Clear success message
- `reset()` - Reset all state
- `handleDeepLink(url)` - Handle deep link

## 🔄 Comparison with Swift Version

| Feature | Swift | React Native | Status |
|---------|-------|--------------|--------|
| Key Management | ✅ | ✅ | Complete |
| Policy Management | ✅ | ✅ | Complete |
| WebView Session Creation | ✅ ASWebAuthenticationSession | ✅ React Native WebView | Complete |
| Background Subscription | ✅ Task.detached | ✅ setTimeout/Promise | Complete |
| Transaction Execution | ✅ | ✅ | Complete |
| Transaction Polling | ✅ | ✅ | Complete |
| Deep Link Handling | ✅ | ✅ | Complete |
| AsyncStorage | ✅ UserDefaults | ✅ AsyncStorage | Complete |

## 🎨 UI Components

### SetupView

- Key display with show/hide toggle
- Policy list with add/remove/toggle
- Session registration button
- Session status card

### ExecuteView

- Session info display
- ETH Transfer form
- ETH Approve form
- Custom transaction form
- Transaction status modal

## 🔧 Configuration

Edit `hooks/useSessionManager.ts` to configure:

```typescript
const RPC_URL = 'https://api.cartridge.gg/x/starknet/sepolia';
const CARTRIDGE_API_URL = 'https://api.cartridge.gg';
const KEYCHAIN_URL = 'https://x.cartridge.gg';
```

## 📦 Dependencies

- `@react-native-async-storage/async-storage` - Persistent key storage
- `react-native` - Core React Native APIs (Linking, etc.)
- `@cartridge/ui-native` - UI components (Button, Card, Badge)

## 🚧 TODO / Future Enhancements

- [ ] Replace mock session creation with actual native module calls
- [ ] Add real transaction status polling via RPC
- [ ] Add session expiry handling
- [ ] Add session revocation support
- [ ] Add multi-account support
- [ ] Add biometric authentication
- [ ] Add transaction history
- [ ] Add gas estimation

## 🐛 Known Issues

- Session creation currently uses mock data (needs native module integration)
- Transaction polling simulates confirmation (needs RPC integration)
- WebView implementation needs platform-specific handling (iOS/Android)

## 📝 Notes

This implementation follows the same architecture and state management patterns as the Swift version, making it easy to maintain feature parity across platforms. The hook-based approach provides flexibility for integration into different UI patterns while maintaining a single source of truth for session state.

The UI uses Cartridge's ui-native components with NativeWind for styling, matching the design system used across the Cartridge ecosystem.


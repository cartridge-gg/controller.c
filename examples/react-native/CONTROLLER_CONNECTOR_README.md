# Cartridge Controller Mobile Connector

A React Native connector for Cartridge Controller that uses native session management.

## Overview

The `MobileConnector` provides a standard Starknet connector interface (`@starknet-react/core`) that works with native session accounts created via the Cartridge Controller native module.

## Key Features

- **Native Session Management**: Uses `SessionAccount.createFromSubscribe` from the native module
- **Safari Authentication**: Opens Safari for secure authentication (ASWebAuthenticationSession equivalent)
- **Automatic Key Management**: Generates and securely stores session keys
- **Direct Transaction Execution**: Executes transactions directly without WebView callbacks
- **Standard Connector Interface**: Compatible with `@starknet-react/core`

## Architecture

```
MobileConnector (extends Connector from @starknet-react/core)
├── MobileProvider (handles connection logic)
│   ├── Uses native SessionAccount.createFromSubscribe
│   ├── Opens Safari for authorization
│   └── Manages session lifecycle
└── MobileAccount (extends WalletAccount)
    ├── Wraps native SessionAccount
    └── Executes transactions via executeFromOutside
```

## Usage

### Option 1: Using the Hook (Recommended)

```typescript
import { useController } from './hooks/useController';

function MyComponent() {
  const {
    isConnected,
    isConnecting,
    address,
    username,
    connect,
    disconnect,
    getAccount,
    getSessionInfo,
  } = useController({
    policies: [
      {
        target: '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7',
        method: 'transfer',
      },
    ],
  });

  return (
    <View>
      {!isConnected ? (
        <Button onPress={connect} disabled={isConnecting}>
          Connect Controller
        </Button>
      ) : (
        <View>
          <Text>Connected as: {username}</Text>
          <Text>Address: {address}</Text>
          <Button onPress={disconnect}>Disconnect</Button>
        </View>
      )}
    </View>
  );
}
```

### Option 2: Using the Connector Directly

```typescript
import { MobileConnector } from './packages/ui-native/src/utils/controller/connector';

// Create connector
const connector = new MobileConnector({
  policies: [
    {
      target: '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7',
      method: 'transfer',
    },
  ],
});

// Connect
const result = await connector.connect();
console.log('Connected:', result.account);

// Get account
const account = await connector.account();

// Execute transaction
const tx = await account.execute([
  {
    contractAddress: '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7',
    entrypoint: 'transfer',
    calldata: [recipientAddress, amount, '0x0'],
  },
]);

console.log('Transaction hash:', tx.transaction_hash);

// Get session info
const sessionInfo = connector.controller.getSessionInfo();
console.log('Session expires:', new Date(sessionInfo.expiresAt * 1000));

// Disconnect
await connector.disconnect();
```

### Option 3: With @starknet-react/core

```typescript
import { StarknetConfig, useAccount, useConnect } from '@starknet-react/core';
import { MobileConnector } from './packages/ui-native/src/utils/controller/connector';

const connectors = [
  new MobileConnector({
    policies: [...],
  }),
];

function App() {
  return (
    <StarknetConfig connectors={connectors}>
      <MyDapp />
    </StarknetConfig>
  );
}

function MyDapp() {
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();

  return (
    <View>
      {!isConnected ? (
        <Button onPress={() => connect({ connector: connectors[0] })}>
          Connect
        </Button>
      ) : (
        <Text>Connected: {address}</Text>
      )}
    </View>
  );
}
```

## How It Works

### Connection Flow

1. **Generate Key**: Creates a random private key (or loads existing one from SecureStore)
2. **Derive Public Key**: Uses `Controller.controller.getPublicKey(privateKey)`
3. **Open Safari**: Opens Safari with the session URL (`https://x.cartridge.gg/session?public_key=...&policies=...`)
4. **Background Subscription**: Simultaneously calls `SessionAccount.createFromSubscribe` which **blocks** and waits for authorization
5. **User Authorizes**: User completes authorization in Safari
6. **Session Created**: Native module receives callback, `createFromSubscribe` returns with `SessionAccount`
7. **Safari Dismisses**: Safari automatically closes
8. **Account Ready**: `MobileAccount` wrapper is created and ready for transactions

### Transaction Execution

1. **Call `account.execute(calls)`**
2. **Convert to SessionCall format**
3. **Execute via `sessionAccount.executeFromOutside(calls)`**
4. **Return transaction hash**

No WebView needed for transactions! 🎉

## API Reference

### MobileConnector

#### Methods

- `connect(): Promise<{ account: string; chainId: bigint }>` - Opens Safari and creates session
- `disconnect(): Promise<void>` - Disconnects and clears session
- `account(): Promise<MobileAccount>` - Returns the connected account
- `chainId(): Promise<bigint>` - Returns the chain ID

### MobileProvider

#### Methods

- `connect(): Promise<MobileAccount>` - Creates session account
- `disconnect(): void` - Clears session
- `getSessionInfo()` - Returns session metadata (address, username, expiry, etc.)
- `reconnect(): Promise<MobileAccount | undefined>` - Attempts to reconnect (TODO: needs session persistence)

### MobileAccount

#### Methods

- `execute(calls): Promise<{ transaction_hash: string }>` - Executes transaction via native session
- `signMessage(typedData): Promise<SIGNATURE>` - Signs a message (opens Safari for approval)

## Configuration

### Policies

Policies define which contract methods the session can call:

```typescript
{
  policies: [
    {
      target: '0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7', // Contract address
      method: 'transfer', // Method name
    },
  ],
}
```

### Chains

```typescript
{
  chains: [
    { rpcUrl: 'https://api.cartridge.gg/x/starknet/sepolia' },
  ],
  defaultChainId: constants.StarknetChainId.SN_SEPOLIA,
}
```

## Comparison with Session Manager Hook

| Feature | MobileConnector | useSessionManager Hook |
|---------|----------------|------------------------|
| Architecture | Standard connector | Custom hook |
| Integration | `@starknet-react/core` | Manual state management |
| UI | Bring your own | Built-in components |
| Transactions | Direct execution | Direct execution |
| State Management | Connector-based | React state |
| Reusability | High (ecosystem compatible) | Medium (app-specific) |

## Migration from useSessionManager

If you're using `useSessionManager`, you can migrate to `useController`:

### Before (useSessionManager)

```typescript
const sessionManager = useSessionManager();

await sessionManager.openSessionInWebView();
await sessionManager.executeTransfer(recipient, amount);
```

### After (useController)

```typescript
const { connect, getAccount } = useController({ policies: [...] });

await connect();
const account = await getAccount();
await account.execute([{
  contractAddress: ethContract,
  entrypoint: 'transfer',
  calldata: [recipient, amount, '0x0'],
}]);
```

## Security

- **Private keys** are stored in `expo-secure-store` (iOS Keychain / Android KeyStore)
- **Safari authentication** uses system Safari for secure cookie isolation
- **Session expiry** is enforced by the native module
- **Policy enforcement** prevents unauthorized contract calls

## Troubleshooting

### "No session account available"
- Make sure you called `connect()` first
- Check if session is expired: `getSessionInfo().isExpired`

### Safari doesn't close automatically
- The connector calls `WebBrowser.dismissBrowser()` after session creation
- If it doesn't work, Safari will close when user taps "Done"

### "Failed to generate key: property crypto does not exist"
- Make sure `react-native-get-random-values` is imported at the top of the file
- Already included in `provider.ts`

## Example App

See `components/ControllerExample.tsx` for a complete working example.

## Next Steps

- [ ] Implement session persistence (reconnect without Safari)
- [ ] Add transaction status tracking
- [ ] Support multiple sessions
- [ ] Add session renewal before expiry


# SessionAccount Swift Example

This example demonstrates how to create and use a SessionAccount with the Cartridge Controller.

## Overview

SessionAccounts allow users to authorize limited permissions for automated transactions without exposing their main account. This is perfect for:

- Gaming sessions with pre-approved actions
- Automated trading bots with limited permissions
- Mobile apps that need to execute transactions without constant user approval

## What This Example Does

1. **Generates a Key Pair**: Creates a random private key and derives the public key
2. **Builds Session Policies**: Defines what contracts and methods the session can call
3. **Creates Session URL**: Generates a URL for the user to authorize the session in their browser
4. **Waits for Authorization**: Pauses until the user creates the session in Keychain
5. **Creates SessionAccount**: Fetches the session from the Cartridge API
6. **Executes Transaction**: Tests the session by executing an approved transaction

## Prerequisites

- Swift compiler installed
- Rust toolchain (for building the library)
- Internet connection (for API calls)
- A web browser (for session creation)

## Running the Example

### Quick Start

```bash
./run_session_account.sh
```

### Manual Build

```bash
# 1. Build the controller library
cd ../..
cargo build --release

# 2. Compile the Swift example
cd examples/swift
swiftc \
    -import-objc-header ../../bindings/swift/ControllerFFI.h \
    -L ../../target/release \
    -lcontroller_uniffi \
    -Xlinker -rpath -Xlinker ../../target/release \
    ../../bindings/swift/Controller.swift \
    session_account.swift \
    -o session_account_example

# 3. Run
./session_account_example
```

## How It Works

### 1. Key Generation

```swift
let privateKey = generateStarkPrivateKey()
let publicKey = try getPublicKey(privateKey: privateKey)
```

### 2. Policy Creation

```swift
let transferPolicy = SessionPolicy(
    contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
    entrypoint: "transfer"
)

let policies = SessionPolicies(
    policies: [transferPolicy],
    maxFee: "0x100000000000000"
)
```

### 3. Session Authorization

The user opens a URL in their browser to authorize the session:

```
https://x.cartridge.gg/session
  ?public_key=0x...
  &policies=[...]
  &rpc_url=https://api.cartridge.gg/x/starknet/mainnet
```

### 4. Session Creation

```swift
let sessionAccount = try SessionAccount.createFromSubscribe(
    privateKey: privateKey,
    policies: policies,
    rpcUrl: RPC_URL,
    cartridgeApiUrl: CARTRIDGE_API_URL
)
```

### 5. Transaction Execution

```swift
let call = Call(
    contractAddress: ethContractAddress,
    entrypoint: "transfer",
    calldata: [recipient, amount, "0x0"]
)

let txHash = try sessionAccount.execute(calls: [call])
```

## Configuration

Edit these constants in `session_account.swift`:

```swift
let RPC_URL = "https://api.cartridge.gg/x/starknet/mainnet"
let CARTRIDGE_API_URL = "https://api.cartridge.gg"
let KEYCHAIN_URL = "https://x.cartridge.gg"
```

For testing on Sepolia:
```swift
let RPC_URL = "https://api.cartridge.gg/x/starknet/sepolia"
```

## Understanding Session Policies

### Policy Structure

Each policy defines:
- **Contract Address**: Which contract can be called
- **Entrypoint**: Which function can be executed
- **Max Fee**: Maximum gas fee for all transactions

### Common Use Cases

**Gaming Session:**
```swift
let gamePolicy = SessionPolicy(
    contractAddress: gameContractAddress,
    entrypoint: "move_player"
)
```

**DeFi Trading:**
```swift
let swapPolicy = SessionPolicy(
    contractAddress: dexContractAddress,
    entrypoint: "swap"
)
```

**NFT Operations:**
```swift
let mintPolicy = SessionPolicy(
    contractAddress: nftContractAddress,
    entrypoint: "mint"
)
```

## Error Handling

Common errors and solutions:

### "Failed to create session account"
- **Cause**: Session not created in browser or network issue
- **Solution**: Ensure you completed the browser authorization step

### "Transaction execution failed"
- **Cause**: Insufficient balance or missing permissions
- **Solution**: Check account balance and policy permissions

### "Invalid public key"
- **Cause**: Private key format incorrect
- **Solution**: Ensure private key is a valid hex string with 0x prefix

## Session Lifecycle

1. **Create**: Generate keys and policies → User authorizes in browser
2. **Use**: Execute transactions within policy limits
3. **Expire**: Sessions have expiration times for security
4. **Refresh**: Create new sessions when expired

## Security Considerations

⚠️ **Important Security Notes:**

- Never hardcode private keys in production
- Store private keys securely (keychain/secure enclave)
- Set appropriate session expiration times
- Limit policies to minimum required permissions
- Monitor session usage for suspicious activity

## Next Steps

After running this example, you can:

1. **Persist Sessions**: Store session data for reuse
2. **Handle Expiration**: Implement session refresh logic
3. **Multi-Policy Sessions**: Create sessions with multiple policies
4. **Session Management**: List and revoke sessions
5. **Integration**: Integrate into your application

## Related Examples

- `controller.swift` - Full controller functionality test
- `run.sh` - Complete controller workflow

## Support

- [Cartridge Documentation](https://docs.cartridge.gg)
- [Controller Overview](https://docs.cartridge.gg/controller/overview)
- [Session Management](https://docs.cartridge.gg/controller/sessions)

## License

See the main project LICENSE file.


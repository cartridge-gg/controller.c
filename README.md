# Controller SDK C/Python/Swift Bindings

This project provides C, Python, and Swift bindings for the Controller SDK using Diplomat. [Diplomat](https://rust-diplomat.github.io/diplomat/intro.html) provides an easy way to generate bindings to different languages. Swift bindings are built on top of the C bindings. 

## Quick Start

### Build the library and generate bindings

```bash
./scripts/build.sh <py|c|swift>
```

### Run Examples

#### C Example

```bash
./examples/run.sh
```

#### Python Example (Recommended)

```bash
# One-command setup and run
./run_python_example.sh

# Or manually
cd examples/python
./setup_and_run.sh
```

#### Swift Example

```bash
cd examples/swift
./run.sh
```

## Examples

- **C Controller Example**: `examples/test_controller.c` - Basic C usage demonstration
- **C Session flow Example**: `examples/test_session_account.c` - Basic C usage demonstration for the register session flow.
- **Python Example**: `examples/python/` - Complete Python example with setup automation
- **Swift Example**: `examples/swift/` - Swift example demonstrating Controller and SessionAccount usage

## Configuration

### Change binding target language

[Generator/main.rs](./crates/generator/src/main.rs) accepts a command line argument to change the target-language. Supported values are:
- `py` - Python bindings using nanobind
- `c` - C bindings
- `swift` - Swift bindings (wraps C bindings)

### Python Bindings

The Python bindings uses nanobind and provide a comprehensive example that includes:

- Automatic dependency installation
- Library building and binding generation
- Key pair generation for testing
- Controller creation and management
- Transaction execution examples

See `examples/python/README.md` for detailed Python setup instructions.

### Swift Bindings

The Swift bindings wrap the C API to provide a native Swift interface that includes:

- Type-safe Swift APIs
- Native error handling with Swift errors
- Support for macOS 12+ and iOS 15+
- Swift Package Manager integration
- Automatic memory management

See `bindings/swift/README.md` for detailed Swift setup instructions.

## Controller flow use case

Create a controller from a backend using a starknet signer. Abstract the web3 experience to your users until you've reached the right place in your funnel, then you can ask them to take ownership of their controller.

## Future improvements

- JS/TS bindings generation: as discussed with @glihm, the optimal way of doing things would be to shift the `controller-rs` `account-wasm` part to this repo. We could then generate the wasm directly from here and keep one single interface for all bindings for the controller. However, building the wasm in here with Diplomat requires that the account-sdk be rid of all the wasm-bindgen dependencies, as the build fails with them.

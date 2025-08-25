# Controller SDK C/Python Bindings

This project provides C and Python bindings for the Controller SDK using Diplomat.

## Quick Start

### Build the library and generate bindings

```bash
./scripts/build.sh
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

## Examples

- **C Example**: `examples/test_controller.c` - Basic C usage demonstration
- **Python Example**: `examples/python/` - Complete Python example with setup automation

## Configuration

### Change binding target language

In [generator/main.rs](./crates/generator/src/main.rs) change the target-language from `py-nanobind` to `c` or vice-versa.

### Python Bindings

The Python bindings use nanobind and provide a comprehensive example that includes:
- Automatic dependency installation
- Library building and binding generation
- Key pair generation for testing
- Controller creation and management
- Transaction execution examples

See `examples/python/README.md` for detailed Python setup instructions.
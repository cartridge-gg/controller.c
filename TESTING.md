# Testing Guide

This guide covers testing strategies for the Controller SDK bindings across C, Python, and Swift.

## Quick Start

### Run All Tests Locally
```bash
./test.sh all
```

### Run Specific Language Tests
```bash
./test.sh c        # C tests only
./test.sh python   # Python tests only
./test.sh swift    # Swift tests only
```

### Verbose Mode
```bash
./test.sh swift true  # Run with verbose output
```

### With Coverage
```bash
./test.sh all --coverage
```

## Test Structure

### Swift Tests

Located in `bindings/swift/ControllerSDK/Tests/`:

- **Unit Tests** (`ControllerTests.swift`, `SessionAccountTests.swift`)
  - Type conversions
  - Error handling
  - Memory management
  - Performance benchmarks

- **Integration Tests** (Enable with `RUN_INTEGRATION_TESTS=true`)
  - Controller initialization
  - Session management
  - Transaction execution

- **Mock Data** (`Mocks/MockData.swift`)
  - Valid test data fixtures
  - Invalid data for error testing
  - Reusable test utilities

### Python Tests

Located in `examples/python/`:

- Basic controller operations
- Session account management
- Transaction handling

### C Tests

Located in `examples/`:

- `test_controller.c` - Controller operations
- `test_session_account.c` - Session flow

## Continuous Integration

GitHub Actions runs tests automatically on:
- Push to `main` or `develop`
- Pull requests to `main`

### CI Matrix

| Language | Platforms | Versions |
|----------|-----------|----------|
| C | Ubuntu | Latest |
| Python | Ubuntu | 3.9, 3.10, 3.11 |
| Swift | macOS | 5.9, 5.10 |
| Swift | Ubuntu | 5.9 (Docker) |

### CI Jobs

1. **test-c** - Build and test C bindings
2. **test-python** - Test Python across multiple versions
3. **test-swift** - Test Swift on macOS
4. **test-swift-linux** - Test Swift on Linux
5. **lint** - Format and lint checks
6. **docs** - Build documentation

## Running Tests in CI

Tests run automatically via GitHub Actions. See `.github/workflows/ci.yml`.

### Manual Workflow Trigger
```bash
# Using GitHub CLI
gh workflow run ci.yml
```

## Test Categories

### 1. Unit Tests
Fast, isolated tests for individual components:
- Type conversions
- Data structures
- Error types
- Helper functions

### 2. Integration Tests
Tests requiring external resources:
- RPC connections
- File system operations
- Cross-language boundaries

Enable with: `export RUN_INTEGRATION_TESTS=true`

### 3. Performance Tests
Benchmark critical operations:
```swift
func testTypeConversionPerformance() {
    measure {
        // Performance-critical code
    }
}
```

### 4. Memory Tests
Verify proper memory management:
- Reference counting
- Deallocation
- No memory leaks

## Mock Data

Use provided mock data for consistent testing:

```swift
// Swift
let call = MockData.createTestCall()
let owner = MockData.createTestOwner()
```

## Debugging Tests

### Swift Debugging
```bash
# Run specific test
swift test --filter ControllerTests.testOwnerCreation

# Enable verbose output
swift test --verbose

# Generate Xcode project for debugging
swift package generate-xcodeproj
open ControllerSDK.xcodeproj
```

### Python Debugging
```python
# Add breakpoints
import pdb; pdb.set_trace()

# Run with pytest for better output
pytest test_controller.py -v
```

### C Debugging
```bash
# Compile with debug symbols
gcc -g examples/test_controller.c -L./target/debug -lcontroller_c

# Run with debugger
lldb ./a.out
```

## Test Coverage

### Swift Coverage
```bash
cd bindings/swift/ControllerSDK
swift test --enable-code-coverage
xcrun llvm-cov report \
    .build/debug/ControllerSDKPackageTests.xctest/Contents/MacOS/ControllerSDKPackageTests \
    -instr-profile .build/debug/codecov/default.profdata
```

### Python Coverage
```bash
cd examples/python
pip install coverage
coverage run test_controller.py
coverage report
coverage html  # Generate HTML report
```

## Best Practices

### 1. Test Isolation
- Each test should be independent
- Clean up resources after tests
- Use fresh test data

### 2. Test Naming
- Descriptive test names
- Follow pattern: `test_<component>_<scenario>_<expected_result>`

### 3. Assertions
- Use specific assertions
- Include helpful error messages
- Test both success and failure paths

### 4. Performance
- Keep unit tests fast (<100ms)
- Use `XCTSkip` for slow integration tests
- Run performance tests separately

### 5. Mocking
- Use provided mock data
- Avoid external dependencies in unit tests
- Mock network calls and file I/O

## Troubleshooting

### Common Issues

#### Swift: "Module not found"
```bash
# Rebuild the C library
./scripts/build.sh c

# Copy headers
cp bindings/c/*.h bindings/swift/ControllerSDK/Sources/CControllerBridge/include/
```

#### Python: "Library not loaded"
```bash
# Set library path
export DYLD_LIBRARY_PATH=./target/release:$DYLD_LIBRARY_PATH
```

#### C: "Undefined symbols"
```bash
# Ensure library is built
cargo build --release --package controller-c
```

### Environment Variables

- `RUN_INTEGRATION_TESTS=true` - Enable integration tests
- `DYLD_LIBRARY_PATH` - Library search path (macOS)
- `LD_LIBRARY_PATH` - Library search path (Linux)

## Adding New Tests

### Swift Test Template
```swift
func testNewFeature() throws {
    // Arrange
    let testData = MockData.createTestData()

    // Act
    let result = try performOperation(testData)

    // Assert
    XCTAssertEqual(result, expectedValue)
}
```

### Python Test Template
```python
def test_new_feature():
    # Arrange
    test_data = create_test_data()

    # Act
    result = perform_operation(test_data)

    # Assert
    assert result == expected_value
```

## Contributing

1. Write tests for new features
2. Ensure all tests pass locally
3. Update test documentation
4. CI must pass before merging
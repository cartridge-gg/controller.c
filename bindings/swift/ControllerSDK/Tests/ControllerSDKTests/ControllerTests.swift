import XCTest
@testable import ControllerSDK

final class ControllerTests: XCTestCase {

    // MARK: - Test Configuration

    struct TestConfig {
        static let appId = "test_app"
        static let username = "test_user"
        static let classHash = "0x1234567890abcdef"
        static let rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia"
        static let chainId = "0x534e5f474f45524c49"
        static let testPrivateKey = "0x0123456789abcdef0123456789abcdef"
    }

    // MARK: - Type Tests

    func testOwnerCreation() {
        let owner = Owner(type: .starknet, privateKey: TestConfig.testPrivateKey)
        XCTAssertEqual(owner.type, .starknet)
        XCTAssertEqual(owner.privateKey, TestConfig.testPrivateKey)
    }

    func testOwnerWithoutPrivateKey() {
        let owner = Owner(type: .ethereum, privateKey: nil)
        XCTAssertEqual(owner.type, .ethereum)
        XCTAssertNil(owner.privateKey)
    }

    func testCallCreation() {
        let call = Call(
            contractAddress: "0xcontract",
            selector: "transfer",
            calldata: ["0xrecipient", "1000", "0"]
        )

        XCTAssertEqual(call.contractAddress, "0xcontract")
        XCTAssertEqual(call.selector, "transfer")
        XCTAssertEqual(call.calldata.count, 3)
    }

    func testSignerTypes() {
        XCTAssertEqual(SignerType.starknet.toCSignerType(), SignerType_Starknet)
        XCTAssertEqual(SignerType.ethereum.toCSignerType(), SignerType_Ethereum)
        XCTAssertEqual(SignerType.webauthn.toCSignerType(), SignerType_Webauthn)
    }

    // MARK: - Controller Error Tests

    func testControllerErrorMessages() {
        let errors: [ControllerError] = [
            .signerError("test signer error"),
            .providerError("test provider error"),
            .payloadError("test payload error"),
            .controllerNotDeployed,
            .invalidOwner("test owner"),
            .badRequest("test request"),
            .invalidCredentials("test creds"),
            .sessionAlreadyRegistered("test session"),
            .slotNotDeployed
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    // MARK: - Integration Tests (Requires Mock/Test Environment)

    func testControllerInitialization() throws {
        // This test requires a proper test environment or mocking
        // For CI, we can use environment variables to control test behavior

        guard ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"] == "true" else {
            throw XCTSkip("Integration tests disabled. Set RUN_INTEGRATION_TESTS=true to run.")
        }

        let owner = Owner(type: .starknet, privateKey: TestConfig.testPrivateKey)

        XCTAssertThrowsError(try Controller(
            appId: TestConfig.appId,
            username: TestConfig.username,
            classHash: TestConfig.classHash,
            rpcUrl: TestConfig.rpcUrl,
            owner: owner,
            address: "0x0",
            chainId: TestConfig.chainId
        )) { error in
            // Expect an error since we don't have a real private key
            XCTAssertTrue(error is ControllerError)
        }
    }

    func testControllerFromStorage() throws {
        guard ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"] == "true" else {
            throw XCTSkip("Integration tests disabled")
        }

        XCTAssertThrowsError(try Controller.fromStorage(appId: "nonexistent_app")) { error in
            if let controllerError = error as? ControllerError {
                switch controllerError {
                case .storageError:
                    // Expected error
                    break
                default:
                    XCTFail("Unexpected error type: \(controllerError)")
                }
            }
        }
    }

    // MARK: - String Extension Tests

    func testDiplomatStringView() {
        let testString = "Hello, World!"
        let view = testString.withDiplomatStringView()

        XCTAssertNotNil(view.data)
        XCTAssertEqual(view.len, testString.count)
    }

    // MARK: - Memory Management Tests

    func testCallListCreationAndDestruction() {
        let calls = [
            Call(contractAddress: "0x1", selector: "method1", calldata: ["data1"]),
            Call(contractAddress: "0x2", selector: "method2", calldata: ["data2", "data3"])
        ]

        let callList = calls.toDiplomatCallList()
        XCTAssertNotNil(callList.cCallList)

        // Destruction is handled by defer in actual usage
        callList.destroy()
    }

    // MARK: - Performance Tests

    func testTypeConversionPerformance() {
        measure {
            for _ in 0..<1000 {
                let owner = Owner(type: .starknet, privateKey: TestConfig.testPrivateKey)
                _ = owner.toDiplomatOwner()
            }
        }
    }

    func testCallCreationPerformance() {
        measure {
            for _ in 0..<1000 {
                let call = Call(
                    contractAddress: "0xcontract",
                    selector: "method",
                    calldata: Array(repeating: "0xdata", count: 10)
                )
                _ = call.toDiplomatCall()
            }
        }
    }
}
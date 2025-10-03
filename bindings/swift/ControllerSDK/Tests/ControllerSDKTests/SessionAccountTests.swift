import XCTest
@testable import ControllerSDK

final class SessionAccountTests: XCTestCase {

    struct TestConfig {
        static let rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia"
        static let chainId = "0x534e5f474f45524c49"
        static let privateKey = "0x0123456789abcdef"
        static let address = "0xTestAddress"
        static let username = "session_user"
        static let sessionAuth = "test_session_auth"
        static let sessionKeyPair = "test_key_pair"
    }

    func testSignerCreation() {
        let signer = Signer(type: .starknet, privateKey: TestConfig.privateKey)

        XCTAssertEqual(signer.type, .starknet)
        XCTAssertEqual(signer.privateKey, TestConfig.privateKey)
    }

    func testSignerToDiplomatConversion() {
        let signer = Signer(type: .ethereum, privateKey: TestConfig.privateKey)
        let diplomatSigner = signer.toDiplomatSigner()

        XCTAssertEqual(diplomatSigner.signer_type, SignerType_Ethereum)
    }

    func testSessionAccountInitialization() throws {
        guard ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"] == "true" else {
            throw XCTSkip("Integration tests disabled")
        }

        let signer = Signer(type: .starknet, privateKey: TestConfig.privateKey)

        XCTAssertThrowsError(try SessionAccount(
            rpcUrl: TestConfig.rpcUrl,
            signer: signer,
            address: TestConfig.address,
            username: TestConfig.username,
            chainId: TestConfig.chainId,
            sessionAuthorization: TestConfig.sessionAuth,
            sessionKeyPair: TestConfig.sessionKeyPair
        )) { error in
            // Expect an error with test data
            XCTAssertTrue(error is ControllerError)
        }
    }

    func testSessionAccountFromStorage() throws {
        guard ProcessInfo.processInfo.environment["RUN_INTEGRATION_TESTS"] == "true" else {
            throw XCTSkip("Integration tests disabled")
        }

        XCTAssertThrowsError(try SessionAccount.fromStorage(
            appId: "test_app",
            username: "test_user",
            privateKey: TestConfig.privateKey
        )) { error in
            // Expect storage error for non-existent data
            XCTAssertTrue(error is ControllerError)
        }
    }

    func testMultipleSignerTypes() {
        let signerTypes: [(SignerType, SignerType)] = [
            (.starknet, SignerType_Starknet),
            (.ethereum, SignerType_Ethereum),
            (.webauthn, SignerType_Webauthn)
        ]

        for (swiftType, cType) in signerTypes {
            let signer = Signer(type: swiftType, privateKey: "0xkey")
            let diplomatSigner = signer.toDiplomatSigner()
            XCTAssertEqual(diplomatSigner.signer_type, cType)
        }
    }

    func testCallExecutionDataStructure() {
        let calls = [
            Call(contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                 selector: "transfer",
                 calldata: ["0xrecipient", "1000000000000000", "0"]),
            Call(contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                 selector: "approve",
                 calldata: ["0xspender", "5000000000000000", "0"])
        ]

        let callList = calls.toDiplomatCallList()
        XCTAssertNotNil(callList.cCallList)

        // Clean up
        callList.destroy()
    }
}
import Foundation
@testable import ControllerSDK

/// Mock data for testing
struct MockData {

    // MARK: - Valid Test Data

    struct Valid {
        static let appId = "test_app_id"
        static let username = "test_user_123"
        static let classHash = "0x029927c8af6bccf3174e2ab951e7aa1290cad87c7c75c04751d243fb0c2e9833"
        static let rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia"
        static let chainId = "0x534e5f474f45524c49" // SN_SEPOLIA

        // Valid Starknet private key format (64 hex chars)
        static let privateKey = "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
        static let address = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"

        static let sessionAuth = """
        {
            "session_id": "test_session_123",
            "expires_at": 1735948800,
            "policies": []
        }
        """

        static let sessionKeyPair = """
        {
            "public_key": "0xpublic_key_test",
            "private_key": "0xprivate_key_test"
        }
        """
    }

    // MARK: - Invalid Test Data

    struct Invalid {
        static let emptyString = ""
        static let invalidHex = "0xGGGGGG"
        static let shortPrivateKey = "0x123"
        static let malformedJson = "{invalid json}"
        static let invalidUrl = "not_a_url"
    }

    // MARK: - Test Calls

    static func createTestCall() -> Call {
        return Call(
            contractAddress: Valid.address,
            selector: "transfer",
            calldata: [
                "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
                "1000000000000000",
                "0"
            ]
        )
    }

    static func createMultipleCalls() -> [Call] {
        return [
            Call(contractAddress: Valid.address,
                 selector: "transfer",
                 calldata: ["0xrecipient1", "1000", "0"]),
            Call(contractAddress: Valid.address,
                 selector: "approve",
                 calldata: ["0xspender", "5000", "0"]),
            Call(contractAddress: Valid.address,
                 selector: "mint",
                 calldata: ["0xto", "10000", "0"])
        ]
    }

    // MARK: - Test Owners

    static func createTestOwner() -> Owner {
        return Owner(type: .starknet, privateKey: Valid.privateKey)
    }

    static func createTestSigner() -> Signer {
        return Signer(type: .starknet, privateKey: Valid.privateKey)
    }
}
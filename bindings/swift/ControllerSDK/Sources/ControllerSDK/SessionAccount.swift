import Foundation
import CControllerBridge

/// Swift wrapper for SessionAccount
public class SessionAccount {
    private let cSessionAccount: OpaquePointer

    /// Creates a new SessionAccount
    /// - Parameters:
    ///   - rpcUrl: The RPC URL
    ///   - signer: The signer to use
    ///   - address: The account address
    ///   - username: The username
    ///   - chainId: The chain ID
    ///   - sessionAuthorization: The session authorization data
    ///   - sessionKeyPair: The session key pair
    /// - Throws: ControllerError if creation fails
    public init(
        rpcUrl: String,
        signer: Signer,
        address: String,
        username: String,
        chainId: String,
        sessionAuthorization: String,
        sessionKeyPair: String
    ) throws {
        let rpcUrlView = rpcUrl.withDiplomatStringView()
        let addressView = address.withDiplomatStringView()
        let usernameView = username.withDiplomatStringView()
        let chainIdView = chainId.withDiplomatStringView()
        let sessionAuthView = sessionAuthorization.withDiplomatStringView()
        let sessionKeyView = sessionKeyPair.withDiplomatStringView()

        var diplomatSigner = signer.toDiplomatSigner()
        let result = withUnsafePointer(to: &diplomatSigner) { signerPtr in
            SessionAccount_new(
                rpcUrlView,
                signerPtr,
                addressView,
                usernameView,
                chainIdView,
                sessionAuthView,
                sessionKeyView
            )
        }

        if result.is_ok {
            self.cSessionAccount = OpaquePointer(result.ok)
        } else {
            throw ControllerError.fromCError(result.err)
        }
    }

    /// Creates a SessionAccount from storage
    /// - Parameters:
    ///   - appId: The application ID
    ///   - username: The username
    ///   - privateKey: The private key
    /// - Throws: ControllerError if loading fails
    public static func fromStorage(
        appId: String,
        username: String,
        privateKey: String
    ) throws -> SessionAccount {
        let appIdView = appId.withDiplomatStringView()
        let usernameView = username.withDiplomatStringView()
        let privateKeyView = privateKey.withDiplomatStringView()

        let result = SessionAccount_from_storage(appIdView, usernameView, privateKeyView)

        if result.is_ok {
            let sessionAccount = SessionAccount()
            sessionAccount.cSessionAccount = OpaquePointer(result.ok)
            return sessionAccount
        } else {
            throw ControllerError.fromCError(result.err)
        }
    }

    private init() {
        self.cSessionAccount = OpaquePointer(bitPattern: 0)!
    }

    /// Gets the session account's address
    /// - Returns: The address string
    /// - Throws: ControllerError if getting address fails
    public var address: String {
        get throws {
            var buffer = [UInt8](repeating: 0, count: 256)
            let write = buffer.withDiplomatWrite()

            let result = SessionAccount_address(cSessionAccount, write)

            if result.is_ok {
                return String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""
            } else {
                throw ControllerError.fromCError(result.err)
            }
        }
    }

    /// Gets the session account's username
    /// - Returns: The username string
    /// - Throws: ControllerError if getting username fails
    public var username: String {
        get throws {
            var buffer = [UInt8](repeating: 0, count: 256)
            let write = buffer.withDiplomatWrite()

            let result = SessionAccount_username(cSessionAccount, write)

            if result.is_ok {
                return String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""
            } else {
                throw ControllerError.fromCError(result.err)
            }
        }
    }

    /// Gets the session account's chain ID
    /// - Returns: The chain ID string
    /// - Throws: ControllerError if getting chain ID fails
    public var chainId: String {
        get throws {
            var buffer = [UInt8](repeating: 0, count: 256)
            let write = buffer.withDiplomatWrite()

            let result = SessionAccount_chain_id(cSessionAccount, write)

            if result.is_ok {
                return String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""
            } else {
                throw ControllerError.fromCError(result.err)
            }
        }
    }

    /// Executes a list of calls using the session account
    /// - Parameter calls: The list of calls to execute
    /// - Returns: The execution result as a string
    /// - Throws: ControllerError if execution fails
    public func execute(calls: [Call]) throws -> String {
        let callList = calls.toDiplomatCallList()
        defer { callList.destroy() }

        var buffer = [UInt8](repeating: 0, count: 4096)
        let write = buffer.withDiplomatWrite()

        let result = SessionAccount_execute(cSessionAccount, callList.cCallList, write)

        if result.is_ok {
            return String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""
        } else {
            throw ControllerError.fromCError(result.err)
        }
    }

    deinit {
        SessionAccount_destroy(cSessionAccount)
    }
}

// MARK: - Signer

public struct Signer {
    public let type: SignerType
    public let privateKey: String

    public init(type: SignerType, privateKey: String) {
        self.type = type
        self.privateKey = privateKey
    }

    func toDiplomatSigner() -> DiplomatSigner {
        var signer = DiplomatSigner()
        signer.signer_type = type.toCSignerType()
        signer.signer = privateKey.withDiplomatStringView()
        return signer
    }
}
import Foundation
import CControllerBridge

/// Swift wrapper for the Controller C API
public class Controller {
    private let cController: OpaquePointer

    // MARK: - Initialization

    /// Creates a new Controller instance
    /// - Parameters:
    ///   - appId: The application ID
    ///   - username: The username
    ///   - classHash: The class hash
    ///   - rpcUrl: The RPC URL
    ///   - owner: The owner configuration
    ///   - address: The address
    ///   - chainId: The chain ID
    /// - Throws: ControllerError if creation fails
    public init(
        appId: String,
        username: String,
        classHash: String,
        rpcUrl: String,
        owner: Owner,
        address: String,
        chainId: String
    ) throws {
        let appIdView = appId.withDiplomatStringView()
        let usernameView = username.withDiplomatStringView()
        let classHashView = classHash.withDiplomatStringView()
        let rpcUrlView = rpcUrl.withDiplomatStringView()
        let addressView = address.withDiplomatStringView()
        let chainIdView = chainId.withDiplomatStringView()

        var diplomatOwner = owner.toDiplomatOwner()
        let result = withUnsafePointer(to: &diplomatOwner) { ownerPtr in
            Controller_new(
                appIdView,
                usernameView,
                classHashView,
                rpcUrlView,
                ownerPtr,
                addressView,
                chainIdView
            )
        }

        if result.is_ok {
            self.cController = OpaquePointer(result.ok)
        } else {
            throw ControllerError.fromCError(result.err)
        }
    }

    /// Creates a new headless Controller instance
    /// - Parameters:
    ///   - appId: The application ID
    ///   - username: The username
    ///   - classHash: The class hash
    ///   - rpcUrl: The RPC URL
    ///   - owner: The owner configuration
    ///   - chainId: The chain ID
    /// - Throws: ControllerError if creation fails
    public static func headless(
        appId: String,
        username: String,
        classHash: String,
        rpcUrl: String,
        owner: Owner,
        chainId: String
    ) throws -> Controller {
        let appIdView = appId.withDiplomatStringView()
        let usernameView = username.withDiplomatStringView()
        let classHashView = classHash.withDiplomatStringView()
        let rpcUrlView = rpcUrl.withDiplomatStringView()
        let chainIdView = chainId.withDiplomatStringView()

        var diplomatOwner = owner.toDiplomatOwner()
        let result = withUnsafePointer(to: &diplomatOwner) { ownerPtr in
            Controller_new_headless(
                appIdView,
                usernameView,
                classHashView,
                rpcUrlView,
                ownerPtr,
                chainIdView
            )
        }

        if result.is_ok {
            let controller = Controller()
            controller.cController = OpaquePointer(result.ok)
            return controller
        } else {
            throw ControllerError.fromCError(result.err)
        }
    }

    /// Loads a Controller from storage
    /// - Parameter appId: The application ID
    /// - Returns: The loaded Controller
    /// - Throws: ControllerError if loading fails
    public static func fromStorage(appId: String) throws -> Controller {
        let appIdView = appId.withDiplomatStringView()
        let result = Controller_from_storage(appIdView)

        if result.is_ok {
            let controller = Controller()
            controller.cController = OpaquePointer(result.ok)
            return controller
        } else {
            throw ControllerError.fromCError(result.err)
        }
    }

    private init() {
        self.cController = OpaquePointer(bitPattern: 0)!
    }

    // MARK: - Methods

    /// Signs up the controller
    /// - Parameters:
    ///   - signerType: The type of signer to use
    ///   - sessionExpiration: Optional session expiration time
    ///   - cartridgeApiUrl: Optional Cartridge API URL
    /// - Throws: ControllerError if signup fails
    public func signup(
        signerType: SignerType,
        sessionExpiration: UInt64? = nil,
        cartridgeApiUrl: String? = nil
    ) throws {
        var optionExpiration = OptionU64()
        if let expiration = sessionExpiration {
            optionExpiration.tag = 1
            optionExpiration.option = expiration
        } else {
            optionExpiration.tag = 0
        }

        var optionApiUrl = OptionStringView()
        if let apiUrl = cartridgeApiUrl {
            let apiUrlView = apiUrl.withDiplomatStringView()
            optionApiUrl.tag = 1
            optionApiUrl.option = apiUrlView
        } else {
            optionApiUrl.tag = 0
        }

        let result = Controller_signup(
            cController,
            signerType.toCSignerType(),
            optionExpiration,
            optionApiUrl
        )

        if !result.is_ok {
            throw ControllerError.fromCError(result.err)
        }
    }

    /// Gets the controller's address
    /// - Returns: The address string
    /// - Throws: ControllerError if getting address fails
    public var address: String {
        get throws {
            var buffer = [UInt8](repeating: 0, count: 256)
            let write = buffer.withDiplomatWrite()

            let result = Controller_address(cController, write)

            if result.is_ok {
                return String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""
            } else {
                throw ControllerError.fromCError(result.err)
            }
        }
    }

    /// Gets the controller's username
    /// - Returns: The username string
    /// - Throws: ControllerError if getting username fails
    public var username: String {
        get throws {
            var buffer = [UInt8](repeating: 0, count: 256)
            let write = buffer.withDiplomatWrite()

            let result = Controller_username(cController, write)

            if result.is_ok {
                return String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""
            } else {
                throw ControllerError.fromCError(result.err)
            }
        }
    }

    /// Gets the controller's app ID
    /// - Returns: The app ID string
    /// - Throws: ControllerError if getting app ID fails
    public var appId: String {
        get throws {
            var buffer = [UInt8](repeating: 0, count: 256)
            let write = buffer.withDiplomatWrite()

            let result = Controller_app_id(cController, write)

            if result.is_ok {
                return String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""
            } else {
                throw ControllerError.fromCError(result.err)
            }
        }
    }

    /// Gets the controller's chain ID
    /// - Returns: The chain ID string
    /// - Throws: ControllerError if getting chain ID fails
    public var chainId: String {
        get throws {
            var buffer = [UInt8](repeating: 0, count: 256)
            let write = buffer.withDiplomatWrite()

            let result = Controller_chain_id(cController, write)

            if result.is_ok {
                return String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""
            } else {
                throw ControllerError.fromCError(result.err)
            }
        }
    }

    /// Disconnects the controller
    /// - Throws: ControllerError if disconnection fails
    public func disconnect() throws {
        let result = Controller_disconnect(cController)

        if !result.is_ok {
            throw ControllerError.fromCError(result.err)
        }
    }

    /// Executes a list of calls
    /// - Parameter calls: The list of calls to execute
    /// - Returns: The execution result as a string
    /// - Throws: ControllerError if execution fails
    public func execute(calls: [Call]) throws -> String {
        let callList = calls.toDiplomatCallList()
        defer { callList.destroy() }

        var buffer = [UInt8](repeating: 0, count: 4096)
        let write = buffer.withDiplomatWrite()

        let result = Controller_execute(cController, callList.cCallList, write)

        if result.is_ok {
            return String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""
        } else {
            throw ControllerError.fromCError(result.err)
        }
    }

    deinit {
        Controller_destroy(cController)
    }
}
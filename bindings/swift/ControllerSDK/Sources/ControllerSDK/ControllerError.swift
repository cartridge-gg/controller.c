import Foundation
import CControllerBridge

/// Swift representation of Controller errors
public enum ControllerError: Error, LocalizedError {
    case signerError(String)
    case providerError(String)
    case payloadError(String)
    case accountFactoryError(String)
    case controllerNotDeployed
    case invalidOwner(String)
    case badRequest(String)
    case invalidCredentials(String)
    case sessionAlreadyRegistered(String)
    case slotNotDeployed
    case topicParseError(String)
    case invalidMessageError(String)
    case deviceParseError(String)
    case sessionParseError(String)
    case proofParseError(String)
    case sessionMetadataParseError(String)
    case typedDataParseError(String)
    case notImplemented(String)
    case unautorized(String)
    case unsupportedChain(String)
    case scriptError(String)
    case storageError(String)
    case noneError
    case executeError(String)
    case unknown(String)

    static func fromCError(_ cError: UnsafeMutablePointer<ControllerError>?) -> ControllerError {
        guard let error = cError else {
            return .unknown("Null error pointer")
        }

        defer { ControllerError_destroy(error) }

        // Get error message
        var buffer = [UInt8](repeating: 0, count: 1024)
        let write = buffer.withDiplomatWrite()
        ControllerError_to_string(error, write)
        let message = String(bytes: buffer.prefix(write.pointee.len), encoding: .utf8) ?? ""

        // Map error types based on the C error structure
        // This is a simplified mapping - you may need to enhance based on actual error types
        if message.contains("SignerError") {
            return .signerError(message)
        } else if message.contains("ProviderError") {
            return .providerError(message)
        } else if message.contains("PayloadError") {
            return .payloadError(message)
        } else if message.contains("AccountFactoryError") {
            return .accountFactoryError(message)
        } else if message.contains("ControllerNotDeployed") {
            return .controllerNotDeployed
        } else if message.contains("InvalidOwner") {
            return .invalidOwner(message)
        } else if message.contains("BadRequest") {
            return .badRequest(message)
        } else if message.contains("InvalidCredentials") {
            return .invalidCredentials(message)
        } else if message.contains("SessionAlreadyRegistered") {
            return .sessionAlreadyRegistered(message)
        } else if message.contains("SlotNotDeployed") {
            return .slotNotDeployed
        } else if message.contains("TopicParseError") {
            return .topicParseError(message)
        } else if message.contains("InvalidMessageError") {
            return .invalidMessageError(message)
        } else if message.contains("DeviceParseError") {
            return .deviceParseError(message)
        } else if message.contains("SessionParseError") {
            return .sessionParseError(message)
        } else if message.contains("ProofParseError") {
            return .proofParseError(message)
        } else if message.contains("SessionMetadataParseError") {
            return .sessionMetadataParseError(message)
        } else if message.contains("TypedDataParseError") {
            return .typedDataParseError(message)
        } else if message.contains("NotImplemented") {
            return .notImplemented(message)
        } else if message.contains("Unauthorized") {
            return .unautorized(message)
        } else if message.contains("UnsupportedChain") {
            return .unsupportedChain(message)
        } else if message.contains("ScriptError") {
            return .scriptError(message)
        } else if message.contains("StorageError") {
            return .storageError(message)
        } else if message.contains("NoneError") {
            return .noneError
        } else if message.contains("ExecuteError") {
            return .executeError(message)
        } else {
            return .unknown(message)
        }
    }

    public var errorDescription: String? {
        switch self {
        case .signerError(let msg):
            return "Signer Error: \(msg)"
        case .providerError(let msg):
            return "Provider Error: \(msg)"
        case .payloadError(let msg):
            return "Payload Error: \(msg)"
        case .accountFactoryError(let msg):
            return "Account Factory Error: \(msg)"
        case .controllerNotDeployed:
            return "Controller Not Deployed"
        case .invalidOwner(let msg):
            return "Invalid Owner: \(msg)"
        case .badRequest(let msg):
            return "Bad Request: \(msg)"
        case .invalidCredentials(let msg):
            return "Invalid Credentials: \(msg)"
        case .sessionAlreadyRegistered(let msg):
            return "Session Already Registered: \(msg)"
        case .slotNotDeployed:
            return "Slot Not Deployed"
        case .topicParseError(let msg):
            return "Topic Parse Error: \(msg)"
        case .invalidMessageError(let msg):
            return "Invalid Message Error: \(msg)"
        case .deviceParseError(let msg):
            return "Device Parse Error: \(msg)"
        case .sessionParseError(let msg):
            return "Session Parse Error: \(msg)"
        case .proofParseError(let msg):
            return "Proof Parse Error: \(msg)"
        case .sessionMetadataParseError(let msg):
            return "Session Metadata Parse Error: \(msg)"
        case .typedDataParseError(let msg):
            return "Typed Data Parse Error: \(msg)"
        case .notImplemented(let msg):
            return "Not Implemented: \(msg)"
        case .unautorized(let msg):
            return "Unauthorized: \(msg)"
        case .unsupportedChain(let msg):
            return "Unsupported Chain: \(msg)"
        case .scriptError(let msg):
            return "Script Error: \(msg)"
        case .storageError(let msg):
            return "Storage Error: \(msg)"
        case .noneError:
            return "None Error"
        case .executeError(let msg):
            return "Execute Error: \(msg)"
        case .unknown(let msg):
            return "Unknown Error: \(msg)"
        }
    }
}
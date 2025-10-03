import Foundation
import CControllerBridge

// MARK: - Owner Types

public enum OwnerType {
    case starknet
    case ethereum
}

public struct Owner {
    public let type: OwnerType
    public let privateKey: String?

    public init(type: OwnerType, privateKey: String? = nil) {
        self.type = type
        self.privateKey = privateKey
    }

    func toDiplomatOwner() -> DiplomatOwner {
        var owner = DiplomatOwner()
        owner.tag = type == .starknet ? OwnerType_Starknet : OwnerType_Ethereum

        if let pk = privateKey {
            let pkView = pk.withDiplomatStringView()
            owner.option = pkView
        } else {
            owner.option = DiplomatStringView(data: nil, len: 0)
        }

        return owner
    }
}

// MARK: - Signer Types

public enum SignerType {
    case starknet
    case ethereum
    case webauthn

    func toCSignerType() -> SignerType {
        switch self {
        case .starknet:
            return SignerType_Starknet
        case .ethereum:
            return SignerType_Ethereum
        case .webauthn:
            return SignerType_Webauthn
        }
    }
}

// MARK: - Call Types

public struct Call {
    public let contractAddress: String
    public let selector: String
    public let calldata: [String]

    public init(contractAddress: String, selector: String, calldata: [String]) {
        self.contractAddress = contractAddress
        self.selector = selector
        self.calldata = calldata
    }

    func toDiplomatCall() -> DiplomatCall {
        var call = DiplomatCall()
        call.contract_address = contractAddress.withDiplomatStringView()
        call.selector = selector.withDiplomatStringView()

        // Convert calldata array to DiplomatStringSlice
        let calldataViews = calldata.map { $0.withDiplomatStringView() }
        call.calldata = DiplomatStringSlice(
            data: calldataViews.withUnsafeBufferPointer { $0.baseAddress },
            len: calldataViews.count
        )

        return call
    }
}

// MARK: - Call List

class CallList {
    let cCallList: OpaquePointer

    init(calls: [Call]) {
        let diplomatCalls = calls.map { $0.toDiplomatCall() }
        let slice = DiplomatCallSlice(
            data: diplomatCalls.withUnsafeBufferPointer { $0.baseAddress },
            len: diplomatCalls.count
        )
        self.cCallList = OpaquePointer(DiplomatCallList_new(slice))
    }

    func destroy() {
        DiplomatCallList_destroy(cCallList)
    }
}

extension Array where Element == Call {
    func toDiplomatCallList() -> CallList {
        return CallList(calls: self)
    }
}

// MARK: - String Extensions

extension String {
    func withDiplomatStringView() -> DiplomatStringView {
        return self.withCString { cStr in
            DiplomatStringView(data: cStr, len: strlen(cStr))
        }
    }
}

// MARK: - Buffer Extensions

extension Array where Element == UInt8 {
    mutating func withDiplomatWrite() -> UnsafeMutablePointer<DiplomatWrite> {
        self.withUnsafeMutableBufferPointer { buffer in
            let write = UnsafeMutablePointer<DiplomatWrite>.allocate(capacity: 1)
            write.pointee.data = buffer.baseAddress
            write.pointee.len = 0
            write.pointee.cap = buffer.count
            return write
        }
    }
}
//
//  ArgumentType.swift
//  Smart argument handling for Starknet transactions
//

import Foundation

enum ArgumentType: String, CaseIterable, Identifiable {
    case felt = "Felt"
    case u256 = "U256"
    case address = "Address"
    case string = "String"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .felt:
            return "Single field element (0x...)"
        case .u256:
            return "256-bit number (splits into low/high)"
        case .address:
            return "Starknet address (0x...)"
        case .string:
            return "UTF-8 string (auto-encoded)"
        }
    }
    
    var placeholder: String {
        switch self {
        case .felt, .address:
            return "0x..."
        case .u256:
            return "0x1000 or 1000"
        case .string:
            return "Hello World"
        }
    }
}

struct TransactionArgument: Identifiable {
    let id = UUID()
    var type: ArgumentType = .felt
    var value: String = ""
    
    // Convert to calldata array
    func toCalldata() -> [String] {
        switch type {
        case .felt, .address:
            // Single felt - ensure 0x prefix
            let cleaned = value.trimmingCharacters(in: .whitespaces)
            if cleaned.hasPrefix("0x") {
                return [cleaned]
            } else if cleaned.isEmpty {
                return ["0x0"]
            } else {
                return ["0x\(cleaned)"]
            }
            
        case .u256:
            // U256 splits into low and high felts
            return splitU256(value)
            
        case .string:
            // Convert string to felt array
            return stringToFelts(value)
        }
    }
    
    private func splitU256(_ value: String) -> [String] {
        let cleaned = value.trimmingCharacters(in: .whitespaces)
        
        // Try to parse as hex or decimal
        let numberString: String
        if cleaned.hasPrefix("0x") {
            numberString = String(cleaned.dropFirst(2))
        } else if let decimal = UInt64(cleaned) {
            numberString = String(decimal, radix: 16)
        } else {
            // Invalid, return zeros
            return ["0x0", "0x0"]
        }
        
        // For simplicity, if the number fits in 64 bits, put it in low, high is 0
        // For larger numbers, we'd need proper 256-bit handling
        if numberString.count <= 16 {
            return ["0x\(numberString)", "0x0"]
        } else {
            // Split into low (last 32 hex chars) and high (rest)
            let lowStart = numberString.index(numberString.endIndex, offsetBy: -min(32, numberString.count))
            let low = String(numberString[lowStart...])
            let high = String(numberString[..<lowStart])
            return ["0x\(low)", high.isEmpty ? "0x0" : "0x\(high)"]
        }
    }
    
    private func stringToFelts(_ value: String) -> [String] {
        // Convert string to felt (simplified - just length + ASCII values)
        let bytes = Array(value.utf8)
        
        if bytes.isEmpty {
            return ["0x0"]
        }
        
        // Pack bytes into felts (31 bytes per felt max for Cairo short strings)
        var felts: [String] = []
        let chunkSize = 31
        
        for chunk in stride(from: 0, to: bytes.count, by: chunkSize) {
            let end = min(chunk + chunkSize, bytes.count)
            let chunkBytes = bytes[chunk..<end]
            
            // Convert bytes to hex string
            let hex = chunkBytes.map { String(format: "%02x", $0) }.joined()
            felts.append("0x\(hex)")
        }
        
        return felts
    }
}



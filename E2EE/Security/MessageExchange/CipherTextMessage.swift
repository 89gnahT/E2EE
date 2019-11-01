//
//  CipherTextMessage.swift
//  E2EE
//
//  Created by CPU11899 on 10/31/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public enum CipherTextType: UInt8, CustomStringConvertible {
    case signal = 2
    case preKey = 3
    case senderKey = 4
    case senderKeyDistribution = 5
    
    public var description: String {
        switch self {
        case .signal:
            return "SignalMessage"
        case .preKey:
            return "PreKeyMessage"
        case .senderKey:
            return "SenderKeyMessage"
        case .senderKeyDistribution:
            return "SenderKeyDistributionMessage"
        }
    }
    
    public var data: Data {
        return Data([self.rawValue])
    }
    
    public init?(from data: Data) {
        guard data.count > 0 else {
            return nil
        }
        self.init(rawValue: data[0])
    }
}

public struct CipherTextMessage {
    public var type: CipherTextType
    public var data: Data
    
    public init(type: CipherTextType, data: Data) {
        self.type = type
        self.data = data
    }
}

extension CipherTextMessage: ProtocolBufferSerializable {
    public func protoData() throws -> Data {
        return type.data + data
    }
    
    public init(from protoData: Data) throws {
        guard protoData.count > 0 else {
            throw SignalError(.invalidProtoBuf, "No data to create CipherTextMessage")
        }
        guard let byte = CipherTextType(rawValue: protoData[0]) else {
            throw SignalError(.invalidProtoBuf, "Invalid type for CipherTextMessage")
        }
        self.type = byte
        self.data = protoData.advanced(by: 1)
    }
}

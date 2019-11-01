//
//  ProtocolBufferConvertible.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 10/26/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import SwiftProtobuf

protocol ProtocolBufferConvertiable: ProtocolBufferSerializable {
    associatedtype ProtocolBufferClass: SwiftProtobuf.Message
    
    func asProtoObject() throws -> ProtocolBufferClass
    init(from protoObject: ProtocolBufferClass) throws
}

extension ProtocolBufferConvertiable {
    public func protoData() throws -> Data {
        do {
            return try asProtoObject().serializedData()
        } catch {
            throw SignalError(.invalidProtoBuf, "Serialization error: \(error)")
        }
    }
    
    public init(from protoData: Data) throws {
        let protoObject: ProtocolBufferClass
        do {
            protoObject = try ProtocolBufferClass(serializedData: protoData)
        } catch {
            throw SignalError(.invalidProtoBuf, "Desiarialization error: \(error)")
        }
        try self.init(from: protoObject)
    }
} 

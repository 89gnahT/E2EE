//
//  PreKeySignalMessage.swift
//  E2EE
//
//  Created by CPU11899 on 10/31/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct PreKeySignalMessage {
    let preKeyId: UInt32?
    let signedPreKeyId: UInt32
    let baseKey: PublicKey
    let identityKey: PublicKey
    let message: SignalMessage
    
    init(preKeyId: UInt32?, signedPreKeyId: UInt32, baseKey: PublicKey, identityKey: PublicKey, message: SignalMessage) {
        self.preKeyId = preKeyId
        self.signedPreKeyId = signedPreKeyId
        self.baseKey = baseKey
        self.identityKey = identityKey
        self.message = message
    }
    
    func baseMessage() throws -> CipherTextMessage {
        return CipherTextMessage(type: .preKey, data: try self.protoData())
    }
}

extension PreKeySignalMessage: ProtocolBufferConvertiable {
    func asProtoObject() throws -> Signal_PreKeySignalMessage {
        return try Signal_PreKeySignalMessage.with {
            if let id = self.preKeyId {
                $0.preKeyID = id
            }
            $0.signedPreKeyID = self.signedPreKeyId
            $0.baseKey = self.baseKey.data
            $0.identityKey = self.identityKey.data
            $0.message = try self.message.baseMessage().data
        }
    }
    
    init(from protoObject: Signal_PreKeySignalMessage) throws {
        guard protoObject.hasBaseKey, protoObject.hasMessage, protoObject.hasPreKeyID, protoObject.hasIdentityKey else {
            throw SignalError(.invalidProtoBuf, "Missing data in PreKeySignalMessage")
        }
        self.baseKey = try PublicKey(from: protoObject.baseKey)
        self.identityKey = try PublicKey(from: protoObject.identityKey)
        self.preKeyId = protoObject.hasPreKeyID ? protoObject.preKeyID : nil
        self.signedPreKeyId = protoObject.signedPreKeyID
        self.message = try SignalMessage(from: protoObject.message)
    }
}

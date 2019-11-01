//
//  SessionSignedPreKeyPublic.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct SessionSignedPreKeyPublic {
    public let id: UInt32
    public let key: PublicKey
    public let timestamp: UInt64
    public let signature: Data
    
    init(id: UInt32, timestamp: UInt64, key: PublicKey, signature: Data) {
        self.id = id
        self.key = key
        self.signature = signature
        self.timestamp = timestamp
    }
    
    func verify(with publicKey: PublicKey) -> Bool {
        return publicKey.verify(signature: signature, for: key.data)
    }
}

extension SessionSignedPreKeyPublic: ProtocolBufferEquivalent {
    var protoObject: Signal_SignedPreKey.PublicPart {
        return Signal_SignedPreKey.PublicPart.with {
            $0.id = id
            $0.key = self.key.data
            $0.timestamp = self.timestamp
            $0.signature = signature
        }
    }
    
    init(from protoObject: Signal_SignedPreKey.PublicPart) throws {
        guard protoObject.hasID && protoObject.hasKey && protoObject.hasSignature && protoObject.hasTimestamp else {
            throw SignalError(.invalidProtoBuf, "Invalid ProtoBuf Object")
        }
        self.id = protoObject.id
        self.key = try PublicKey(from: protoObject.key)
        self.signature = protoObject.signature
        self.timestamp = protoObject.timestamp
    }
}

extension SessionSignedPreKeyPublic: Equatable {
    static func ==(a: SessionSignedPreKeyPublic, b: SessionSignedPreKeyPublic) -> Bool {
        return a.id == b.id && a.key == b.key && a.signature == b.signature && a.timestamp == b.timestamp
    }
}

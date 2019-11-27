//
//  SessionSignedPreKey.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct SessionSignedPreKey {
    let publicKey: SessionSignedPreKeyPublic
    let privateKey: PrivateKey
    
    init(id: UInt32, timestamp: UInt64, keyPair: KeyPair, signature: Data) {
        self.publicKey = SessionSignedPreKeyPublic(id: id, timestamp: timestamp, key: keyPair.publicKey, signature: signature)
        self.privateKey = keyPair.privateKey
    }
    
    init(id:UInt32, signatureKey: PrivateKey, timestamp: UInt64) throws {
        let keyPair = try KeyPair()
        let signature = try signatureKey.sign(message: keyPair.publicKey.data)
        self.publicKey = SessionSignedPreKeyPublic(id: id, timestamp: timestamp, key: keyPair.publicKey, signature: signature)
        guard publicKey.verify(with: try signatureKey.publicKey()) else {
            throw SignalError(.invalidSignature)
        }
        self.privateKey = keyPair.privateKey
    }
    
    var keyPair: KeyPair {
        return KeyPair(publicKey: publicKey.key, privateKey: privateKey)
    }
}

extension SessionSignedPreKey: ProtocolBufferEquivalent {
    var protoObject: Signal_SignedPreKey {
        return Signal_SignedPreKey.with {
            $0.publicKey = self.publicKey.protoObject
            $0.privateKey = self.privateKey.data
        }
    }
    
    init(from protoObject: Signal_SignedPreKey) throws {
        guard protoObject.hasPublicKey, protoObject.hasPrivateKey else {
            throw SignalError(.invalidProtoBuf, "Missing data in protoBuf object")
        }
        self.publicKey = try SessionSignedPreKeyPublic(from: protoObject.publicKey)
        self.privateKey = try PrivateKey(from: protoObject.privateKey)
    }
}

extension SessionSignedPreKey: Equatable {
    public static func ==(lhs: SessionSignedPreKey, rhs: SessionSignedPreKey) -> Bool {
        return lhs.publicKey == rhs.publicKey && lhs.privateKey == rhs.privateKey
    }
}

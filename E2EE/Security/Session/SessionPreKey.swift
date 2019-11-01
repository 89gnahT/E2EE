//
//  SessionPreKey.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct SessionPreKey {
    static let mediumMaxValue: UInt32 = 0xFFFFFF
    let publicKey: SessionPreKeyPublic
    let privateKey: PrivateKey
    init(id: UInt32, keyPair: KeyPair) {
        self.publicKey = SessionPreKeyPublic(id: id, key: keyPair.publicKey)
        self.privateKey = keyPair.privateKey
    }
    
    init(index: UInt32) throws {
        let id = index
        let keyPair = try KeyPair()
        self.init(id: id, keyPair: keyPair)
    }
    
    var keyPair: KeyPair {
        return KeyPair(publicKey: publicKey.key, privateKey: privateKey)
    }
}

extension SessionPreKey: ProtocolBufferEquivalent {
    var protoObject: Signal_PreKey {
        return Signal_PreKey.with {
            $0.publicKey = publicKey.protoObject
            $0.privateKey = privateKey.data
        }
    }
    
    init(from protoObject: Signal_PreKey) throws {
        guard protoObject.hasPublicKey, protoObject.hasPrivateKey else {
            throw SignalError(.invalidProtoBuf, "Missing data in Session PreKey object")
        }
        self.publicKey = try SessionPreKeyPublic(from: protoObject.publicKey)
        self.privateKey = try PrivateKey(from: protoObject.privateKey)
    }
}

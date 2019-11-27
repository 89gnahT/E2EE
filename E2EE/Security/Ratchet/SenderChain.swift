//
//  SenderChain.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct SenderChain {
    var ratchetKey: KeyPair
    var chainKey: RatchetChainKey
    
    init(ratchetKey: KeyPair, chainKey: RatchetChainKey) {
        self.ratchetKey = ratchetKey
        self.chainKey = chainKey
    }
}

extension SenderChain: ProtocolBufferEquivalent {
    var protoObject: Signal_Session.Chain {
        return Signal_Session.Chain.with {
            $0.senderRatchetKey = self.ratchetKey.publicKey.data
            $0.senderRatchetKeyPrivate = self.ratchetKey.privateKey.data
            $0.chainKey = self.chainKey.protoObject
        }
    }
    
    init(from protoObject: Signal_Session.Chain) throws {
        guard protoObject.hasChainKey && protoObject.hasSenderRatchetKey && protoObject.hasSenderRatchetKeyPrivate else {
            throw SignalError(.invalidProtoBuf, "Invalid ProtoBuf Object for SenderChain")
        }
        chainKey = try RatchetChainKey(from: protoObject.chainKey)
        let publicKey = try PublicKey(from: protoObject.senderRatchetKey)
        let privateKey = try PrivateKey(from: protoObject.senderRatchetKeyPrivate)
        ratchetKey = KeyPair(publicKey: publicKey, privateKey: privateKey)
    }
}

extension SenderChain: Equatable {
    static func ==(lhs: SenderChain, rhs: SenderChain) -> Bool {
        return lhs.chainKey == rhs.chainKey && lhs.ratchetKey == rhs.ratchetKey
    }
}

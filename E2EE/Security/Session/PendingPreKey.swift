//
//  PendingPrekey.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct PendingPreKey {
    var preKeyId: UInt32?
    var signedPreKeyId: UInt32
    var baseKey: PublicKey
}

extension PendingPreKey: ProtocolBufferEquivalent {
    var protoObject: Signal_Session.PendingPreKey {
        return Signal_Session.PendingPreKey.with {
            if let item = preKeyId {
                $0.preKeyID = item
            }
            $0.signedPreKeyID = Int32(self.signedPreKeyId)
            $0.baseKey = self.baseKey.data
        }
    }
    
    init(from protoObject: Signal_Session.PendingPreKey) throws {
        guard protoObject.hasBaseKey, protoObject.hasSignedPreKeyID else {
            throw SignalError(.invalidProtoBuf, "Missing data in object")
        }
        if protoObject.hasPreKeyID {
            self.preKeyId = protoObject.preKeyID
        }
        if protoObject.signedPreKeyID < 0 {
            throw SignalError(.invalidProtoBuf, "Invalid SignedPreKeyid \(protoObject.signedPreKeyID)")
        }
        self.signedPreKeyId = UInt32(protoObject.signedPreKeyID)
        self.baseKey = try PublicKey(from: protoObject.baseKey)
    }
}

extension PendingPreKey: Equatable {
    static func ==(lhs: PendingPreKey, rhs: PendingPreKey) -> Bool {
        return lhs.preKeyId == rhs.preKeyId && lhs.signedPreKeyId == rhs.signedPreKeyId && lhs.baseKey == rhs.baseKey
    }
}

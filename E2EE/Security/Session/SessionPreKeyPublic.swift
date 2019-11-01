//
//  SessionPreKeyPublic.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct SessionPreKeyPublic {
    let id: UInt32
    let key: PublicKey
    
    init(id: UInt32, key: PublicKey) {
        self.id = id
        self.key = key
    }
}

extension SessionPreKeyPublic: ProtocolBufferEquivalent {
    var protoObject: Signal_PreKey.PublicPart {
        return Signal_PreKey.PublicPart.with {
            $0.id = self.id
            $0.key = key.data
        }
    }
    
    init(from protoObject: Signal_PreKey.PublicPart) throws {
        guard protoObject.hasID, protoObject.hasKey else {
            throw SignalError(.invalidProtoBuf, "Missing data in Session public prekey")
        }
        self.id = protoObject.id
        self.key = try PublicKey(from: protoObject.key)
    }
}

//
//  SessionPreKeyBundle.swift
//  E2EE
//
//  Created by CPU11899 on 10/31/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct SessionPreKeyBundle {
    var preKeyId: UInt32
    var preKeyPublic: PublicKey?
    var signedPreKeyId: UInt32
    var signedPreKeyPublic: PublicKey
    var signedPreKeySignature: Data
    var identityKey: PublicKey
    
    init(preKeyId: UInt32, preKeyPublic: PublicKey?, signedPreKeyId: UInt32, signedPreKeyPublic: PublicKey, signedPreKeySignature: Data, identityKey: PublicKey) {
        self.preKeyId = preKeyId
        self.preKeyPublic = preKeyPublic
        self.signedPreKeyPublic = signedPreKeyPublic
        self.signedPreKeyId = signedPreKeyId
        self.signedPreKeySignature = signedPreKeySignature
        self.identityKey = identityKey
    }
    
    init(preKey: SessionPreKeyPublic, signedPreKey: SessionSignedPreKeyPublic, identityKey: PublicKey) {
        self.preKeyId = preKey.id
        self.preKeyPublic = preKey.key
        self.signedPreKeyId = signedPreKey.id
        self.identityKey = identityKey
        self.signedPreKeyPublic = signedPreKey.key
        self.signedPreKeySignature = signedPreKey.signature
    }
    
    public init(preKey: Data, signedPreKey: Data, identityKey: Data) throws {
        self.init(preKey: try SessionPreKeyPublic(from: preKey), signedPreKey: try SessionSignedPreKeyPublic(from: signedPreKey), identityKey: try PublicKey(from: identityKey))
    }
}

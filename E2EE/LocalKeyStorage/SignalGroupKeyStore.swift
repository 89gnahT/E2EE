//
//  SignalGroupKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class SignalGroupKeyStore: GroupKeyStore {
    private var identityKey: Data!
    var senderKeyStore: SignalSenderKeyStore = SignalSenderKeyStore()
    
    var identityKeyStore: SignalIdentityKeyStore = SignalIdentityKeyStore()
    
    var preKeyStore: PreKeyStore = SignalPreKeyStore()
    
    var sessionStore: SignalSessionStore = SignalSessionStore()
    
    var signedPreKeyStore: SignedPreKeyStore = SignalSignedPreKeyStore()
    
    
    typealias GroupAddress = SignalSenderKeyName
    
    typealias SenderKeyStoreType = SignalSenderKeyStore
    
    typealias Address = SignalAddress
    
    typealias IdentityKeyStoreType = SignalIdentityKeyStore
    
    typealias SessionStoreType = SignalSessionStore
    
    init(withKeyPair keyPair: Data) {
        self.identityKey = keyPair
    }
    
    init() {}
}

//
//  SignalKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class SignalKeyStore: KeyStore {
    var identityKeyStore: SignalIdentityKeyStore
    
    var preKeyStore: PreKeyStore
    
    var sessionStore: SignalSessionStore
    
    var signedPreKeyStore: SignedPreKeyStore
    
    
    typealias Address = SignalAddress
    
    typealias IdentityKeyStoreType = SignalIdentityKeyStore
    
    typealias SessionStoreType = SignalSessionStore
    
    init(withKeyPair keyPair: Data) {
        identityKeyStore = SignalIdentityKeyStore(keyPair: keyPair)
        preKeyStore = SignalPreKeyStore()
        sessionStore = SignalSessionStore()
        signedPreKeyStore = SignalSignedPreKeyStore()
    }
}

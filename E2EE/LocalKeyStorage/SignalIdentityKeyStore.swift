//
//  IdentityKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class SignalIdentityKeyStore: IdentityKeyStore {
    typealias Address = SignalAddress
    private var identityKey: Data!
    private var identities = [SignalAddress: Data]()
    
    func getIdentityKeyData() throws -> Data {
        if identityKey == nil {
            let crypto = CommonSignalCrypto()
            identityKey = try crypto.generateIdentityKeyPair()
        }
        return self.identityKey
    }
    
    func identity(for address: Address) throws -> Data? {
        return self.identities[address]
    }
    
    func store(identity: Data?, for address: Address) throws {
        self.identities[address] = identity
    }
    
    required init(keyPair: Data) {
        self.identityKey = keyPair
    }
    
    init() {
        
    }
}

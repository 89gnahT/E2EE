//
//  SignalSignedPreKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class SignalSignedPreKeyStore: SignedPreKeyStore {
    private var signedPreKeys = [UInt32: Data]()
    func store(signedPreKey: Data, for id: UInt32) throws {
        self.signedPreKeys[id] = signedPreKey
        lastId = id
    }
    
    func signedPrekey(for id: UInt32) throws -> Data {
        guard let key = self.signedPreKeys[id] else { throw SignalError(.storageError, "No contain preKey for \(id)") }
        return key
    }
    
    func containsSignedPreKey(for id: UInt32) throws -> Bool {
        return self.signedPreKeys[id] != nil
    }
    
    func removeSignedPreKey(for id: UInt32) throws {
        self.signedPreKeys[id] = nil
    }
    
    func allIds() throws -> [UInt32] {
        return [UInt32](self.signedPreKeys.keys)
    }
    
    var lastId: UInt32 = 0
    
}

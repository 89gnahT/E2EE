//
//  SignalPreKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class SignalPreKeyStore: PreKeyStore {
    private var preKeys = [UInt32: Data]()
    var lastId: UInt32 = 0
    
    func store(preKey: Data, for id: UInt32) throws {
        self.preKeys[id] = preKey
        lastId = id
    }
    
    func preKey(for id: UInt32) throws -> Data {
        guard let key = preKeys[id] else { throw SignalError(.storageError, "No preKey for id \(id)") }
        return key
    }
    
    func containPreKey(for id: UInt32) -> Bool {
        return preKeys[id] != nil
    }
    
    func removePreKey(for id: UInt32) throws {
        preKeys[id] = nil
    }
    
}

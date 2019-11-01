//
//  SignedPrekeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public protocol SignedPreKeyStore: class {
    func signedPrekey(for id: UInt32) throws -> Data
    func store(signedPreKey: Data, for id: UInt32) throws
    func containsSignedPreKey(for id: UInt32) throws -> Bool
    func removeSignedPreKey(for id: UInt32) throws
    func allIds() throws -> [UInt32]
    var lastId: UInt32 {get set}
}

extension SignedPreKeyStore {
    func signedPreKey(for id: UInt32) throws -> SessionSignedPreKey {
        let record = try signedPrekey(for: id)
        return try SessionSignedPreKey(from: record)
    }
    
    func store(signedPreKey: SessionSignedPreKey) throws {
        let data = try signedPreKey.protoData()
        try store(signedPreKey: data, for: signedPreKey.publicKey.id)
    }
}

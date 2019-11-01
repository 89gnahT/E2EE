//
//  PreKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public protocol PreKeyStore: class {
    func preKey(for id: UInt32) throws -> Data
    func store(preKey: Data, for id: UInt32) throws
    func containPreKey(for id: UInt32) -> Bool
    func removePreKey(for id: UInt32) throws
    var lastId: UInt32 {get set}
}

extension PreKeyStore {
    func preKey(for id: UInt32) throws -> SessionPreKey {
        let data = try preKey(for: id)
        return try SessionPreKey(from: data)
    }
    
    func store(preKey: SessionPreKey) throws {
        let data = try preKey.protoData()
        try store(preKey: data, for: preKey.publicKey.id)
    }
}

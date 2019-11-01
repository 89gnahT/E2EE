//
//  IdentityKeyStore.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 10/24/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public protocol IdentityKeyStore : class {
    associatedtype Address : Hashable
    
    func getIdentityKeyData() throws -> Data
    func identity(for address: Address) throws -> Data?
    func store(identity: Data?, for address: Address) throws
    
}

extension IdentityKeyStore {
    func getIdentityKey() throws -> KeyPair {
        let identity = try getIdentityKeyData()
        return try KeyPair(from: identity)
    }
    
    public func getPublicIdentityKey() throws -> Data {
        let identity = try getIdentityKeyData()
        let pair = try KeyPair(from: identity)
        return pair.publicKey.data
    }
    
    public func getIdentityKeyPublicData() throws -> Data {
        let identity = try getIdentityKeyData()
        let key = try KeyPair(from: identity)
        return key.publicKey.data
    }
    
    public func isTrusted(identity: Data, for address: Address) throws -> Bool {
        if let data = try self.identity(for: address) {
            return data == identity
        }
        return true
    }
    
    public func store(identity: PublicKey?, for address: Address) throws {
        try store(identity: identity?.data, for: address)
    }
    
    func isTrusted(identity: PublicKey, for address: Address) throws -> Bool {
        return try isTrusted(identity: identity.data, for: address)
    }
}


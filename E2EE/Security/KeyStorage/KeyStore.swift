//
//  KeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public protocol KeyStore: class {
    associatedtype Address: CustomStringConvertible
    associatedtype IdentityKeyStoreType: IdentityKeyStore where IdentityKeyStoreType.Address == Address
    associatedtype SessionStoreType: SessionStore where SessionStoreType.Address == Address
    
    var identityKeyStore: IdentityKeyStoreType  {get}
    var preKeyStore: PreKeyStore {get}
    var sessionStore: SessionStoreType {get}
    var signedPreKeyStore: SignedPreKeyStore {get}
}

extension KeyStore {
    public func signatureWithIdentityKey(message: Data) throws -> Data {
        let privateKey = try identityKeyStore.getIdentityKey().privateKey
        return try privateKey.sign(message: message)
    }
    
    public func updateSignedPrekey(timestamp: UInt64 = UInt64(Date().timeIntervalSince1970)) throws -> Data {
        let crypto = CommonSignalCrypto()
        let currentId = signedPreKeyStore.lastId
        let nextId = currentId &+ 1
        let privateKey = try identityKeyStore.getIdentityKey().privateKey
        let key = try crypto.generatedSignedPreKey(identityKey: privateKey, id: nextId, timestamp: timestamp)
        try signedPreKeyStore.store(signedPreKey: key)
        let oldId = currentId &- 1
        if try signedPreKeyStore.containsSignedPreKey(for: oldId) {
            try signedPreKeyStore.removeSignedPreKey(for: oldId)
        }
        
        return try key.publicKey.protoData()
    }
    
    public func createPreKeys(count: Int) throws -> [Data] {
        let commonCrypto = CommonSignalCrypto()
        let start = preKeyStore.lastId &+ 1
        let keys = try commonCrypto.generatePreKeys(start: start, count: count)
        for key in keys {
            try preKeyStore.store(preKey: key)
        }
        preKeyStore.lastId = start &+ UInt32(count)
        return try keys.map({(sessionPreKey: SessionPreKey) -> Data in
            return try sessionPreKey.publicKey.protoData()
        })
    }
    
    private func fingerprint(for remoteAddress: Address, localAddress: Address) throws -> Fingerprint {
        let localIdentity = try identityKeyStore.getIdentityKeyPublicData()
        guard let remoteIdentity = try identityKeyStore.identity(for: remoteAddress) else {
            throw SignalError(.untrustedIdentity, "No identity for address")
        }
        
        
        return try Fingerprint(localStableIdentifier: localAddress.description, localIdentity: localIdentity, remoteStableIdentifier: remoteAddress.description, remoteIdentity: remoteIdentity)
    }
    
    public func sign(message: Data) throws -> Data {
        return try identityKeyStore.getIdentityKey().privateKey.sign(message: message)
    }
}

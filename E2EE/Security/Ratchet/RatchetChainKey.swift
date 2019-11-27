//
//  RatchetChainKey.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct RatchetChainKey {
    private static let messageKeySeed = Data([0x01])
    private static let chainKeySeed = Data([0x02])
    private static let keyMaterialSeed = "WhisperMessageKeys".data(using: .utf8)!
    static let secretSize = 32
    static let hashOutputSize = 32
    var key: Data
    var index: UInt32
    private let signalCrypto = CommonSignalCrypto()
    
    init(key: Data, index: UInt32) {
        self.key = key
        self.index = index
    }
    
    private func getBaseMaterial(seed: Data) throws -> Data {
        return try self.signalCrypto.hmacSHA256(for: seed, with: key)
    }
    
    func messageKeys() throws -> RatchetMessageKeys {
        let inputKeyMaterial = try getBaseMaterial(seed: RatchetChainKey.messageKeySeed)
        let salt = Data(count: RatchetChainKey.hashOutputSize)
        let keyMaterialData = try HKDF.deriveSecrets(material: inputKeyMaterial, salt: salt, info: RatchetChainKey.keyMaterialSeed, outputLength: RatchetMessageKeys.derivedMessageSecretsSize)
        var temp = index
        let indexData = withUnsafePointer(to: &temp, {(tempPointer: UnsafePointer) -> Data in
            return Data(bytes: tempPointer, count: MemoryLayout<UInt32>.size)
        })
        return try RatchetMessageKeys(material: keyMaterialData + indexData)
    }
    
    func next() throws -> RatchetChainKey {
        let nextKey = try getBaseMaterial(seed: RatchetChainKey.chainKeySeed)
        return RatchetChainKey(key: nextKey, index: index + 1)
    }
}

extension RatchetChainKey: ProtocolBufferEquivalent {
    var protoObject: Signal_Session.Chain.ChainKey {
        return Signal_Session.Chain.ChainKey.with {
            $0.index = self.index
            $0.key = self.key
        }
    }
    
    init(from protoObject: Signal_Session.Chain.ChainKey) throws {
        guard protoObject.hasKey && protoObject.hasIndex else {
            throw SignalError(.invalidProtoBuf, "Missing in Ratchet Chain Key ProtoBuf Object")
        }
        self.index = protoObject.index
        self.key = protoObject.key
    }
}

extension RatchetChainKey: Equatable {
    static func ==(lhs: RatchetChainKey, rhs: RatchetChainKey) -> Bool {
        return lhs.key == rhs.key && lhs.index == rhs.index
    }
}

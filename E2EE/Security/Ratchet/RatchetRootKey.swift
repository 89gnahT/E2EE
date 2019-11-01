//
//  RatchetRootKey.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct RatchetRootKey {
    private static let keyInfo = "WhisperRatchet".data(using: .utf8)!
    static let secrectSize = 32
    let key: Data
    
    init(key: Data) {
        self.key = key
    }
    
    func createChain(theirRatchetKey: PublicKey, ourRatchetKey: PrivateKey) throws -> (rootKey: RatchetRootKey, chainKey: RatchetChainKey) {
        let sharedSecrect = try theirRatchetKey.calculateAgreement(privateKey: ourRatchetKey)
        return try HKDF.chainAndRootKey(material: sharedSecrect, salt: key, info: RatchetRootKey.keyInfo)
    }
}

extension RatchetRootKey: ProtocolBufferSerializable {
    func protoData() -> Data {
        return key
    }
    
    init(from protoData: Data) {
        self.key = protoData
    }
}

extension RatchetRootKey: Comparable {
    static func <(a: RatchetRootKey, b: RatchetRootKey) -> Bool {
        guard a.key.count == b.key.count else {
            return a.key.count < b.key.count
        }
        for i in 0..<a.key.count {
            if a.key[i] != b.key[i] {
                return a.key[i] < b.key[i]
            }
        }
        return false
    }
}

extension RatchetRootKey: Equatable {
    static func ==(a: RatchetRootKey, b: RatchetRootKey) -> Bool {
        return a.key == b.key
    }
}

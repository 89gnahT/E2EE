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
    static func <(lhs: RatchetRootKey, rhs: RatchetRootKey) -> Bool {
        guard lhs.key.count == rhs.key.count else {
            return lhs.key.count < rhs.key.count
        }
        for i in 0..<lhs.key.count {
            if lhs.key[i] != rhs.key[i] {
                return lhs.key[i] < rhs.key[i]
            }
        }
        return false
    }
}

extension RatchetRootKey: Equatable {
    static func ==(lhs: RatchetRootKey, rhs: RatchetRootKey) -> Bool {
        return lhs.key == rhs.key
    }
}

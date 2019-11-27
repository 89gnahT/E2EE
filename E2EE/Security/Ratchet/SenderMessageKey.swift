//
//  SenderMessageKey.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct SenderMessageKey {
    private static let infoMaterial = "WhisperGroup".data(using: .utf8)!
    private static let ivLength = 16
    private static let cipherKeyLength = 32
    private static let secretLength = ivLength + cipherKeyLength
    
    var iteration: UInt32
    var iv: Data
    var cipherKey: Data
    private var seed: Data
    
    init(iteration: UInt32, seed: Data) throws {
        let salt = Data(count: RatchetChainKey.hashOutputSize)
        let derivative = try HKDF.deriveSecrets(material: seed, salt: salt, info: SenderMessageKey.infoMaterial, outputLength: SenderMessageKey.secretLength)
        self.iteration = iteration
        self.seed = seed
        self.iv = derivative[0..<SenderMessageKey.ivLength]
        self.cipherKey = derivative.advanced(by: SenderMessageKey.ivLength)
    }
}

extension SenderMessageKey: ProtocolBufferEquivalent {
    var protoObject: Signal_SenderKeyState.SenderMessageKey {
        return Signal_SenderKeyState.SenderMessageKey.with {
            $0.iteration = self.iteration
            $0.seed = seed
        }
    }
    
    init(from protoObject: Signal_SenderKeyState.SenderMessageKey) throws {
        guard protoObject.hasSeed && protoObject.hasIteration else {
            throw SignalError(.invalidProtoBuf, "Invalid ProtoBuf object for SenderMessageKey")
        }
        try self.init(iteration: protoObject.iteration, seed: protoObject.seed)
    }
}

extension SenderMessageKey: Equatable {
    static func ==(lhs: SenderMessageKey, rhs: SenderMessageKey) -> Bool {
        return lhs.iteration == rhs.iteration && lhs.seed == rhs.seed && lhs.cipherKey == rhs.cipherKey && lhs.iv == rhs.iv
    }
}

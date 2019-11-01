//
//  SenderChainKey.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct SenderChainKey {
    private static let messageKeySeed = Data([0x01])
    private static let chainKeySeed = Data([0x02])
    var iteration: UInt32
    var chainKey: Data
    let crypto = CommonSignalCrypto()
    
    init(iteration: UInt32, chainKey: Data) {
        self.iteration = iteration
        self.chainKey = chainKey
    }
    
    mutating func messageKey() throws -> SenderMessageKey {
        let derivative = try self.crypto.hmacSHA256(for: SenderChainKey.chainKeySeed, with: chainKey)
        let messageKey = try SenderMessageKey(iteration: iteration, seed: derivative)
        chainKey = Data(derivative)
        iteration += 1
        return messageKey
    }
}

extension SenderChainKey : ProtocolBufferEquivalent {
    var protoObject: Signal_SenderKeyState.SenderChainKey {
        return Signal_SenderKeyState.SenderChainKey.with {
            $0.iteration = self.iteration
            $0.seed = self.chainKey
        }
    }
    
    init(from protoObject: Signal_SenderKeyState.SenderChainKey) throws {
        guard protoObject.hasSeed && protoObject.hasIteration else {
            throw SignalError(.invalidProtoBuf, "Invalid ProtoBufObject for Sender Chain Key")
        }
        self.iteration = protoObject.iteration
        self.chainKey = protoObject.seed
    }
}

extension SenderChainKey : Equatable {
    static func ==(a: SenderChainKey, b: SenderChainKey) -> Bool {
        return a.chainKey == b.chainKey && a.iteration == b.iteration
    }
}

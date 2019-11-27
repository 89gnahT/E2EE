//
//  SenderKeyDistributionMessage.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 10/31/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
public struct SenderKeyDistributionMessage {
    var id: UInt32
    var iteration: UInt32
    var chainKey: Data
    var signatureKey: PublicKey
    
    public func baseMessage() throws -> CipherTextMessage {
        return CipherTextMessage(type: .senderKeyDistribution, data: try self.protoData())
    }
    
    init(id: UInt32, iteration: UInt32, chainKey: Data, signatureKey: PublicKey) {
        self.id = id
        self.iteration = iteration
        self.chainKey = chainKey
        self.signatureKey = signatureKey
    }
    
}

extension SenderKeyDistributionMessage: ProtocolBufferEquivalent {
    var protoObject: Signal_SenderKeyDistributionMessage {
        return Signal_SenderKeyDistributionMessage.with {
            $0.id = self.id
            $0.iteration = self.iteration
            $0.chainKey = self.chainKey
            $0.signingKey = self.signatureKey.data
        }
    }
    
    init(from protoObject: Signal_SenderKeyDistributionMessage) throws {
        guard protoObject.hasID, protoObject.hasChainKey, protoObject.hasIteration, protoObject.hasSigningKey else {
            throw SignalError(.invalidProtoBuf, "Missing data in Protocol Buffer Object")
        }
        self.id = protoObject.id
        self.iteration = protoObject.iteration
        self.chainKey = protoObject.chainKey
        self.signatureKey = try PublicKey(from: protoObject.signingKey)
    }
}

extension SenderKeyDistributionMessage: Equatable {
    public static func ==(lhs: SenderKeyDistributionMessage, rhs: SenderKeyDistributionMessage) -> Bool {
        return lhs.id == rhs.id && lhs.chainKey == rhs.chainKey && lhs.iteration == rhs.iteration && lhs.signatureKey == rhs.signatureKey
    }
}




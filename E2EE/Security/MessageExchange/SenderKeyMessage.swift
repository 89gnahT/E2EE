//
//  SenderKeyMessage.swift
//  E2EE
//
//  Created by CPU11899 on 10/31/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import Curve25519

public struct SenderKeyMessage {
    let keyId: UInt32
    let iteration: UInt32
    let cipherText: Data
    var signature: Data
    
    func baseMessage() throws -> CipherTextMessage {
        return CipherTextMessage(type: .senderKey, data: try self.protoData())
    }
    
    init(keyId: UInt32, iteration: UInt32, cipherText: Data, signatureKey: PrivateKey) throws {
        self.keyId = keyId
        self.iteration = iteration
        self.cipherText = cipherText
        self.signature = Data()
        let data = try self.protoData()
        self.signature = try signatureKey.sign(message: data)
    }
    
    func verify(signatureKey: PublicKey) throws -> Bool {
        guard signature.count == Curve25519.signatureLength else {
            return false
        }
        let record = try self.protoData()
        let length = record.count - Curve25519.signatureLength
        let message = record[0..<length]
        return signatureKey.verify(signature: signature, for: message)
    }
}

extension SenderKeyMessage: ProtocolBufferEquivalent {
    var protoObject: Signal_SenderKeyMessage {
        return Signal_SenderKeyMessage.with {
            $0.id = self.keyId
            $0.ciphertext = self.cipherText
            $0.iteration = self.iteration
        }
    }
    
    init(from protoObject: Signal_SenderKeyMessage) throws {
        guard protoObject.hasID, protoObject.hasCiphertext, protoObject.hasIteration else {
            throw SignalError(.invalidProtoBuf, "Missing data in protoBuf object")
        }
        self.keyId = protoObject.id
        self.cipherText = protoObject.ciphertext
        self.iteration = protoObject.iteration
        self.signature = Data()
    }
}

extension SenderKeyMessage: ProtocolBufferSerializable {
    public func protoData() throws -> Data {
        do {
            return try protoObject.serializedData() + signature
        } catch {
            throw SignalError(.invalidProtoBuf, "Could not serializa Sender Key Message:\(error)")
        }
    }
    public init(from data: Data) throws {
        guard data.count > Curve25519.signatureLength else {
            throw SignalError(.invalidProtoBuf, "Too few bytes in data for SenderKeyMessage")
        }
        let length = data.count - Curve25519.signatureLength
        guard length > 1 else {
            throw SignalError(.invalidProtoBuf, "Too few bytes in SenderKeyMessage")
        }
        let content = data[0..<length]
        let signature = data[length...]
        let object: Signal_SenderKeyMessage
        do {
            object = try Signal_SenderKeyMessage(serializedData: content)
        } catch {
            throw SignalError(.invalidProtoBuf, "Could not create sender key message object: \(error)")
        }
        try self.init(from: object)
        self.signature = signature
    }
}

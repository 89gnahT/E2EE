//
//  SignalMessage.swift
//  E2EE
//
//  Created by CPU11899 on 10/31/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct SignalMessage {
    static let macLength = 8
    let senderRatchetKey: PublicKey
    let counter: UInt32
    let previousCounter: UInt32
    let cipherText: Data
    var mac: Data
    
    init(macKey: Data, senderRatchetKey: PublicKey, counter: UInt32, previousCounter: UInt32, cipherText: Data, senderIdentityKey: PublicKey, receiverIdentityKey: PublicKey) throws {
        self.senderRatchetKey = senderRatchetKey
        self.counter = counter
        self.previousCounter = previousCounter
        self.cipherText = cipherText
        self.mac = Data()
        self.mac = try getMac(senderIdentityKey: senderIdentityKey, receiverIdentityKey: receiverIdentityKey, macKey: macKey, message: try self.protoData())
    }
    
    private func getMac(senderIdentityKey: PublicKey, receiverIdentityKey: PublicKey, macKey: Data, message: Data) throws -> Data {
        let bytes = senderIdentityKey.data + receiverIdentityKey.data
        let crypto = CommonSignalCrypto()
        let longMac = try crypto.hmacSHA256(for: bytes + message, with: macKey)
        guard longMac.count >= SignalMessage.macLength else {
            throw SignalError(.hmacError, "MAC length invalid: Is \(SignalMessage.macLength), maximum \(longMac.count)")
        }
        return longMac[0..<SignalMessage.macLength]
    }
    
    func verifyMac(senderIdentityKey: PublicKey, receiverIdentityKey: PublicKey, macKey: Data) throws -> Bool {
        let data = try self.protoData()
        let length = data.count - SignalMessage.macLength
        let content = data[0..<length]
        let ourMac = try getMac(senderIdentityKey: senderIdentityKey, receiverIdentityKey: receiverIdentityKey, macKey: macKey, message: content)
        guard ourMac.count == SignalMessage.macLength else {
            throw SignalError(.hmacError, "MAC Length mismatch: \(mac.count) != \(SignalMessage.macLength)")
        }
        return ourMac == mac
    }
    
    func baseMessage() throws -> CipherTextMessage {
        return CipherTextMessage(type: .signal, data: try self.protoData())
    }
}

extension SignalMessage: ProtocolBufferEquivalent {
    var protoObject: Signal_SignalMessage {
        return Signal_SignalMessage.with {
            $0.ciphertext = self.cipherText
            $0.counter = self.counter
            $0.previousCounter = self.previousCounter
            $0.ratchetKey = self.senderRatchetKey.data
        }
    }
    
    init(from protoObject: Signal_SignalMessage) throws {
        guard protoObject.hasCounter, protoObject.hasCiphertext, protoObject.hasRatchetKey, protoObject.hasPreviousCounter else {
            throw SignalError(.invalidProtoBuf, "Missing data in protobuf object")
        }
        self.cipherText = protoObject.ciphertext
        self.senderRatchetKey = try PublicKey(from: protoObject.ratchetKey)
        self.previousCounter = protoObject.previousCounter
        self.counter = protoObject.counter
        self.mac = Data()
    }
}

extension SignalMessage: ProtocolBufferSerializable {
    public func protoData() throws -> Data {
        do {
            return try protoObject.serializedData() +
            mac
        } catch {
            throw SignalError(.invalidProtoBuf, "Could not serialize signal message: \(error)")
        }
    }
    
    public init(from data: Data) throws {
        guard data.count > SignalMessage.macLength else {
            throw SignalError(.invalidMessage, "Invalid length of SignalMessage: \(data.count)")
        }
        let length = data.count - SignalMessage.macLength
        let newData = data[0..<length]
        let protoObject: Signal_SignalMessage
        do {
            protoObject = try Signal_SignalMessage(serializedData: newData)
        } catch  {
            throw SignalError(.invalidProtoBuf, "Could not create SignalMessage ProtoBuf object: \(error)")
        }
        try self.init(from: protoObject)
        self.mac = data.advanced(by: length)
    }
}

extension SignalMessage: Equatable {
    public static func ==(a: SignalMessage, b: SignalMessage) -> Bool {
        return a.counter == b.counter && a.previousCounter == b.previousCounter && a.cipherText == b.cipherText && a.mac == b.mac && a.senderRatchetKey == b.senderRatchetKey
    }
}

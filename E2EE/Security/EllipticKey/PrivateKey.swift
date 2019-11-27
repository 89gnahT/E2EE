//
//  PrivateKey.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 10/24/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import Curve25519

public struct PrivateKey {
    private let key: Data
    
    var data: Data {
        return key
    }
    
    init (point: Data) throws {
        guard point.count == Curve25519.keyLength else {
            throw SignalError(.invalidProtoBuf, "Invalid key length: \(point.count)")
        }
        guard point[0] & 0b00000111 == 0 else {
            throw SignalError(.invalidProtoBuf, "Invalid private key (byte 0 == \(point[0])")
        }
        let lastByteIndex = Curve25519.keyLength - 1
        guard point[lastByteIndex] & 0b10000000 == 0 else {
            throw SignalError(.invalidProtoBuf, "Invalid private key (byte \(lastByteIndex) == \(point[lastByteIndex])")
        }
        guard point[lastByteIndex] & 0b01000000 != 0 else {
            throw SignalError(.invalidProtoBuf, "Invalid private key (byte \(lastByteIndex) == \(point[lastByteIndex])")
        }
        key = point
    }
    
    init(unverifiedPoint point: Data) throws {
        guard point.count == Curve25519.keyLength else {
            throw SignalError(.invalidLength, "Invalid key length: \(point.count)")
        }
        key = point
    }
    
    public init() throws {
        let signalCrypto = CommonSignalCrypto()
        var random : Data = try signalCrypto.random(bytes: Curve25519.keyLength)
        random[0] &= 248
        random[31] = (random[31] & 127) | 64
        self.key = random
    }
    
    public func sign(message: Data) throws -> Data {
        let signalCrypto = CommonSignalCrypto()
        let random = try signalCrypto.random(bytes: Curve25519.signatureLength)
        do {
            return try Curve25519.signature(for: message, privateKey: key, randomData: random)
        } catch {
            throw SignalError(.invalidSignature, "Could not sign message: \(error)")
        }
    }
    
    func signVRF(message: Data) throws -> Data {
        let signalCrypto = CommonSignalCrypto()
        let random = try signalCrypto.random(bytes: 32)
        do {
            return try Curve25519.vrfSignature(for: message, privateKey: key, randomData: random)
        } catch {
            throw SignalError(.invalidSignature, "VRF signature failed \(error)")
        }
    }
    
    func calculateAgreement(publicKey: PublicKey) throws -> Data {
        return try publicKey.calculateAgreement(privateKey: self)
    }
    
    func keyPair() throws -> KeyPair {
        return try KeyPair(privateKey: self)
    }
    
    func publicKey() throws -> PublicKey {
        return try PublicKey(privateKey: self)
    }
}

extension PrivateKey: Equatable {
    public static func ==(lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        return lhs.key == rhs.key
    }
}

extension PrivateKey: ProtocolBufferSerializable {
    public init(from data: Data) throws {
        try self.init(point: data)
    }
    public func protoData() -> Data {
        return key
    }
}

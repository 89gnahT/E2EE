//
//  KeyPair.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 10/24/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import SwiftProtobuf

public struct KeyPair {
    static let DJBType: UInt8 = 0x05
    public let publicKey: PublicKey
    public let privateKey: PrivateKey
    
    public init(publicKey: PublicKey, privateKey: PrivateKey) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    
    public init(privateKey: PrivateKey) throws {
        self.publicKey = try PublicKey(privateKey: privateKey)
        self.privateKey = privateKey
    }
    
    public init() throws {
        self.privateKey = try PrivateKey()
        self.publicKey = try PublicKey(privateKey: self.privateKey)
    }
    
    func sign(message: Data) throws -> Data {
        return try privateKey.sign(message: message)
    }
    
    func signVRF(message: Data) throws -> Data {
        return try privateKey.signVRF(message: message)
    }
    
    func calculateAgreement(publicKey: PublicKey) throws -> Data {
        return try publicKey.calculateAgreement(privateKey: privateKey)
    }
    
    func calculateAgreement(privateKey: PrivateKey) throws -> Data {
        return try privateKey.calculateAgreement(publicKey: publicKey)
    }
    
    func verify(signature: Data, for message: Data) -> Bool {
        return publicKey.verify(signature: signature, for: message)
    }
    
    func verify(vrfSignature: Data, for message: Data) throws -> Data {
        return try publicKey.verify(vrfSignature: vrfSignature, for: message)
    }
    
}

extension KeyPair: ProtocolBufferEquivalent {
    
    init(from protoObject: Signal_KeyPair) throws {
        guard protoObject.hasPublicKey, protoObject.hasPrivateKey else {
            throw SignalError(.invalidProtoBuf, "Missing data in protobuf object")
        }
        self.publicKey = try PublicKey(from: protoObject.publicKey)
        self.privateKey = try PrivateKey(from: protoObject.privateKey)
    }
    
    var protoObject: Signal_KeyPair {
        return Signal_KeyPair.with {
            $0.publicKey = self.publicKey.data
            $0.privateKey = self.privateKey.data
        }
    }
}

extension KeyPair: Equatable {
    public static func ==(a: KeyPair, b: KeyPair) -> Bool {
        return a.privateKey == b.privateKey && a.publicKey == b.publicKey
    }
}



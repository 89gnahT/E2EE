//
//  PublicKey.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 10/24/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import Curve25519

public struct PublicKey {
    private static let basePoint = Data([9] + [UInt8](repeating: 0, count: 31))
    private let key: Data
    
    public var data: Data {
        return key
    }
    
    init(point: Data) throws {
        guard point.count == Curve25519.keyLength else {
            throw SignalError(.invalidProtoBuf, "Invalid Key length \(point.count)")
        }
        self.key = point
    }
    
    public init(privateKey: PrivateKey) throws {
        do {
            self.key = try Curve25519.publicKey(for: privateKey.data, basepoint: PublicKey.basePoint)
        } catch {
            throw SignalError(.curveError, "Could not create public key from private key: \(error)")
        }
    }
    
    public func verify(signature: Data, for message: Data) -> Bool {
        return Curve25519.verify(signature: signature, for: message, publicKey: key)
    }
    
    func verify(vrfSignature: Data, for message: Data) throws -> Data {
        do {
            return try Curve25519.verify(vrfSignature: vrfSignature, for: message, publicKey: key)
        } catch {
            throw SignalError(.invalidSignature, "Invalide vrf signature: \(error)")
        }
    }
    
    public func calculateAgreement(privateKey: PrivateKey) throws -> Data {
        do {
            return try Curve25519.calculateAgreement(privateKey: privateKey.data, publicKey: key)
        } catch {
            throw SignalError(.curveError, "Could not calculate curve25519: \(error)")
        }
    }
}

extension PublicKey: Comparable {
    public static func <(lhs: PublicKey, rhs: PublicKey) -> Bool {
        for i in 0..<lhs.key.count {
            if lhs.key[i] != rhs.key[i] {
                return lhs.key[i] < rhs.key[i]
            }
        }
        return false
    }
    
    public static func ==(lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.key == rhs.key
    }
}

extension PublicKey: ProtocolBufferSerializable {
    public init(from protoData: Data) throws {
        try self.init(point: protoData)
    }
    
    public func protoData() throws -> Data {
        return data
    }
}


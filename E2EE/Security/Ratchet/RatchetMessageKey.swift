//
//  RatchetMessageKey.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct RatchetMessageKeys {
    static let cipherKeyLength = 32
    static let macKeyLength = 32
    static let ivLength = 16
    static let derivedMessageSecretsSize = cipherKeyLength + macKeyLength + ivLength
    
    var cipherKey: Data
    var macKey: Data
    var iv: Data
    var counter: UInt32
    
    init(cipher: Data, mac: Data, iv: Data, counter: UInt32) throws {
        guard cipher.count == RatchetMessageKeys.cipherKeyLength else {
            throw SignalError(.invalidLength, "Invalid cipher key length \(cipher.count)")
        }
        guard mac.count == RatchetMessageKeys.macKeyLength else {
            throw SignalError(.invalidLength, "Invalid mac key length \(mac.count)")
        }
        guard iv.count == RatchetMessageKeys.ivLength else {
            throw SignalError(.invalidLength, "Invalid iv length \(iv.count)")
        }
        self.cipherKey = cipher
        self.macKey = mac
        self.iv = iv
        self.counter = counter
    }
    
    init(material: Data) throws {
        guard material.count == RatchetMessageKeys.derivedMessageSecretsSize + MemoryLayout<UInt32>.size else {
            throw SignalError(.invalidLength, "Invalid material size")
        }
        self.cipherKey = material[0..<RatchetMessageKeys.cipherKeyLength]
        let length2 = RatchetMessageKeys.cipherKeyLength + RatchetMessageKeys.macKeyLength
        self.macKey = material[RatchetMessageKeys.cipherKeyLength ..< length2]
        self.iv = material[length2..<RatchetMessageKeys.derivedMessageSecretsSize]
        self.counter = material.advanced(by: RatchetMessageKeys.derivedMessageSecretsSize).withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> UInt32 in
            buffer.baseAddress!.assumingMemoryBound(to: UInt32.self).pointee
        })
    }
}

extension RatchetMessageKeys: ProtocolBufferEquivalent {
    var protoObject: Signal_Session.Chain.MessageKey {
        return Signal_Session.Chain.MessageKey.with {
            $0.index = self.counter
            $0.cipherKey = self.cipherKey
            $0.iv = self.iv
            $0.macKey = self.macKey
        }
    }
    
    init(from protoObject: Signal_Session.Chain.MessageKey) throws {
        guard protoObject.hasIv, protoObject.hasIndex, protoObject.hasMacKey, protoObject.hasCipherKey else {
            throw SignalError(.invalidProtoBuf, "Missing data in ProtoBuf Object")
        }
        self.counter = protoObject.index
        self.cipherKey = protoObject.cipherKey
        self.iv = protoObject.iv
        self.macKey = protoObject.macKey
    }
}

extension RatchetMessageKeys: Equatable {
    static func ==(lhs: RatchetMessageKeys, rhs: RatchetMessageKeys) -> Bool {
        return lhs.cipherKey == rhs.cipherKey && lhs.macKey == rhs.macKey && lhs.iv == rhs.iv && lhs.counter == rhs.counter
    }
}

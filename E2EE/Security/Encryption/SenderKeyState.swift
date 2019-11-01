//
//  SenderKeyState.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

final class SenderKeyState {
    static let messageKeyMaximum = 2000
    var keyId: UInt32
    var chainKey: SenderChainKey
    var signaturePublicKey: PublicKey
    var signaturePrivateKey: PrivateKey?
    private var messageKeys: [SenderMessageKey]
    
    init(keyId: UInt32, chainKey: SenderChainKey, signaturePublicKey: PublicKey, signaturePrivateKey: PrivateKey?) {
        self.keyId = keyId
        self.chainKey = chainKey
        self.signaturePublicKey = signaturePublicKey
        self.signaturePrivateKey = signaturePrivateKey
        self.messageKeys = [SenderMessageKey]()
    }
    
    func add(messageKey: SenderMessageKey, removingOldKey: Bool = true) {
        messageKeys.insert(messageKey, at: 0)
        if removingOldKey && messageKeys.count > SenderKeyState.messageKeyMaximum {
            messageKeys.removeLast(messageKeys.count - SenderKeyState.messageKeyMaximum)
        }
    }
    
    func messageKey(for iteration: UInt32) -> SenderMessageKey? {
        for index in 0..<messageKeys.count {
            if messageKeys[index].iteration == iteration {
                return messageKeys.remove(at: index)
            }
        }
        return nil
    }
    
    private func removeOldMessageKeys() {
        let count = messageKeys.count - SenderKeyState.messageKeyMaximum
        if count > 0 {
            messageKeys.removeLast(count)
        }
    }
    
    func senderKey(for iteration: UInt32) throws -> SenderMessageKey {
        if chainKey.iteration > iteration {
            if let messageKey = messageKey(for: iteration) {
                return messageKey
            } else {
                throw SignalError(.duplicateMessage, "Received message with old counter: \(chainKey.iteration), \(iteration)")
            }
        }
        
        if iteration - chainKey.iteration > SenderKeyState.messageKeyMaximum {
            throw SignalError(.invalidMessage, "Over \(SenderKeyState.messageKeyMaximum) message future")
        }
        while chainKey.iteration < iteration {
            let messageKey = try chainKey.messageKey()
            add(messageKey: messageKey, removingOldKey: false)
        }
        removeOldMessageKeys()
        return try chainKey.messageKey()
    }
    
    init(from object: Signal_SenderKeyState) throws {
        guard object.hasSenderKeyID, object.hasSenderChainKey, object.hasSenderSigningKey, object.senderSigningKey.hasPublic else {
            throw SignalError(.invalidProtoBuf, "Missing data in ProtoBuf object")
        }
        self.keyId = object.senderKeyID
        self.chainKey = try SenderChainKey(from: object.senderChainKey)
        self.signaturePublicKey = try PublicKey(from: object.senderSigningKey.public)
        if object.senderSigningKey.hasPrivate {
            self.signaturePrivateKey = try PrivateKey(from: object.senderSigningKey.public)
        }
        self.messageKeys = try object.senderMessageKeys.map{try SenderMessageKey(from: $0)}
    }
    
    var protoObject: Signal_SenderKeyState {
        return Signal_SenderKeyState.with {
            $0.senderKeyID = self.keyId
            $0.senderChainKey = self.chainKey.protoObject
            $0.senderSigningKey = Signal_SenderKeyState.SenderSigningKey.with {
                $0.public = self.signaturePublicKey.data
                if let key = self.signaturePrivateKey {
                    $0.private = key.data
                }
            }
            $0.senderMessageKeys = self.messageKeys.map {$0.protoObject}
        }
    }
}

extension SenderKeyState: Equatable {
    static func ==(a: SenderKeyState, b: SenderKeyState) -> Bool {
        return a.keyId == b.keyId && a.chainKey == b.chainKey && a.messageKeys == b.messageKeys && a.signaturePrivateKey == b.signaturePrivateKey && a.signaturePublicKey == b.signaturePublicKey
    }
}

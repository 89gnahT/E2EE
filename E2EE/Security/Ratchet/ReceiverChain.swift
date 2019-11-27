//
//  RecieverChain.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

final class ReceiverChain: ProtocolBufferEquivalent {
    var ratchetKey: PublicKey
    var chainKey: RatchetChainKey
    private var messageKeys = [RatchetMessageKeys]()
    
    init(ratchetKey: PublicKey, chainKey: RatchetChainKey) {
        self.ratchetKey = ratchetKey
        self.chainKey = chainKey
    }
    
    func add(messageKey: RatchetMessageKeys) {
        for index in 0..<messageKeys.count {
            if messageKeys[index].counter == messageKey.counter {
                messageKeys[index] = messageKey
                return
            }
        }
        messageKeys.insert(messageKey, at: 0)
        if messageKeys.count > SenderKeyState.messageKeyMaximum {
            messageKeys.removeLast(messageKeys.count - SenderKeyState.messageKeyMaximum)
        }
    }
    
    func has(messageKey: RatchetMessageKeys) -> Bool {
        for item in messageKeys {
            if item.counter == messageKey.counter {
                return true
            }
        }
        return false
    }
    
    func messageKey(for iteration: UInt32) -> RatchetMessageKeys? {
        for item in messageKeys {
            if item.counter == iteration {
                return item
            }
        }
        return nil
    }
    
    func removeMessageKey(for iteration: UInt32) -> RatchetMessageKeys? {
        for index in 0..<messageKeys.count {
            if messageKeys[index].counter == iteration {
                return messageKeys.remove(at: index)
            }
        }
        return nil
    }
    
    var protoObject: Signal_Session.Chain {
        return Signal_Session.Chain.with {
            $0.chainKey = self.chainKey.protoObject
            $0.senderRatchetKey = self.ratchetKey.data
            $0.messageKeys = self.messageKeys.map({$0.protoObject})
        }
    }
    init(from protoObject: Signal_Session.Chain) throws {
//        guard protoObject.hasChainKey && protoObject.hasSenderRatchetKey && protoObject.hasSenderRatchetKeyPrivate else {
//            throw SignalError(.invalidProtoBuf, "Invalid ProtoBuf Object for RecieverChain Object")
//        }
        self.ratchetKey = try PublicKey(from: protoObject.senderRatchetKey)
        self.chainKey = try RatchetChainKey(from: protoObject.chainKey)
        self.messageKeys = try protoObject.messageKeys.map({try RatchetMessageKeys(from: $0)})
    }
}

extension ReceiverChain: Equatable {
    public static func ==(lhs: ReceiverChain, rhs: ReceiverChain) -> Bool {
        return lhs.messageKeys == rhs.messageKeys && lhs.chainKey == rhs.chainKey && lhs.ratchetKey == rhs.ratchetKey
    }
}

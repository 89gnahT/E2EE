//
//  SessionState.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public typealias RatchetIdentityKeyPair = KeyPair

struct SymmetricParameters {
    var ourIdentityKey: RatchetIdentityKeyPair
    var ourBaseKey: KeyPair
    var ourRatchetKey: KeyPair
    var theirBaseKey: PublicKey
    var theirRatchetKey: PublicKey
    var theirIdentityKey: PublicKey
    var isAlice: Bool {
        return ourBaseKey.publicKey < theirBaseKey //WARNING
    }
}

final class SessionState: ProtocolBufferEquivalent {
    private static let maxRecieverChains = 5
    private static let keyInfo = "WhisperSecureText".data(using: .utf8)!
    var previousCounter: UInt32 = 0
    var localIdentity: PublicKey?
    var remoteIdentity: PublicKey?
    var rootKey: RatchetRootKey?
    var senderChain: SenderChain?
    var receiverChains: [ReceiverChain]
    var pendingPreKey: PendingPreKey?
    var aliceBaseKey: PublicKey?
    
    init() {
        self.receiverChains = [ReceiverChain]()
    }
    
    func receiverChain(for senderEmphemeralKey: PublicKey) -> ReceiverChain? {
        for chain in receiverChains {
            if chain.ratchetKey == senderEmphemeralKey {
                return chain
            }
        }
        return nil
    }
    
    func add(receiverChain: ReceiverChain) {
        receiverChains.insert(receiverChain, at: 0)
        if receiverChains.count > SessionState.maxRecieverChains {
            receiverChains.removeLast(receiverChains.count - SessionState.maxRecieverChains)
        }
    }
    
    func set(chainKey: RatchetChainKey, for senderEmphemeralKey: PublicKey) throws {
        for index in 0..<receiverChains.count {
            if receiverChains[index].ratchetKey == senderEmphemeralKey {
                receiverChains[index].chainKey = chainKey
                return
            }
        }
        throw SignalError(.unknown, "Couldn't find receiver chain to set chain key on")
    }
    
    func set(messageKeys: RatchetMessageKeys, for senderEphemeral: PublicKey) {
        if let chain = receiverChain(for: senderEphemeral) {
            chain.add(messageKey: messageKeys)
        }
    }
    
    func removeMessageKeys(for senderEmphemeral: PublicKey, and counter: UInt32) -> RatchetMessageKeys? {
        guard let chain = receiverChain(for: senderEmphemeral) else { return nil }
        return chain.removeMessageKey(for: counter)
    }
    
    func receiverChainKey(for senderEmphemeral: PublicKey) -> RatchetChainKey? {
        return receiverChain(for: senderEmphemeral)?.chainKey
    }
    
    func set(receiverChainKey: RatchetChainKey, for senderEphemeral: PublicKey) throws {
        guard let node = receiverChain(for: senderEphemeral) else {
            throw SignalError(.unknown, "Couldn't find receiver chain to set chain key on");
        }
        node.chainKey = receiverChainKey
    }
    
    func aliceInitialize(ourIdentityKey: RatchetIdentityKeyPair, ourBaseKey: KeyPair, theirIdentityKey: PublicKey, theirSignedPreKey: PublicKey, theirOneTimePreKey: PublicKey?, theirRatchetKey: PublicKey) throws {
        let sendingRatchetKey = try KeyPair()
        let secret1 = Data(repeating: 0xFF, count: 32)
        let secret2 = try theirSignedPreKey.calculateAgreement(privateKey: ourIdentityKey.privateKey)
        let secret3 = try theirIdentityKey.calculateAgreement(privateKey: ourBaseKey.privateKey)
        let secret4 = try theirSignedPreKey.calculateAgreement(privateKey: ourBaseKey.privateKey)
        let secret5 = try theirOneTimePreKey?.calculateAgreement(privateKey: ourBaseKey.privateKey) ?? Data()
        let secret = secret1 + secret2 + secret3 + secret4 + secret5
        let (derivedRoot, derivedChain) = try calculateDerivedKeys(secret: secret)
        let (sendingChainRoot, sendingChainKey) = try derivedRoot.createChain(theirRatchetKey: theirRatchetKey, ourRatchetKey: sendingRatchetKey.privateKey)
        add(receiverChain: ReceiverChain(ratchetKey: theirRatchetKey, chainKey: derivedChain))
        self.remoteIdentity = theirIdentityKey
        self.localIdentity = ourIdentityKey.publicKey
        self.senderChain = SenderChain(ratchetKey: sendingRatchetKey, chainKey: sendingChainKey)
        self.rootKey = sendingChainRoot
    }
    
    func bobInitialize(ourIdentityKey: RatchetIdentityKeyPair, ourSignedPreKey: KeyPair, ourOneTimePreKey: KeyPair?, ourRatchetKey: KeyPair, theirIdentityKey: PublicKey, theirBaseKey: PublicKey) throws {
        let secret1 = Data(repeating: 0xFF, count: 32)
        let secret2 = try theirIdentityKey.calculateAgreement(privateKey: ourSignedPreKey.privateKey)
        let secret3 = try theirBaseKey.calculateAgreement(privateKey: ourIdentityKey.privateKey)
        let secret4 = try theirBaseKey.calculateAgreement(privateKey: ourSignedPreKey.privateKey)
        let secret5 = try ourOneTimePreKey?.privateKey.calculateAgreement(publicKey: theirBaseKey) ?? Data()
        let secret = secret1 + secret2 + secret3 + secret4 + secret5
        let (derivedRoot, derivedChain) = try calculateDerivedKeys(secret: secret)
        self.remoteIdentity = theirIdentityKey
        self.localIdentity = ourIdentityKey.publicKey
        self.senderChain = SenderChain(ratchetKey: ourRatchetKey, chainKey: derivedChain)
        self.rootKey = derivedRoot
    }
    
    func symmetricInitialize(parameters params: SymmetricParameters) throws {
        if params.isAlice {
            try aliceInitialize(ourIdentityKey: params.ourIdentityKey, ourBaseKey: params.ourBaseKey, theirIdentityKey: params.theirIdentityKey, theirSignedPreKey: params.theirBaseKey, theirOneTimePreKey: nil, theirRatchetKey: params.theirRatchetKey)
        } else {
            try bobInitialize(ourIdentityKey: params.ourIdentityKey, ourSignedPreKey: params.ourBaseKey, ourOneTimePreKey: nil, ourRatchetKey: params.ourRatchetKey, theirIdentityKey: params.theirIdentityKey, theirBaseKey: params.theirBaseKey)
        }
    }
    
    private func calculateDerivedKeys(secret: Data) throws -> (rootKey: RatchetRootKey, chainKey: RatchetChainKey) {
        let salt = Data(count: RatchetChainKey.hashOutputSize)
        return try HKDF.chainAndRootKey(material: secret, salt: salt, info: SessionState.keyInfo)
    }
    
    var protoObject: Signal_Session {
        return Signal_Session.with {
            if let item = self.localIdentity {
                $0.localIdentityPublic = item.data
            }
            if let item = self.remoteIdentity {
                $0.remoteIdentityPublic = item.data
            }
            if let item = self.rootKey {
                $0.rootKey = item.protoData()
            }
            $0.previousCounter = self.previousCounter
            if let item = self.senderChain {
                $0.senderChain = item.protoObject
            }
            $0.receiverChains = receiverChains.map {$0.protoObject}
            if let item = self.pendingPreKey {
                $0.pendingPreKey = item.protoObject
            }
            if let item = self.aliceBaseKey {
                $0.aliceBaseKey = item.data
            }
        }
    }
    
    init(from protoObject: Signal_Session) throws {
        if protoObject.hasLocalIdentityPublic {
            self.localIdentity = try PublicKey(from: protoObject.localIdentityPublic)
        }
        if protoObject.hasRemoteIdentityPublic {
            self.remoteIdentity = try PublicKey(from: protoObject.remoteIdentityPublic)
        }
        if protoObject.hasRootKey {
            self.rootKey = RatchetRootKey(from: protoObject.rootKey)
        }
        self.previousCounter = protoObject.previousCounter
        if protoObject.hasSenderChain {
            self.senderChain = try SenderChain(from: protoObject.senderChain)
        }
        self.receiverChains = try protoObject.receiverChains.map {
            try ReceiverChain(from: $0)
        }
        if protoObject.hasPendingPreKey {
            self.pendingPreKey = try PendingPreKey(from: protoObject.pendingPreKey)
        }
        if protoObject.hasAliceBaseKey {
            self.aliceBaseKey = try PublicKey(from: protoObject.aliceBaseKey)
        }
    }
}

extension SessionState: Equatable {
    static func ==(a: SessionState, b: SessionState) -> Bool {
        guard a.previousCounter == b.previousCounter else {
            return false
        }
        guard a.localIdentity == b.localIdentity, a.remoteIdentity == b.remoteIdentity, a.rootKey == b.rootKey, a.senderChain == b.senderChain else {
            return false
        }
        guard a.receiverChains == b.receiverChains, a.pendingPreKey == b.pendingPreKey, a.aliceBaseKey == b.aliceBaseKey else {
            return false
        }
        return true
    }
}

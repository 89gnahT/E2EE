//
//  SessionCipher.swift
//  E2EE
//
//  Created by CPU11899 on 11/1/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct SessionCipher<Context: KeyStore> {
    private var store: Context
    private var remoteAddress: Context.Address
    
    public init(store: Context, remoteAddress: Context.Address) {
        self.store = store
        self.remoteAddress = remoteAddress
    }
    
    public func encrypt(_ message: Data) throws -> CipherTextMessage {
        let record = try loadSession()
        guard let senderChain = record.state.senderChain else {
            throw SignalError(.unknown, "No sender chain for session state")
        }
        let chainKey = senderChain.chainKey
        let messageKeys = try chainKey.messageKeys()
        let senderEphemeral = senderChain.ratchetKey.publicKey
        let ciphertext = try getCipherText(messageKeys: messageKeys, plainText: message)
        
        guard let localIdentityKey = record.state.localIdentity, let remoteIdentityKey = record.state.remoteIdentity else {
            throw SignalError(.unknown, "No local or remote identity in state")
        }
        
        let resultMessage = try SignalMessage(macKey: messageKeys.macKey, senderRatchetKey: senderEphemeral, counter: chainKey.index, previousCounter: record.state.previousCounter, cipherText: ciphertext, senderIdentityKey: localIdentityKey, receiverIdentityKey: remoteIdentityKey)
        
        let preKeyMessage: PreKeySignalMessage?
        if let pendingPreKey = record.state.pendingPreKey {
            preKeyMessage = PreKeySignalMessage(preKeyId: pendingPreKey.preKeyId, signedPreKeyId: pendingPreKey.signedPreKeyId, baseKey: pendingPreKey.baseKey, identityKey: localIdentityKey, message: resultMessage)
        } else {
            preKeyMessage = nil
        }
        
        let nextChainKey = try chainKey.next()
        record.state.senderChain?.chainKey = nextChainKey
        try store.sessionStore.store(session: record, for: remoteAddress)
        if preKeyMessage != nil {
            return try preKeyMessage!.baseMessage()
        }
        return try resultMessage.baseMessage()
    }
    
    public func decrypt(_ message: CipherTextMessage) throws -> Data {
        switch message.type {
        case .preKey:
            let mess = try PreKeySignalMessage(from: message.data)
            return try decrypt(preKeySignalMessage: mess)
        case .signal:
            let mess = try SignalMessage(from: message.data)
            return try decrypt(signalMessage: mess)
        default:
            throw SignalError(.invalidType, "Not a PreKeySignalMessage or SignalMessage")
        }
        
    }
    
    func decrypt(preKeySignalMessage ciphertext: PreKeySignalMessage) throws -> Data {
        let record = try loadSession()
        
        let builder = SessionBuilder(remoteAddress: remoteAddress, store: store)
        let unsignedPreKeyId = try builder.process(preKeySignalMessage: ciphertext, sessionRecord: record)
        let plaintext = try decrypt(from: record, and: ciphertext.message)
        try store.sessionStore.store(session: record, for: remoteAddress)
        if let id = unsignedPreKeyId, store.preKeyStore.containPreKey(for: id) {
            try store.preKeyStore.removePreKey(for: id)
        }
        return plaintext
    }
    
    func decrypt(signalMessage ciphertext: SignalMessage) throws -> Data {
        let record = try loadSession()
        let plaintext = try decrypt(from: record, and: ciphertext)
        
        try store.sessionStore.store(session: record, for: remoteAddress)
        return plaintext
    }
    
    public func process(preKeyBundle bundle: SessionPreKeyBundle) throws {
        let builder = SessionBuilder(remoteAddress: remoteAddress, store: store)
        try builder.process(preKeyBundle: bundle)
    }
    
    private func loadSession() throws -> SessionRecord {
        return try store.sessionStore.loadSession(for: remoteAddress)
    }
    
    private func decrypt(from record:SessionRecord, and signalMessage: SignalMessage) throws -> Data {
        do {
            return try decrypt(from: record.state, and: signalMessage)
        } catch let error as SignalError where error.type == .invalidMessage {
            
        }
        
        for index in 0..<record.previousStates.count {
            let state = record.previousStates[index]
            do {
                let plaintext = try decrypt(from: state, and: signalMessage)
                record.promoteState(state: state)
                return plaintext
            } catch let error as SignalError where error.type == .invalidMessage {
                
            }
        }
        throw SignalError(.invalidMessage, "No valid sessions")
    }
    
    private func decrypt(from state: SessionState, and signalMessage: SignalMessage) throws -> Data {
        
        guard state.senderChain != nil else {
            throw SignalError(.invalidMessage, "Uninitialized session!")
        }

        let chainKey = try getOrCreateChainKey(state: state, theirEphemeral: signalMessage.senderRatchetKey)

        let messageKeys = try getOrCreateMessageKeys(
            state: state,
            theirEphemeral: signalMessage.senderRatchetKey,
            chainKey: chainKey,
            counter: signalMessage.counter)

        guard let remoteIdentity = state.remoteIdentity else {
            throw SignalError(.unknown, "No remote identity in state")
        }
        guard let localIdentity = state.localIdentity else {
            throw SignalError(.unknown, "No local identity in state")
        }
        guard try signalMessage.verifyMac(
            senderIdentityKey: remoteIdentity,
            receiverIdentityKey: localIdentity,
            macKey: messageKeys.macKey) else {
                throw SignalError(.invalidMessage, "Message mac not verified")
        }

        let plaintext = try getPlainText(messageKeys: messageKeys, cipherText: signalMessage.cipherText)

        state.pendingPreKey = nil
        return plaintext
    }
    
    private func getOrCreateMessageKeys(state: SessionState, theirEphemeral: PublicKey, chainKey: RatchetChainKey, counter: UInt32) throws -> RatchetMessageKeys {
        if chainKey.index > counter {
            guard let messageKeysResult = state.removeMessageKeys(for: theirEphemeral, and: counter) else {
                throw SignalError(.duplicateMessage, "Received message with old counter: \(chainKey.index), \(counter)")
            }
            return messageKeysResult
        }
        
        if counter - chainKey.index > SenderKeyState.messageKeyMaximum {
            throw SignalError(.invalidMessage, "Over \(SenderKeyState.messageKeyMaximum) message into future")
        }
        
        var currentChainKey = chainKey
        
        while currentChainKey.index < counter {
            let messageKeysResult = try currentChainKey.messageKeys()
            state.set(messageKeys: messageKeysResult, for: theirEphemeral)
            currentChainKey = try currentChainKey.next()
        }
        let nextChainKey = try currentChainKey.next()
        try state.set(receiverChainKey: nextChainKey, for: theirEphemeral)
        return try currentChainKey.messageKeys()
    }
    
    private func getOrCreateChainKey(state: SessionState, theirEphemeral: PublicKey) throws -> RatchetChainKey {
        if let resultKey = state.receiverChain(for: theirEphemeral)?.chainKey {
            return resultKey
        }
        
        guard let rootKey = state.rootKey else {
            throw SignalError(.unknown, "No root key in state")
        }
        
        guard let senderChain = state.senderChain else {
            throw SignalError(.unknown, "Not chain key in state")
        }
        
        let ourEphemeral = senderChain.ratchetKey
        let (receiverRootKey, receiverChainKey) = try rootKey.createChain(theirRatchetKey: theirEphemeral, ourRatchetKey: ourEphemeral.privateKey)
        let ourNewEphemeral = try KeyPair()
        
        let (senderRootKey, senderChainKey) = try receiverRootKey.createChain(theirRatchetKey: theirEphemeral, ourRatchetKey: ourNewEphemeral.privateKey)
        
        state.rootKey = senderRootKey
        let receiverChain = ReceiverChain(ratchetKey: theirEphemeral, chainKey: receiverChainKey)
        state.add(receiverChain: receiverChain)
        
        let previousChainKey = senderChain.chainKey
        if previousChainKey.index > 0 {
            state.previousCounter = previousChainKey.index - 1
        } else {
            state.previousCounter = 0
        }
        
        state.senderChain = SenderChain(ratchetKey: ourNewEphemeral, chainKey: senderChainKey)
        return receiverChainKey
    }
    
    private func getCipherText(messageKeys: RatchetMessageKeys, plainText: Data) throws -> Data {
        let crypto = CommonSignalCrypto()
        return try crypto.encrypt(message: plainText, with: .AES_CTRnoPadding, key: messageKeys.cipherKey, iv: messageKeys.iv)
    }
    
    private func getPlainText(messageKeys: RatchetMessageKeys, cipherText: Data) throws -> Data {
        let crypto = CommonSignalCrypto()
        return try crypto.decrypt(message: cipherText, with: .AES_CTRnoPadding, key: messageKeys.cipherKey, iv: messageKeys.iv)
    }
}

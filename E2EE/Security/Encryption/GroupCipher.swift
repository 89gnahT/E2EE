//
//  GroupCipher.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 11/1/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct GroupCipher<Context: GroupKeyStore> {
    private let store: Context
    private let address: Context.GroupAddress
    private let crypto = CommonSignalCrypto()
    
    init(address: Context.GroupAddress, store: Context) {
        self.store = store
        self.address = address
    }
    
    public func process(message: CipherTextMessage) throws {
        guard message.type == .senderKeyDistribution else {
            throw SignalError(.invalidType, "Invalid message type \(message.type)")
        }
        let object = try SenderKeyDistributionMessage(from: message.data)
        try process(distributionMessage: object)
    }
    
    public func process(distributionMessage: SenderKeyDistributionMessage) throws {
        let senderKey = try store.senderKeyStore.senderKey(for: address) ?? SenderKeyRecord()
        senderKey.addState(id: distributionMessage.id, iteration: distributionMessage.iteration, chainKey: distributionMessage.chainKey, signaturePublicKey: distributionMessage.signatureKey, signaturePrivateKey: nil)
        try store.senderKeyStore.store(senderKey: senderKey, for: address)
    }
    
    public func createSession() throws -> SenderKeyDistributionMessage {
        let record = try store.senderKeyStore.senderKey(for: address) ?? SenderKeyRecord()
        if record.isEmpty {
            let senderKeyId = try crypto.generateSenderKeyId()
            let senderKey = try crypto.generateSenderKey()
            let senderSigningKey = try crypto.generateSenderSigningKey()
            record.setSenderKey(id: senderKeyId,
                                iteration: 0,
                                chainKey: senderKey,
                                signatureKeyPair: senderSigningKey)
            try store.senderKeyStore.store(senderKey: record, for: address)
        }

        guard let state = record.state else {
            throw SignalError(.unknown, "No state in record")
        }

        let chainKey = state.chainKey
        let seed = chainKey.chainKey

        return SenderKeyDistributionMessage(
            id: state.keyId,
            iteration: chainKey.iteration,
            chainKey: seed,
            signatureKey: state.signaturePublicKey)
    }
    
    public func encrypt(_ plaintext: Data) throws -> CipherTextMessage {
        let record = try loadRecord()
        guard let state = record.state else {
            throw SignalError(.unknown, "No state in session record")
        }

        guard let signingKeyPrivate = state.signaturePrivateKey else {
            throw SignalError(.invalidKey, "No signature private key")
        }
        // Get message key and advance chain key
        let senderKey = try state.chainKey.messageKey()
        let ciphertext = try crypto.encrypt(
            message: plaintext,
            with: .AES_CBCwithPKCS5,
            key: senderKey.cipherKey,
            iv: senderKey.iv)

        let resultMessage = try SenderKeyMessage(
            keyId: state.keyId,
            iteration: senderKey.iteration,
            cipherText: Data(ciphertext),
            signatureKey: signingKeyPrivate).baseMessage()

        try store.senderKeyStore.store(senderKey: record, for: address)
        return resultMessage
    }
    
    public func decrypt(ciphertext: SenderKeyMessage) throws -> Data {
        let record = try loadRecord()
        let crypto = CommonSignalCrypto()
        guard let state = record.state(for: ciphertext.keyId) else {
            throw SignalError(.invalidId, "No state for key id")
        }

        guard try ciphertext.verify(signatureKey: state.signaturePublicKey) else {
            throw SignalError(.invalidSignature, "Invalid message signature")
        }
        let senderKey = try state.senderKey(for: ciphertext.iteration)

        let decrypted = try crypto.decrypt(
            message: ciphertext.cipherText,
            with: .AES_CBCwithPKCS5,
            key: senderKey.cipherKey,
            iv: senderKey.iv)

        try store.senderKeyStore.store(senderKey: record, for: address)
        return decrypted
    }
    
    private func loadRecord() throws -> SenderKeyRecord {
        guard let record: SenderKeyRecord = try store.senderKeyStore.senderKey(for: address) else {
            throw SignalError(.noSession, "No existing session")
        }
        return record
    }
}

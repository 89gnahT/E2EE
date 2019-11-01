//
//  SessionBuilder.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct SessionBuilder<Context: KeyStore> {
    var store: Context
    var remoteAddress: Context.Address
    
    init(remoteAddress: Context.Address, store: Context) {
        self.remoteAddress = remoteAddress
        self.store = store
    }
    
    func process(preKeySignalMessage message: PreKeySignalMessage, sessionRecord record: SessionRecord) throws -> UInt32? {
        let theirIdentityKey = message.identityKey
        guard try store.identityKeyStore.isTrusted(identity: theirIdentityKey, for: remoteAddress) else {
            throw SignalError(.untrustedIdentity, "Untrusted identity for \(remoteAddress)")
        }
        let result = try process(preKeySignalMessageV3: message, record: record)
        try store.identityKeyStore.store(identity: theirIdentityKey, for: remoteAddress)
        return result
    }
    
    private func process(preKeySignalMessageV3 message: PreKeySignalMessage, record: SessionRecord) throws -> UInt32? {
        if record.hasSessionState(baseKey: message.baseKey) {
            return nil
        }
        let ourSignedPreKey: SessionSignedPreKey = try store.signedPreKeyStore.signedPreKey(for: message.signedPreKeyId)
        let ourIdentityKey = try store.identityKeyStore.getIdentityKey()
        let ourOneTimePreKey: SessionPreKey?
        if let preKeyID = message.preKeyId {
            ourOneTimePreKey = try store.preKeyStore.preKey(for: preKeyID)
        } else {
            ourOneTimePreKey = nil
        }
        if !record.isFresh {
            record.archiveCurrentState()
        }
        try record.state.bobInitialize(ourIdentityKey: ourIdentityKey, ourSignedPreKey: ourSignedPreKey.keyPair, ourOneTimePreKey: ourOneTimePreKey?.keyPair, ourRatchetKey: ourSignedPreKey.keyPair, theirIdentityKey: message.identityKey, theirBaseKey: message.baseKey)
        record.state.aliceBaseKey = message.baseKey
        if message.preKeyId != SessionPreKey.mediumMaxValue {
            return message.preKeyId
        }
        return nil
    }
    
    func process(preKeyBundle bundle: SessionPreKeyBundle) throws {
        guard try store.identityKeyStore.isTrusted(identity: bundle.identityKey, for: remoteAddress) else {
            throw SignalError(.untrustedIdentity, "Untrusted identity for pre key bundle")
        }
        guard bundle.identityKey.verify(signature: bundle.signedPreKeySignature, for: bundle.signedPreKeyPublic.data) else {
            throw SignalError(.invalidSignature, "Invalid signal pre key bundle")
        }
        let session: SessionRecord = try store.sessionStore.loadSession(for: remoteAddress)
        let ourBaseKey = try KeyPair()
        let preKeyId = bundle.preKeyPublic != nil ? bundle.preKeyId : nil
        let ourIdentityKey = try store.identityKeyStore.getIdentityKey()
        if !session.isFresh {
            session.archiveCurrentState()
        }
        try session.state.aliceInitialize(ourIdentityKey: ourIdentityKey, ourBaseKey: ourBaseKey, theirIdentityKey: bundle.identityKey, theirSignedPreKey: bundle.signedPreKeyPublic, theirOneTimePreKey: bundle.preKeyPublic, theirRatchetKey: bundle.signedPreKeyPublic)
        session.state.pendingPreKey = PendingPreKey(preKeyId: preKeyId, signedPreKeyId: bundle.signedPreKeyId, baseKey: ourBaseKey.publicKey)
        session.state.aliceBaseKey = ourBaseKey.publicKey
        try store.sessionStore.store(session: session, for: remoteAddress)
        try store.identityKeyStore.store(identity: bundle.identityKey, for: remoteAddress)
    }
}

//
//  SenderKeyRecord.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

final class SenderKeyRecord {
    private static let maxState = 5
    private var states = [SenderKeyState]()
    var state: SenderKeyState? {
        return states.first
    }
    var isEmpty: Bool {
        return states.count == 0
    }
    init() {}
    
    func state(for id:UInt32) -> SenderKeyState? {
        for item in states {
            if item.keyId == id {
                return state
            }
        }
        return nil
    }
    
    func setSenderKey(id: UInt32, iteration: UInt32, chainKey: Data, signatureKeyPair: KeyPair) {
        self.states = []
        addState(id: id, iteration: iteration, chainKey: chainKey, signatureKeyPair: signatureKeyPair)
    }
    
    func addState(id: UInt32, iteration: UInt32, chainKey: Data, signaturePublicKey: PublicKey, signaturePrivateKey: PrivateKey?) {
        let chainKeyElement = SenderChainKey(iteration: iteration, chainKey: chainKey)
        let state = SenderKeyState(keyId: id, chainKey: chainKeyElement, signaturePublicKey: signaturePublicKey, signaturePrivateKey: signaturePrivateKey)
        states.insert(state, at: 0)
        if states.count > SenderKeyRecord.maxState {
            states = Array(states[0..<SenderKeyRecord.maxState])
        }
    }
    
    func addState(id: UInt32, iteration: UInt32, chainKey: Data, signatureKeyPair: KeyPair) {
        addState(id: id, iteration: iteration, chainKey: chainKey, signaturePublicKey: signatureKeyPair.publicKey, signaturePrivateKey: signatureKeyPair.privateKey)
    }
}

extension SenderKeyRecord: ProtocolBufferEquivalent {
    var protoObject: Signal_SenderKeyRecord {
        return Signal_SenderKeyRecord.with {
            $0.senderKeyStates = self.states.map{ $0.protoObject }
        }
    }
    
    convenience init(from protoObject: Signal_SenderKeyRecord) throws {
        self.init()
        self.states = try protoObject.senderKeyStates.map({(senderKeyState: Signal_SenderKeyState) -> SenderKeyState in
            return try SenderKeyState(from: senderKeyState)
        })
    }
}

extension SenderKeyRecord: Equatable {
    
    static func ==(a: SenderKeyRecord, b: SenderKeyRecord) -> Bool {
        return a.states == b.states
    }
}

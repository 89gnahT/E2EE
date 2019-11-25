//
//  SignalSenderKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class SignalSenderKeyStore: SenderKeyStore {
    
    typealias Address = SignalSenderKeyName
    private var senderKeys = [Address: Data]()
    
    func store(senderKey: Data, for address: SignalSenderKeyName) throws {
        senderKeys[address] = senderKey
    }
    
    func senderKey(for address: SignalSenderKeyName) -> Data? {
        return senderKeys[address]
    }
}

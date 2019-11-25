//
//  SignalSessionKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class SignalSessionStore: SessionStore {
    typealias Address = SignalAddress
    private var sessions = [Address: Data]()
    
    func loadSession(for address: Address) throws -> Data? {
        return sessions[address]
    }
    
    func store(session: Data, for address: Address) throws {
        sessions[address] = session
    }
    
    func deleteSession(for address: Address) throws {
        sessions[address] = nil
    }
    
    func containSession(for address: Address) -> Bool {
        return sessions[address] != nil
    }
}

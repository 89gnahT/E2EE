//
//  SessionStore.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public protocol SessionStore: class {
    associatedtype Address: Hashable
    func loadSession(for address: Address) throws -> Data?
    func store(session: Data, for address: Address) throws
    func deleteSession(for address: Address) throws
}

extension SessionStore {
    func loadSession(for address: Address) throws -> SessionRecord {
        guard let record = try loadSession(for: address) else {
            return SessionRecord(state: nil)
        }
        return try SessionRecord(from: record)
    }
    
    func store(session: SessionRecord, for address: Address) throws {
        let data = try session.protoData()
        try store(session: data, for: address)
    }
}

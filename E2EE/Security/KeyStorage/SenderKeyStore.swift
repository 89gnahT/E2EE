//
//  SenderKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public protocol SenderKeyStore: class {
    associatedtype Address: Hashable
    
    func senderKey(for address: Address) -> Data?
    func store(senderKey: Data, for address: Address) throws
}

extension SenderKeyStore {
    func senderKey(for address: Address) throws -> SenderKeyRecord? {
        guard let senderKey = senderKey(for: address) else { return nil }
        return try SenderKeyRecord(from: senderKey)
    }
    
    func store(senderKey: SenderKeyRecord, for address: Address) throws {
        let data = try senderKey.protoData()
        try store(senderKey: data, for: address)
    }
}

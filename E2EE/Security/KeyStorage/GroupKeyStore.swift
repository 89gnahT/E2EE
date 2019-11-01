//
//  GroupKeyStore.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public protocol GroupKeyStore: KeyStore {
    associatedtype GroupAddress: CustomStringConvertible
    associatedtype SenderKeyStoreType: SenderKeyStore where SenderKeyStoreType.Address == GroupAddress
    var senderKeyStore: SenderKeyStoreType { get }
    
}

//
//  FirebaseUserStorage.swift
//  E2EE
//
//  Created by CPU11899 on 12/9/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public class FirebaseUserStorage {
    let userAddress: SignalAddress
    let keyBundle: FirebaseKeyStorage
    
    init(address: SignalAddress, keyBundle: FirebaseKeyStorage) {
        self.userAddress = address
        self.keyBundle = keyBundle
    }
    
    func toDictionary() -> Dictionary<String, Any> {
        return ["user_address": self.userAddress.toDictionary(),
                "key_bundle": self.keyBundle.toDictionary()]
    }
}

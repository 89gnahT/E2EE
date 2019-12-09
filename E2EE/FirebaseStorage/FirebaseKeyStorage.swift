//
//  FirebaseKeyStorage.swift
//  E2EE
//
//  Created by CPU11899 on 12/9/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public class FirebaseKeyStorage {
    let id_key: Data
    let medium_term_cycle_key: Data
    let one_time_keys: [Data]
    
    init(identityKey: Data, SignedPreKey: Data, OneTimePreKeys: [Data]) {
        id_key = identityKey
        medium_term_cycle_key = SignedPreKey
        one_time_keys = OneTimePreKeys
    }
    
    func toDictionary() -> Dictionary<String, Any>? {
        guard let identitiKey = String(bytes: id_key, encoding: .utf8) else {
            return nil
        }
        guard let signedKey = String(bytes: medium_term_cycle_key, encoding: .utf8) else {
            return nil
        }
        return ["id_key": identitiKey,
                "medium_term_cycle_key": signedKey,
                "one_time_keys": self.one_time_keys] as [String : Any]
    }
}

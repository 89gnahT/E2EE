//
//  CurrentLoginUser.swift
//  E2EE
//
//  Created by CPU11899 on 12/9/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import Firebase

class CurrentLoginUser {
    let keyBundle: SessionPreKeyBundle
    let remoteIdentityBundle: FirebaseUserStorage
    var ref: DatabaseReference!
    
    init(keyBundle: SessionPreKeyBundle, firebaseKey: FirebaseUserStorage) {
        self.keyBundle = keyBundle
        remoteIdentityBundle = firebaseKey
    }
    
    func uploadKeyBunde(_ name: String) {
        ref = Database.database().reference()
        //let user = ref.child(name)
        ref.child(name).setValue(self.remoteIdentityBundle.toDictionary())
    }
}

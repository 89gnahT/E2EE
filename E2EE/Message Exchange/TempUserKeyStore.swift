//
//  TempUser.swift
//  E2EE
//
//  Created by Thang on 15/11/2019.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class TempUserKeyStore {
    let cryptoSignal : CommonSignalCrypto
    let identityKeyPair: KeyPair
    
    init() {
        let protoObject_identityKeyPair: Data
        do {
            protoObject_identityKeyPair = try cryptoSignal.generateIdentityKeyPair()
            self.identityKeyPair = try KeyPair.init(from: protoObject_identityKeyPair)
        } catch {
            print("Error generating identity key pair. TODO: create keypair again.")
        }
    }
    
    func getPublicKey() -> PublicKey {
        return identityKeyPair.publicKey
    }
    
    func createPrekeys(count : Int? = 10) -> [SessionPreKey] {
        return try cryptoSignal.generatePreKeys(start: 45, count: count)
    }
}

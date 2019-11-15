//
//  SPWrapper.swift
//  E2EE
//
//  Created by Thang on 15/11/2019.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class SPWrapper {
    
    let cryptoSignal : CommonSignalCrypto
    
    init() {
        cryptoSignal = CommonSignalCrypto()
    }
    
    func generateIdentityKeyPair() throws -> Data {
        var identity: Data
        do {
            identity = try cryptoSignal.generateIdentityKeyPair()
        } catch let error {
            print("Throw called when generating Identity key pair ")
            throw error
        }
        return identity
    }

    
}

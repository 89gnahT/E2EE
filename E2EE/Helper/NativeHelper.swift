//
//  NativeHelper.swift
//  E2EE
//
//  Created by CPU11899 on 10/18/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import CryptoKit

protocol CryptoProtocol : NSObject {
    func hashMethod(data : Data) throws -> Data // Example: SHA256, SHA512, ...
    func hmacAuthentication(data : Data) throws -> Data // Example: hmacSHA256, hmacbcrypt, hmacMD5, ...
    func crtypoAlgorithm(data : Data) -> Data //Example: AES, DES, IDEA, ...
}

public class Crypto : NSObject {
    override public init() {
        super.init()
    }
}

extension Crypto : CryptoProtocol {
    func hmacAuthentication(data: Data) throws -> Data {
        <#code#>
    }
    
    func crtypoAlgorithm(data: Data) -> Data {
        <#code#>
    }
    
    
    //implement SHA512
    func hashMethod(data: Data) throws -> Data {
        if #available(iOS 13.0, *) {
            let hashData = SHA512.hash(data: data)
            let hashValue = hashData.hashValue
            
        } else {
            
        }
        
        
    }
}

//
//  NativeHelper.swift
//  E2EE
//
//  Created by CPU11899 on 10/18/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

protocol CryptoProtocol : NSObject {
    func hashMethod(data : Data) throws -> Data? // Example: SHA256, SHA512, ...
    func hmacAuthentication(data : Data, salt: Data) throws -> Data? // Example: hmacSHA256, hmacbcrypt, hmacMD5, ...
    func encryptAlgorithm(data : Data, keyCipher: Data) throws -> Data? //Example: AES, DES, IDEA, ...
    func decryptAlgorithm(data : Data, keyCipher: Data) throws -> Data? //Example: AES, DES, IDEA, ...
}

public class Crypto : NSObject {
    override public init() {
        super.init()
    }
}

//var context = CCHmacContext()
//
//let bytes = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//withUnsafeMutablePointer(to: &context) { (ptr: UnsafeMutablePointer<CCHmacContext>) in
//    // Pointer to salt
//    salt.withUnsafeBytes { ptr2 in
//        let saltPtr = ptr2.baseAddress!
//        // Pointer to message
//        message.withUnsafeBytes { ptr3 in
//            let messagePtr = ptr3.baseAddress!
//            // Authenticate
//            CCHmacInit(ptr, CCHmacAlgorithm(kCCHmacAlgSHA256), saltPtr, salt.count)
//            CCHmacUpdate(ptr, messagePtr, message.count)
//            CCHmacFinal(ptr, UnsafeMutableRawPointer(mutating: bytes))
//        }
//    }
//}
//
//return Data(bytes)

extension Crypto : CryptoProtocol {
    
    //HMAC using SHA512
    func hmacAuthentication(data: Data, salt: Data) throws -> Data? {
        if #available(iOS 13.0, *) {
            let authenticationCode = HMAC<SHA512>.authenticationCode(for: data, using: SymmetricKey.init(data: salt))
            return Data(authenticationCode)
        } else {
            var context = CCHmacContext()
            let bytes = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            withUnsafeMutablePointer(to: &context, {(ptr : UnsafeMutablePointer<CCHmacContext>) in
                salt.withUnsafeBytes{ ptr2 in
                    let saltPtr = ptr2.baseAddress!
                    data.withUnsafeBytes({ptr3 in
                        let dataPtr = ptr3.baseAddress!
                        CCHmacInit(ptr, CCHmacAlgorithm(kCCHmacAlgSHA512), saltPtr, salt.count)
                        CCHmacUpdate(ptr, dataPtr, data.count)
                        CCHmacFinal(ptr, UnsafeMutableRawPointer(mutating: bytes))
                    })
                }
            })
            return Data(bytes)
        }
    }
    
    //cryptoAlgorithm using AES
    func encryptAlgorithm(data: Data, keyCipher: Data) throws -> Data? {
        if #available(iOS 13.0, *) {
            let encryptData = try! AES.GCM.seal(data, using: SymmetricKey(data: keyCipher), nonce: .none)
            return encryptData.ciphertext
        } else {
            
        }
        return nil
    }
    
    func decryptAlgorithm(data: Data, keyCipher: Data) throws -> Data? {
        if #available(iOS 13.0, *) {
            <#code#>
        } else {
            
        }
    }
    
    
    //implement SHA512
    func hashMethod(data: Data) throws -> Data? {
        if #available(iOS 13.0, *) {
            let hashData = SHA512.hash(data: data)
            return Data(hashData)
        } else {
            var context = CC_SHA512_CTX()
            return try withUnsafeMutablePointer(to: &context, {contextPtr in
                CC_SHA512_Init(contextPtr)
                let result: Int32 = data.withUnsafeBytes({ptr2 in
                    let dataPtr = ptr2.baseAddress!
                    return CC_SHA512_Update(contextPtr, dataPtr, CC_LONG(data.count))
                })
                guard result == 1 else {
                    print("Error")
                    return nil
                }
                var md = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
                let result2: Int32 = md.withUnsafeMutableBytes({ptr4 in
                    let a = ptr4.baseAddress?.assumingMemoryBound(to: UInt8.self)
                    return CC_SHA512_Final(a, contextPtr)
                })
                guard result2 == 1 else {
                    print("Error")
                    return nil
                }
                return md
            })
        }
    }
}

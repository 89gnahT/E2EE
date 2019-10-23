//
//  NativeHelper.swift
//  E2EE
//
//  Created by CPU11899 on 10/18/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import CommonCrypto

protocol CryptoProtocol : NSObject {
    func hashMethod(data : Data) throws -> Data? // Example: SHA256, SHA512, ...
    func hmacAuthentication(data : Data, salt: Data) throws -> Data? // Example: hmacSHA256, hmacbcrypt, hmacMD5, ...
    func encryptAlgorithm(data : Data, keyCipher: Data) throws -> Data? //Example: AES, DES, IDEA, ...
    func decryptAlgorithm(data : Data, keyCipher: Data) throws -> Data? //Example: AES, DES, IDEA, ...
}

enum Error : Swift.Error {
    case BadKeyLength
    case BadInputVectorLength
    case keyGenerator(status: Int)
    case cryptoFailed(status: CCCryptorStatus)
}

public class Crypto : NSObject {
    override public init() {
        super.init()
    }
}

struct AES256 {
    
    private var key : Data
    private var iv : Data
    
    public init (_ key : Data, _ iv : Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw Error.BadKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw Error.BadInputVectorLength
        }
        self.key = key
        self.iv = iv
    }
    
    public func encrypt (_ digest: Data) throws -> Data {
        return try crypt(digest, operation: CCOperation(kCCEncrypt))
    }
    
    public func decrypt (_ encrypted: Data) throws -> Data {
        return try crypt(encrypted, operation: CCOperation(kCCDecrypt))
    }
    
    private func crypt(_ input: Data, operation: CCOperation) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        input.withUnsafeBytes({(inputBuffer: UnsafeRawBufferPointer) -> () in
            let inputTypedBytes = inputBuffer.bindMemory(to: UInt8.self)
            let inputUnsafeBytes = inputTypedBytes.baseAddress!
            iv.withUnsafeBytes({(ivBuffer: UnsafeRawBufferPointer) -> () in
                let ivTypedBytes = ivBuffer.bindMemory(to: UInt8.self)
                let ivUnsafeBytes = ivTypedBytes.baseAddress!
                key.withUnsafeBytes({(keyBuffer: UnsafeRawBufferPointer) -> () in
                    let keyTypedBytes = keyBuffer.bindMemory(to: UInt8.self)
                    let keyUnsafeBytes = keyTypedBytes.baseAddress!
                    status = CCCrypt(operation, CCAlgorithm(kCCAlgorithmAES128), CCOptions(kCCOptionPKCS7Padding), keyUnsafeBytes, key.count, ivUnsafeBytes, inputUnsafeBytes, input.count, &outBytes, outBytes.count, &outLength)
                })
            })
        })
        guard status == kCCSuccess else {
            throw Error.cryptoFailed(status: status)
        }
        return Data(bytes: UnsafePointer<UInt8>(outBytes), count: outLength)
    }
    
    static func createKey(password: Data, salt: Data) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        password.withUnsafeBytes({(passwordBuffer : UnsafeRawBufferPointer) -> Void in
            let passwordTypedBytes = passwordBuffer.bindMemory(to: Int8.self)
            let passwordUnsafeBytes = passwordTypedBytes.baseAddress!
            salt.withUnsafeBytes({(saltBuffer : UnsafeRawBufferPointer) -> Void in
                let saltTypedBytes = saltBuffer.bindMemory(to: UInt8.self)
                let saltUnsafeBytes = saltTypedBytes.baseAddress!
                status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), passwordUnsafeBytes, password.count, saltUnsafeBytes, salt.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1), 10000, &derivedBytes, length)
            })
        })
        guard status == 0 else {
            throw Error.keyGenerator(status: Int(status))
        }
        return Data(bytes: UnsafePointer<UInt8>(derivedBytes), count: length)
    }
    
    static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes({(dataBuffer: UnsafeMutableRawBufferPointer) -> Int32 in
            let dataPointer = dataBuffer.baseAddress!
            return SecRandomCopyBytes(kSecRandomDefault, length, dataPointer)
        })
        assert(status == Int32(0))
        return data
    }
    
    static func randomIv() -> Data {
        return randomData(length: kCCBlockSizeAES128)
    }
    static func randomSalt() -> Data {
        return randomData(length: 8)
    }
}

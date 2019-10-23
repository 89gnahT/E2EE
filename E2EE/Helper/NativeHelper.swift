//
//  NativeHelper.swift
//  E2EE
//
//  Created by CPU11899 on 10/18/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import CommonCrypto
import Security

enum Error : Swift.Error {
    case BadKeyLength
    case BadInputVectorLength
    case keyGenerator(status: Int)
    case cryptoFailed(status: CCCryptorStatus)
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

enum hmacAlgorithm {
    case SHA1, SHA224, SHA256, SHA384, SHA512, MD5
    
    var algorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var length : Int32 {
        var result: Int32 = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        }
        return result
    }
}

struct hmacSHA256 {
    static func hmac(algorithm: hmacAlgorithm = .SHA256, message: Data, key: Data) -> Data? {
        var macData = Data(count: Int(algorithm.length))
        macData.withUnsafeMutableBytes({(macBuffer: UnsafeMutableRawBufferPointer) -> Void in
            let macBytes = macBuffer.baseAddress!
            message.withUnsafeBytes({(messBuffer: UnsafeRawBufferPointer) -> Void in
                let messBytes = messBuffer.baseAddress!
                key.withUnsafeBytes({(keyBuffer: UnsafeRawBufferPointer) -> Void in
                    let keyBytes = keyBuffer.baseAddress!
                    CCHmac(algorithm.algorithm, keyBytes, key.count, messBytes, message.count, macBytes)
                })
            })
        })
        return macData
//        macData.withUnsafeMutableBytes({macBytes in
//            message.withUnsafeBytes({messageBytes in
//                key.withUnsafeBytes({keyBytes in
//                    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes, key.count, messageBytes, message.count, macBytes)
//                })
//            })
//        })
    }
}


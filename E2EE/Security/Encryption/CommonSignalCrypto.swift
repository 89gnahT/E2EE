//
//  CommonSignalEncryption.swift
//  E2EE
//
//  Created by CPU11899 on 10/25/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import CommonCrypto

public enum SignalEncryptionScheme {
    case AES_CBCwithPKCS5
    case AES_CTRnoPadding
}

public struct CommonSignalCrypto {
    public func random(bytes: Int) throws -> Data {
        let random = [UInt8](repeating: 0, count: bytes)
        let result = SecRandomCopyBytes(nil, bytes, UnsafeMutableRawPointer(mutating: random))
        guard result == errSecSuccess else {
            throw SignalError(.noRandomBytes, "Error getting random bytes: \(result)")
        }
        return Data(random)
    }
    
    public func hmacSHA256(for message: Data, with salt: Data) throws -> Data {
        var context = CCHmacContext()
        let bytes = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeMutablePointer(to: &context, {(ptr: UnsafeMutablePointer<CCHmacContext>) in
            salt.withUnsafeBytes({(saltBuffer: UnsafeRawBufferPointer) -> Void in
                let saltPtr = saltBuffer.baseAddress!
                message.withUnsafeBytes({(messBuffer: UnsafeRawBufferPointer) -> Void in
                    let messPtr = messBuffer.baseAddress!
                    CCHmacInit(ptr, CCHmacAlgorithm(kCCHmacAlgSHA256), saltPtr, salt.count)
                    CCHmacUpdate(ptr, messPtr, message.count)
                    CCHmacFinal(ptr, UnsafeMutableRawPointer(mutating: bytes))
                })
            })
        })
        return Data(bytes)
    }
    
    public func sha512(for message: Data) throws -> Data {
        guard message.count > 0 else {
            throw SignalError(.invalidMessage, "Message length is 0")
        }
        var context = CC_SHA512_CTX()
        return try withUnsafeMutablePointer(to: &context, {(pointer: UnsafeMutablePointer<CC_SHA512_CTX>) -> Data in
            CC_SHA512_Init(pointer)
            let result: Int32 = message.withUnsafeBytes({(messBuffer: UnsafeRawBufferPointer) -> Int32 in
                let messPtr = messBuffer.baseAddress!
                return CC_SHA512_Update(pointer, messPtr, CC_LONG(message.count))
            })
            guard result == 1 else {
                throw SignalError(.digestError, "Error on SHA512 Update: \(result)")
            }
            var messDigest = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
            let result2: Int32 = messDigest.withUnsafeMutableBytes({(messDigestBuffer: UnsafeMutableRawBufferPointer) -> Int32 in
                let messDigestPtr = messDigestBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
                return CC_SHA512_Final(messDigestPtr, pointer)
            })
            guard result2 == 1 else {
                throw SignalError(.digestError, "Error on SHA512 Final: \(result2)")
            }
            return messDigest
        })
    }
    
    private func process(cbc message: Data, key: Data, iv: Data, encrypt: Bool) throws -> Data {
        let operation = encrypt ? CCOperation(kCCEncrypt) : CCOperation(kCCDecrypt)
        let dataLength = message.count + kCCBlockSizeAES128
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: dataLength, alignment: MemoryLayout<UInt8>.alignment)
        defer {
            ptr.deallocate()
        }
        var dataOutMoved: Int = 0
        let status: Int32 = key.withUnsafeBytes({(keyBuffer: UnsafeRawBufferPointer) -> Int32 in
            let keyPtr = keyBuffer.baseAddress!
            return iv.withUnsafeBytes({(ivBuffer: UnsafeRawBufferPointer) -> Int32 in
                let ivPtr = ivBuffer.baseAddress!
                return message.withUnsafeBytes({(messBuffer: UnsafeRawBufferPointer) -> Int32 in
                    let messPtr = messBuffer.baseAddress!
                    let algorithm = CCAlgorithm(kCCAlgorithmAES)
                    let padding = CCOptions(kCCOptionPKCS7Padding)
                    return CCCrypt(operation, algorithm, padding, keyPtr, key.count, ivPtr, messPtr, message.count, ptr, dataLength, &dataOutMoved)
                })
            })
        })
        guard status == kCCSuccess else {
            if encrypt {
                throw SignalError(.encryptionError, "AES CBC encryption error: \(status)")
            } else {
                throw SignalError(.decryptionError, "AES CBC decryption error: \(status)")
            }
        }
        let typedPointer = ptr.bindMemory(to: UInt8.self, capacity: dataOutMoved)
        let typedBuffer = UnsafeMutableBufferPointer(start: typedPointer, count: dataOutMoved)
        return Data(typedBuffer)
    }
    
    private func process(ctr message: Data, key: Data, iv: Data, encrypt: Bool) throws -> Data {
        var cryptoRef: CCCryptorRef? = nil
        var status: Int32 = key.withUnsafeBytes({(keyBuffer: UnsafeRawBufferPointer) -> Int32 in
            let keyPtr = keyBuffer.baseAddress!
            return iv.withUnsafeBytes({(ivBuffer: UnsafeRawBufferPointer) -> Int32 in
                let ivPtr = ivBuffer.baseAddress!
                let operation = encrypt ? CCOperation(kCCEncrypt) : CCOperation(kCCDecrypt)
                let mode = CCMode(kCCModeCTR)
                let algorithm = CCAlgorithm(kCCAlgorithmAES)
                let padding = CCPadding(kCCModeCTR)
                let option = CCModeOptions(kCCModeOptionCTR_BE)
                return CCCryptorCreateWithMode(operation, mode, algorithm, padding, ivPtr, keyPtr, key.count, nil, 0, 0, option, &cryptoRef)
            })
        })
        defer {
            CCCryptorRelease(cryptoRef)
        }
        guard status == kCCSuccess, let ref = cryptoRef else {
            if encrypt {
                throw SignalError(.encryptionError, "AES CTR encryption error: \(status)")
            } else {
                throw SignalError(.decryptionError, "AES CTR decryption error: \(status)")
            }
        }
        let outputLength = CCCryptorGetOutputLength(ref, message.count, true)
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: outputLength, alignment: MemoryLayout<UInt8>.alignment)
        defer {
            ptr.deallocate()
        }
        var updateMovedLength = 0
        status = withUnsafeMutablePointer(to: &updateMovedLength, {updatedPtr in
            message.withUnsafeBytes({(messBuffer: UnsafeRawBufferPointer) -> Int32 in
                let messPtr = messBuffer.baseAddress!
                return CCCryptorUpdate(ref, messPtr, message.count, ptr, outputLength, updatedPtr)
            })
        })
        guard updateMovedLength <= outputLength else {
            throw SignalError(.encryptionError, "Updated bytes \(updateMovedLength) for \(outputLength) total bytes")
        }
        guard status == kCCSuccess else {
            if encrypt {
                throw SignalError(.encryptionError, "AES CTR encryption error: \(status)")
            } else {
                throw SignalError(.decryptionError, "AES CTR decryption error: \(status)")
            }
        }
        let available = outputLength - updateMovedLength
        let ptr2 = ptr.advanced(by: updateMovedLength)
        var finalMovedLength: Int = 0
        status = withUnsafeMutablePointer(to: &finalMovedLength, {
            CCCryptorFinal(ref, ptr2, available, $0)
        })
        let finalLength = updateMovedLength + finalMovedLength
        guard status == kCCSuccess else {
            if encrypt {
                throw SignalError(.encryptionError, "AES CTR encryption error: \(status)")
            } else {
                throw SignalError(.decryptionError, "AES CTR decryption error: \(status)")
            }
        }
        if encrypt && finalLength != outputLength {
            throw SignalError(.encryptionError, "AES CTR: output not correct: \(finalLength), \(outputLength), \(updateMovedLength), \(finalMovedLength)")
        }
        
        let typedPointer = ptr.bindMemory(to: UInt8.self, capacity: finalLength)
        let typedBuffer = UnsafeMutableBufferPointer(start: typedPointer, count: finalLength)
        return Data(typedBuffer)
    }
    
    public func encrypt(message: Data, with cipher: SignalEncryptionScheme, key: Data, iv: Data) throws -> Data {
        guard key.count == kCCKeySizeAES256 else {
            throw SignalError(.invalidKey, "Invalid key length")
        }
        guard message.count > 0 else {
            throw SignalError(.invalidMessage, "Message length is 0")
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw SignalError(.invalidIv, "The length of initalized vector is not correct")
        }
        switch cipher {
        case .AES_CBCwithPKCS5:
            return try process(cbc: message, key: key, iv: iv, encrypt: true)
        case .AES_CTRnoPadding:
            return try process(ctr: message, key: key, iv: iv, encrypt: true)
        }
    }
    
    public func decrypt(message: Data, with cipher: SignalEncryptionScheme, key: Data, iv: Data) throws -> Data {
        guard key.count == kCCKeySizeAES256 else {
            throw SignalError(.invalidKey, "Invalid key length")
        }
        guard message.count > 0 else {
            throw SignalError(.invalidMessage, "Message length is 0")
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw SignalError(.invalidIv, "The length of the iv is not correct")
        }
        switch cipher {
        case .AES_CBCwithPKCS5:
            return try process(cbc: message, key: key, iv: iv, encrypt: false)
        case .AES_CTRnoPadding:
            return try process(ctr: message, key: key, iv: iv, encrypt: false)
        }
    }
    
    public func generateIdentityKeyPair() throws -> Data {
        return try KeyPair().protoData()
    }
    
    func generatePreKeys(start: UInt32, count: Int) throws -> [SessionPreKey] {
        var dict = [SessionPreKey]()
        for i in 0..<UInt32(count) {
            dict.append(try SessionPreKey(index: start &+ i))
        }
        return dict
    }
    
    func generatedSignedPreKey(identityKey: PrivateKey, id: UInt32, timestamp: UInt64 = UInt64(Date().timeIntervalSince1970)) throws -> SessionSignedPreKey {
        return try SessionSignedPreKey(id: id, signatureKey: identityKey, timestamp: timestamp)
    }
    
    func generateSenderKeyId() throws -> UInt32 {
        let data = try random(bytes: 4)
        let value = data.withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> UInt32 in
            buffer.baseAddress!.assumingMemoryBound(to: UInt32.self).pointee
        })
        return value & 0x7FFFFFFF
    }
    
    func generateSenderKey() throws -> Data {
        return try Data(random(bytes: 32))
    }
    
    func generateSenderSigningKey() throws -> KeyPair {
        let result = try KeyPair()
        return result
    }
//    private init() {
//
//    }
}

//
//  HKDF.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct HKDF {
    private static let derivedRootSecretsSize = RatchetRootKey.secrectSize + RatchetChainKey.secretSize
    private static let iterationStartOffset: UInt8 = 1
    private static let crypto = CommonSignalCrypto()
    
    static func deriveSecrets(material: Data, salt: Data, info: Data, outputLength: Int) throws -> Data {
        let prk = try HKDF.crypto.hmacSHA256(for: material, with: salt)
        return try expand(prk: prk, info: info, outputLength: outputLength)
    }
    
    private static func expand(prk: Data, info: Data, outputLength: Int) throws -> Data {
        var fraction = Double(outputLength) / Double(RatchetChainKey.hashOutputSize)
        fraction.round(.up)
        let iterations = UInt8(fraction)
        var result = Data()
        var remainingLength = outputLength
        var stepBuffer = Data()
        for index in iterationStartOffset ..< iterations + iterationStartOffset {
            let message = stepBuffer + info + [index]
            stepBuffer = try HKDF.crypto.hmacSHA256(for: message, with: prk)
            let stepSize = min(remainingLength, stepBuffer.count)
            result += stepBuffer[0..<stepSize]
            remainingLength -= stepSize
        }
        return result
    }
    
    static func chainAndRootKey(material: Data, salt: Data, info: Data) throws -> (rootKey: RatchetRootKey, chainKey: RatchetChainKey) {
        let derivedSecrect = try HKDF.deriveSecrets(material: material, salt: salt, info: info, outputLength: HKDF.derivedRootSecretsSize)
        let rootKeySecrect = derivedSecrect[0..<RatchetRootKey.secrectSize]
        let newRootKey = RatchetRootKey(key: rootKeySecrect)
        let chainKeySecret = derivedSecrect[RatchetRootKey.secrectSize..<HKDF.derivedRootSecretsSize]
        let newChainKey = RatchetChainKey(key: chainKeySecret, index: 0)
        return (newRootKey, newChainKey)
    }
}

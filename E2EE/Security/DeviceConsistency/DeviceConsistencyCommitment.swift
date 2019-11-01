//
//  DeviceConsistencyCommitment.swift
//  E2EE
//
//  Created by CPU11899 on 11/1/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct DeviceConsistencyCommitmentV0 {
    private static let codeVersion: UInt16 = 0
    private static let version = "DeviceConsistencyCommitment_V0".data(using: .utf8)!
    var generation: UInt32
    var serialized: Data
    
    init(generation: UInt32, identityKeyList: [PublicKey]) throws {
        let crypto = CommonSignalCrypto()
        let list = identityKeyList.sorted()
        var gen = generation
        let data = withUnsafePointer(to: &gen, {(pointer: UnsafePointer) -> Data in
            return Data(bytes: pointer, count: MemoryLayout<UInt32>.size)
        })
        var bytes = DeviceConsistencyCommitmentV0.version + data
        for item in list {
            bytes += item.data
        }
        self.serialized = try crypto.sha512(for: bytes)
        self.generation = generation
    }
    
    func generateCode(for signatureList: [DeviceConsistencySignature]) throws -> String {
        let crypto = CommonSignalCrypto()
        let list = signatureList.sorted()
        let byte0 = UInt8(DeviceConsistencyCommitmentV0.codeVersion & 0x00FF)
        let byte1 = UInt8((DeviceConsistencyCommitmentV0.codeVersion & 0xFF0) >> 8)
        var bytes = Data([byte0, byte1]) + self.serialized
        
        for item in list {
            bytes += item.vrfOutput
        }
        
        let hash = try crypto.sha512(for: bytes)
        guard hash.count >= 10 else {
            throw SignalError(.digestError, "SHA512 is only \(hash.count) bytes")
        }
        let data = hash.map {UInt64($0)}
        let a1 = (data[0] << 32) | (data[1] << 24) | (data[2] << 16) | (data[3] << 8) | data[4]
        let a2 = (data[5] << 32) | (data[6] << 24) | (data[7] << 16) | (data[8] << 8) | data[9]
        let b1 = Int(a1) % 100000
        let b2 = Int(a2) % 100000
        let longString = String(format: "%05d%05d", b1, b2)
        return String(longString.prefix(7))
    }
}

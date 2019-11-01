//
//  Fingerprint.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct Fingerprint {
    static let version: UInt8 = 0
    public static let length = 30
    public static let iterations = 1024
    let displayable: DisplayableFingerprint
    public let scannable: ScannableFingerprint
    public var displayText: String {
        return displayable.displayText
    }
    
    public init(
        localStableIdentifier: String,
        localIdentity: Data,
        remoteStableIdentifier: String,
        remoteIdentity: Data,
        iterations: Int = Fingerprint.iterations) throws {

        let localFingerprint = try getFingerprint(
            identity: localIdentity,
            stableIdentifier: localStableIdentifier,
            iterations: iterations)

        let remoteFingerprint = try getFingerprint(
            identity: remoteIdentity,
            stableIdentifier: remoteStableIdentifier,
            iterations: iterations)

        self.displayable = try DisplayableFingerprint(
            localFingerprint: localFingerprint,
            remoteFingerprint: remoteFingerprint)

        self.scannable = try ScannableFingerprint(
            localFingerprint: localFingerprint,
            remoteFingerprint: remoteFingerprint)
    }
    
    public init(
        localStableIdentifier: String,
        localIdentity: PublicKey,
        remoteStableIdentifier: String,
        remoteIdentity: PublicKey,
        iterations: Int = Fingerprint.iterations) throws {
        try self.init(
            localStableIdentifier: localStableIdentifier,
            localIdentity: localIdentity.data,
            remoteStableIdentifier: remoteStableIdentifier,
            remoteIdentity: remoteIdentity.data,
            iterations: iterations)
    }
    
    public init(
        localStableIdentifier: String,
        localIdentityList: [PublicKey],
        remoteStableIdentifier: String,
        remoteIdentityList: [PublicKey],
        iterations: Int = Fingerprint.iterations) throws {
        try self.init(
            localStableIdentifier: localStableIdentifier,
            localIdentity: getLogicalKey(for: localIdentityList),
            remoteStableIdentifier: remoteStableIdentifier,
            remoteIdentity: getLogicalKey(for: remoteIdentityList),
            iterations: iterations)
    }
    
    public func matches(_ scannedData: Data) throws -> Bool {
        let scanned = try ScannableFingerprint(from: scannedData)
        return scannable.matches(scanned)
    }
}

private func getLogicalKey(for keyList: [PublicKey]) -> Data {
    let list = keyList.sorted()
    return list.reduce(Data(), {(data: Data, key: PublicKey) -> Data in
        return data + key.data
    })
        
}

private func getFingerprint(identity: Data, stableIdentifier: String, iterations: Int) throws -> Data {
    guard let id = stableIdentifier.data(using: .utf8) else {
        throw SignalError(.unknown, "Stable identifier \(stableIdentifier) cannot convert to data")
    }
    let commonCrypto = CommonSignalCrypto()
    var hashBuffer = Data([0, Fingerprint.version]) + identity + id
    for _ in 0..<iterations {
        hashBuffer = try commonCrypto.sha512(for: hashBuffer + identity)
    }
    guard hashBuffer.count >= Fingerprint.length else {
        throw SignalError(.invalidLength, "Invalid SHA512 hash length \(hashBuffer.count)")
    }
    return hashBuffer
}

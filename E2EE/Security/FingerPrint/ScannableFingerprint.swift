//
//  ScannableFingerprint.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct ScannableFingerprint {
    private static let length = 32
    private static let version: UInt32 = 1
    public let localFingerPrint: Data
    public let remoteFingerprint: Data
    
    init(localFingerprint: Data, remoteFingerprint: Data) throws {
        let length = ScannableFingerprint.length
        guard localFingerprint.count >= length, remoteFingerprint.count >= length else {
            throw SignalError(.invalidLength, "Invalid fingerprint lengths \(localFingerprint.count), \(remoteFingerprint.count)")
        }
        self.localFingerPrint = localFingerprint[0..<length]
        self.remoteFingerprint = remoteFingerprint[0..<length]
    }
}

extension ScannableFingerprint: ProtocolBufferEquivalent {
    init(from protoObject: Signal_Fingerprint) throws {
        guard protoObject.hasLocal && protoObject.hasRemote && protoObject.hasVersion else {
            throw SignalError(.invalidProtoBuf, "Missing data in Fingerprint protobuf")
        }
        guard protoObject.version == ScannableFingerprint.version else {
            throw SignalError(.invalidProtoBuf, "Invalid fingerprint version \(protoObject.version)")
        }
        try self.init(localFingerprint: protoObject.local, remoteFingerprint: protoObject.remote)
    }
    
    var protoObject: Signal_Fingerprint {
        return Signal_Fingerprint.with {
            $0.version = ScannableFingerprint.version
            $0.remote = self.remoteFingerprint
            $0.local = self.localFingerPrint
        }
    }
}

extension ScannableFingerprint {
    public func matches(_ other: ScannableFingerprint) -> Bool {
        return localFingerPrint == other.localFingerPrint && remoteFingerprint == other.remoteFingerprint
    }
}

extension ScannableFingerprint: Equatable {
    public static func ==(lhs: ScannableFingerprint, rhs: ScannableFingerprint) -> Bool {
        return lhs.localFingerPrint == rhs.localFingerPrint && lhs.remoteFingerprint == rhs.remoteFingerprint
    }
}

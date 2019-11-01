//
//  DisplayableFingerprint.swift
//  E2EE
//
//  Created by CPU11899 on 10/29/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct DisplayableFingerprint {
    let local: String
    let remote: String
    public let displayText: String
    
    init(local: String, remote: String) {
        self.local = local
        self.remote = remote
        
        if local <= remote {
            self.displayText = local + remote
        } else {
            self.displayText = remote + local
        }
    }
    
    public init(localFingerprint: Data, remoteFingerprint: Data) throws {
        guard localFingerprint.count >= Fingerprint.length else {
            throw SignalError(.invalidLength, "Invalid local fingerprint length: \(localFingerprint.count)")
        }
        guard remoteFingerprint.count >= Fingerprint.length else {
            throw SignalError(.invalidLength, "Invalid remote fingerprint length: \(remoteFingerprint.count)")
        }
        let localString = DisplayableFingerprint.createDisplayString(fingerprint: localFingerprint)
        let remoteString = DisplayableFingerprint.createDisplayString(fingerprint: remoteFingerprint)
        self.init(local: localString, remote: remoteString)
    }
    
    private static func createDisplayString(fingerprint: Data) -> String {
        let data = fingerprint.map({(element: UInt8) -> UInt64 in
            return UInt64(element)
        })
        var output = ""
        for i in stride(from: 0, to: 30, by: 5) {
            let chunk = (data[i] << 32) | (data[i+1] << 24)
            let chunk2 = (data[i+2] << 16) | (data[i+3] << 8) | data[i+4]
            let chunk3 = chunk | chunk2
            let val = Int(chunk3 % 100000)
            output += String(format: "%05d", val)
        }
        return output
    }
}

extension DisplayableFingerprint : Equatable {
    static public func ==(a: DisplayableFingerprint, b: DisplayableFingerprint) -> Bool {
        return a.displayText == b.displayText
    }
}

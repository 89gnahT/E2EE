//
//  ErrorException.swift
//  E2EE
//
//  Created by CPU11899 on 10/25/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public enum ErrorType : String {
    case unknown = "Unknown"
    case curveError = "Cureve25519"
    case storageError = "Storage"
    case duplicateMessage = "Duplicate Message"
    case invalidType = "Invalid Type"
    case invalidKey = "Invalid Key"
    case invalidIv = "Invalid IV"
    case invalidId = "Invalid ID"
    case invalidMac = "Invalid MAC"
    case invalidMessage = "Invalid Message"
    case invalidLength = "Invalid Length"
    case legacyMessage = "Legact Message"
    case noSession = "No Session"
    case untrustedIdentity = "Untrusted Identity"
    case invalidSignature = "Invalid Signature"
    case invalidProtoBuf = "Invalid protoBuf"
    case fPIdentityMismatch = "Fingerprint identity mismatch"
    case noCryptoProvider = "No Crypto Provider"
    case noRandomBytes = "No Random Bytes"
    case hmacError = "HMAC error"
    case digestError = "Digest Error"
    case encryptionError = "Encryption Error"
    case decryptionError = "Decryption Error"
}

public final class SignalError : CustomStringConvertible, Error {
    public let type: ErrorType
    public let message: String?
    public let cause: SignalError?
    public let function: String
    public let file: String
    
    public init (_ type: ErrorType, _ message: String? = nil, cause: SignalError? = nil, file: String = #file, function: String = #function) {
        self.type = type
        self.message = message
        self.cause = cause
        self.file = file
        self.function = function
    }
    
    public init (_ message: String?, cause: SignalError, file: String = #file, function: String = #function) {
        self.type = cause.type
        self.message = message
        self.cause = cause
        self.file = file
        self.function = function
    }
    public convenience init (_ message: String?, cause: Error, file: String = #file, function: String = #function) {
        if let reason = cause as? SignalError {
            self.init(message, cause: reason, file: file, function: function)
        } else {
            let reason = SignalError(.unknown, cause.localizedDescription)
            self.init(message, cause: reason, file: file, function: function)
        }
    }
    public var description: String {
        var output = shortDescription
        if let text = cause {
            output += "\n" + text.description
        }
        return output
    }
    
    public var shortDescription: String {
        var output = type.rawValue + "error"
        if let text = message {
            output += ": " + text
        }
        return output
    }
    
    public var longDescription: String {
        return type.rawValue + " error\n" + trace
    }
    
    public var trace: String {
        var output = ""
        if let text = message {
            output += "Reason: " + text
        }
        output += " \nTrace:\n" + file + ": " + function
        if let reason = cause {
            output += "\n" + reason.trace
        }
        return output
    }
    public var localizedDescription: String {
        return description
    }
}

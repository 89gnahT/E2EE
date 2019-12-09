//
//  SignalAddress.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct SignalAddress {
    public let identifier: String
    public let deviceId: UInt32
    
    init(identifier: String, deviceId: UInt32) {
        self.identifier = identifier
        self.deviceId = deviceId
    }
    
    func toDictionary() -> Dictionary<String, Any> {
        return ["Identifier": self.identifier,
                "deviceId": self.deviceId]
    }
}

extension SignalAddress : Equatable {
    public static func ==(rhs: SignalAddress, lhs: SignalAddress) -> Bool {
        return rhs.deviceId == lhs.deviceId && rhs.identifier == lhs.identifier
    }
}

extension SignalAddress : Hashable {}

extension SignalAddress : CustomStringConvertible {
    public var description: String {
        return "Description identifier: \(self.identifier)"
    }
}

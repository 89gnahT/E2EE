//
//  SignalSenderKeyName.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

public struct SignalSenderKeyName {
    private var groupID: String
    private var sender: SignalAddress
    
    init(groupid: String, sender: SignalAddress) {
        self.groupID = groupid
        self.sender = sender
    }
}

extension SignalSenderKeyName: Hashable {
    
}

extension SignalSenderKeyName: Equatable {
    public static func ==(lhs: SignalSenderKeyName, rhs: SignalSenderKeyName) -> Bool {
        return lhs.groupID == rhs.groupID && lhs.sender == rhs.sender
    }
}

extension SignalSenderKeyName: CustomStringConvertible {
    public var description: String {
        return "Sender \(sender.description) at \(groupID)"
    }
    
    
}

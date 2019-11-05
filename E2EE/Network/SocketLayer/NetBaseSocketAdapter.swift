//
//  NetBaseSocketStatus.swift
//  E2EE
//
//  Created by CPU11899 on 11/5/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

enum ConnectionStatus {
    case uninitialize
    case connected
    case disconnected
}

public protocol NetbaseSocketProtocol {
    func send(_ data: Data)
    func receiver(_ data: Data)
    func init(withHost host: String, and port: String)
}


enum NetBaseErrorType: String {
    case invalidSetting = "Invalid connection setting"
}

public class NetBaseError: CustomStringConvertible, Error {
    let errorType: NetBaseErrorType
    public let description: String
    
    init(type: NetBaseErrorType, description: String) {
        self.errorType = type
        self.description = description
    }
}

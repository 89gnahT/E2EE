//
//  NetBaseSocketStatus.swift
//  E2EE
//
//  Created by CPU11899 on 11/5/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import Network

public enum ConnectivityState {
    case setup
    case waiting
    case preparing
    case ready
    case failed
    case canceled
}

public enum Service {
    case voicecall
    case chat
}

enum NetBaseErrorType: String {
    case invalidSetting = "Invalid connection setting"
    case internalError = "Internal Error"
    case sendError = "Send Error"
    case receiveError = "Receive Error"
    case netBaseError = "Netbase Error"
}

public class NetBaseError: CustomStringConvertible, Error {
    let errorType: NetBaseErrorType
    public let description: String
    
    init(type: NetBaseErrorType, description: String) {
        self.errorType = type
        self.description = description
    }
}

public protocol NetbaseSocketDelegate {
    func receive(_ data: Data)
    func stateDidChange(_ state: ConnectivityState)
}

public protocol GenericSocket: NSObjectProtocol {
    var delegate: NetbaseSocketDelegate? { get set }
    func loadSetting(host:String, port:String) throws
    func send(_ data: Data)
}

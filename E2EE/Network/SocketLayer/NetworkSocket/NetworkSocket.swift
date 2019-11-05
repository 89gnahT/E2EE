//
//  NetBaseSocket.swift
//  E2EE
//
//  Created by CPU11899 on 11/5/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import Network

@available(iOS 12.0, *)
class NetBaseSocket: NSObject {
    static var connectionStatus: ConnectionStatus = .uninitialize
    var connection: NWConnection
    var endpoint: NWEndpoint
    var host: NWEndpoint.Host
    var port: NWEndpoint.Port
    var type: NWEndpoint.Type
    
    init(withHost host: String, and port:String) throws {
        self.host = NWEndpoint.Host.init(host)
        guard case self.port = NWEndpoint.Port.init(port) else {
            throw NetBaseError(type: .invalidSetting, description: "Wrong port")
        }
        self.connection = NWConnection(to: self.endpoint, using: NWParameters(tls: .none, tcp: .init()))
        
    }
}

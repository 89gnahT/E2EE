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
    var connection: NWConnection?
    var endpoint: NWEndpoint?
    var host: NWEndpoint.Host?
    var port: NWEndpoint.Port?
    var type: NWEndpoint.Type?
    
    init(withHost host: String, and port:String) throws {
        self.host = NWEndpoint.Host.init(host)
        guard case self.port = NWEndpoint.Port.init(port) else {
            throw NetBaseError(type: .invalidSetting, description: "Wrong port")
        }
        self.connection = NWConnection(to: self.endpoint!, using: NWParameters(tls: .none, tcp: .init()))
        
    }
    
    open func send(_ data: Data) throws {
        var sendError: NWError?
        self.connection?.send(content: data, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({(nwerror: NWError?) -> Void in
            sendError = nwerror
            guard nwerror != nil else {
                return
            }
        }))
        guard sendError != nil else {
            throw NetBaseError(type: .sendError, description: "Error when send data: \(sendError!.localizedDescription)")
        }
    }
    
    open func receive(_ data: Data) throws {
        var receiveError: NWError?
        self.connection?.receiveMessage(completion: {(receivedData: Data?, context: NWConnection.ContentContext?, isSuccess: Bool, nwerror: NWError?) -> Void in
            receiveError = nwerror
            guard nwerror != nil else {
                return
            }
            
        })
        guard receiveError != nil else {
            throw NetBaseError(type: .receiveError, description: "Error when receive data: \(receiveError!.localizedDescription)")
        }
    }
}

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
class NetWorkSocket: NSObject {
    public var delegate: NetbaseSocketDelegate?
    
    static var connectionStatus: ConnectionStatus = .uninitialize
    var connection: NWConnection?
    var host: NWEndpoint.Host?
    var port: NWEndpoint.Port?
    var type: NWEndpoint.Type?
    static let maxReadSize = Int(UInt16.max)
    var buffer:UnsafeMutablePointer<UInt8>?
    
    init(withHost host: String, and port:String) throws {
        super.init()
        
        let endpointHost = NWEndpoint.Host.init(host)
        
        let portInt = UInt16(port, radix: 10)
        
        if let port = portInt {
            let endpointPort = NWEndpoint.Port.init(rawValue: port)
            if let endpointPort = endpointPort {
                let nwConnection = NWConnection(host: endpointHost, port: endpointPort, using: .tcp)
                nwConnection.stateUpdateHandler = self.stateDidChange(to:)
                nwConnection.start(queue: DispatchQueue.global())
            } else {
                throw NetBaseError(type: .invalidSetting, description: "Port of Endpoint is wrong")
            }
        } else {
            throw NetBaseError(type: .invalidSetting, description: "Port of endpoint is wrong")
        }
        
    }
    
    func stateDidChange(to state: NWConnection.State) {
        guard let delegate = self.delegate else { return }
        switch state {
        case .cancelled:
            delegate.stateDidChange(.canceled)
        case .failed(let error):
            delegate.stateDidChange(.failed)
            print(error.localizedDescription)
        case .preparing:
            delegate.stateDidChange(.preparing)
        case .ready:
            delegate.stateDidChange(.ready)
        case .setup:
            delegate.stateDidChange(.setup)
        case .waiting(let error):
            print(error.localizedDescription)
            delegate.stateDidChange(.waiting)
        @unknown default:
            print("Unknown Error")
        }
    }
    
    
    
    open func send(_ data: Data){
        self.connection?.send(content: data, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({(nwerror: NWError?) -> Void in
            guard nwerror != nil else {
                return
            }
        }))
    }
    
    open func receive(){
        self.connection?.receiveMessage(completion: {(receivedData: Data?, context: NWConnection.ContentContext?, isSuccess: Bool, nwerror: NWError?) -> Void in
            guard nwerror != nil else {
                return
            }
            if let receivedData = receivedData {
                self.delegate?.receive(receivedData)
            }
            
            if isSuccess {
                self.receive()
            }
        })
    }
}

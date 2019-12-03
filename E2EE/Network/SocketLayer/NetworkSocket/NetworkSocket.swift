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
class NetWorkSocket: NSObject, GenericSocket {
    var delegate: NetbaseSocketDelegate?
    var connection: NWConnection?
    var host: NWEndpoint.Host?
    var port: NWEndpoint.Port?
    var type: NWEndpoint.Type?
    static let maxReadSize = Int(UInt16.max)
    var buffer:UnsafeMutablePointer<UInt8>?
    let socketQueue = DispatchQueue(label: "Socket.inputQueue")
    
    override init() {
        
    }
    
    func loadSetting(host: String, port: String) throws {
        let endpointHost = NWEndpoint.Host.init(host)
        
        let portInt = UInt16(port, radix: 10)
        
        if let port = portInt {
            let endpointPort = NWEndpoint.Port.init(rawValue: port)
            if let endpointPort = endpointPort {
                self.connection = NWConnection(host: endpointHost, port: endpointPort, using: .tcp)
                if let connection = self.connection {
                    connection.stateUpdateHandler = self.stateDidChange(to:)
                    connection.start(queue: self.socketQueue)
                } else {
                    throw NetBaseError(type: .invalidSetting, description: "Failed to initialize connection")
                }
            } else {
                throw NetBaseError(type: .invalidSetting, description: "Port of Endpoint is wrong")
            }
        } else {
            throw NetBaseError(type: .invalidSetting, description: "Port of endpoint is wrong")
        }
    }
    
    func setService() throws {
        
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
//        self.outputQueue.async { [weak self] in
//            guard let connection = self?.connection else {
//                return
//            }
//            data.withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> Void in
//                let typedBuffer = buffer.bindMemory(to: UInt8.self)
//                let pointer = typedBuffer.baseAddress!
//                var isComplete = false
//                while !isComplete {
//                    connection.send(content: <#T##DataProtocol?#>, contentContext: <#T##NWConnection.ContentContext#>, isComplete: <#T##Bool#>, completion: <#T##NWConnection.SendCompletion#>)
//                }
//            })
//        }
        guard let connection = self.connection else { return }
        connection.send(content: data, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({(nwerror: NWError?) -> Void in
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

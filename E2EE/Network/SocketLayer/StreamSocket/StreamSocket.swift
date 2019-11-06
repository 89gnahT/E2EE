//
//  StreamSocket.swift
//  E2EE
//
//  Created by CPU11899 on 11/5/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class StreamSocket: NSObject {
    var runloop: RunLoop?
    static let maxReadSize = Int(UInt16.max)
    var buffer:UnsafeMutablePointer<UInt8>?
    var inputData = Data()
    var inputQueue = DispatchQueue(label: "liveStream.inputQueue")
    var outputQueue = DispatchQueue(label: "liveStream.outputQueue")
    var input: InputStream?
    var output: OutputStream?
    
    open func setSocketSetting() throws {
        buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: StreamSocket.maxReadSize)
        buffer?.initialize(repeating: 0, count: StreamSocket.maxReadSize)
        if let delegate = self as? StreamDelegate {
            self.input?.delegate = delegate
            self.output?.delegate = delegate
        } else {
            throw NetBaseError(type: .invalidSetting, description: "Stream not implementation the Stream delegate")
        }
        self.runloop = .current
//        self.input?.setProperty(StreamNetworkServiceTypeValue.voIP, forKey: Stream.PropertyKey.networkServiceType)
//        self.input?.setProperty(StreamSocketSecurityLevel.negotiatedSSL, forKey: .socketSecurityLevelKey)
//        self.input?.schedule(in: self.runloop!, forMode: .common)
//
//        self.output?.schedule(in: self.runloop!, forMode: .common)
//        self.output?.setProperty(StreamNetworkServiceTypeValue.voIP, forKey: Stream.PropertyKey.networkServiceType)
        self.input?.open()
        self.output?.open()
        self.runloop?.run()
    }
    
    open func removeSocketSetting() throws {
        self.input?.close()
        self.output?.close()
        self.input?.delegate = nil
        self.output?.delegate = nil
        self.input?.remove(from: self.runloop!, forMode: .common)
        self.output?.remove(from: self.runloop!, forMode: .common)
        self.input = nil
        self.output = nil
        buffer?.deinitialize(count: StreamSocket.maxReadSize)
        buffer?.deallocate()
        buffer = nil
        inputData.removeAll()
        guard let r = self.runloop else {
            throw NetBaseError(type: .internalError, description: "Error with stream run loop")
        }
        CFRunLoopStop(r.getCFRunLoop())
        self.runloop = nil
    }
    
    public func send(_ data: Data) {
        outputQueue.async { [weak self] in
            guard let o = self?.output else {
                return
            }
            data.withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> Void in
                let typedBuffer = buffer.bindMemory(to: UInt8.self)
                let pointer = typedBuffer.baseAddress!
                var total: Int = 0
                while total < data.count {
                    let length = o.write(pointer.advanced(by: total), maxLength: data.count)
                    if length <= 0 {
                        break
                    }
                    total += length
                }
            })
        }
    }
}

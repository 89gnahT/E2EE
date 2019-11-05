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
    
    open func setSocketSetting() {
        buffer = 
    }
}

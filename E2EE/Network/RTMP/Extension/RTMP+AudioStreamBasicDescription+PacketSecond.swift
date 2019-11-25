//
//  RTMP+AudioStreamBasicDescription+PacketSecond.swift
//  E2EE
//
//  Created by CPU11899 on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import AVFoundation

extension AudioStreamBasicDescription {
    var packetPerSecond: Int {
        get {
            return Int(Float(self.mSampleRate)/Float(self.mFramesPerPacket))
        }
    }
}

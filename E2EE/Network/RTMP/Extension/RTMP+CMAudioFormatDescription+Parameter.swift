//
//  RTMP+CMAudioFormatDescription+Parameter.swift
//  E2EE
//
//  Created by CPU11899 on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import CoreMedia

extension CMAudioFormatDescription {
    var streamBasicDesc: AudioStreamBasicDescription? {
        get {
            return CMAudioFormatDescriptionGetStreamBasicDescription(self)?.pointee
        }
    }
}

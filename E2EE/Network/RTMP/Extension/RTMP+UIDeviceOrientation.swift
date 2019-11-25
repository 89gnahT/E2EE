//
//  RTMP+UIDeviceOrientation.swift
//  E2EE
//
//  Created by CPU11899 on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension UIDeviceOrientation {
    var avaptureOrientation: AVCaptureVideoOrientation {
        get {
            switch self {
            case .landscapeLeft:
                return .landscapeRight
            case .landscapeRight:
                return .landscapeLeft
            case .portrait:
                return .portrait
            case .portraitUpsideDown:
                return .portraitUpsideDown
            default:
                return .portrait
            }
        }
    }
}

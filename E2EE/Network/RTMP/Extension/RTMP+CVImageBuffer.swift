//
//  RTMP+CVImageBuffer.swift
//  E2EE
//
//  Created by CPU11899 on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension CVImageBuffer {
    func convert() -> UIImage {
        return UIImage(ciImage: CIImage(cvImageBuffer: self))
    }
}

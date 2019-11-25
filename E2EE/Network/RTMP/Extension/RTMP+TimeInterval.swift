//
//  RTMP+TimeInterval.swift
//  E2EE
//
//  Created by CPU11899 on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

extension TimeInterval {
    var millSecond: TimeInterval {
        get {
            return self*1000
        }
    }
}

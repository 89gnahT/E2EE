//
//  RTMP+ExpressibleByIntegerLiteral+Convert.swift
//  E2EE
//
//  Created by CPU11899 on 11/22/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

import Foundation

extension ExpressibleByIntegerLiteral {
    var data: Data {
        var v: Self = self
        let s:Int = MemoryLayout<`Self`>.size
        return withUnsafeMutablePointer(to: &v, {
            return $0.withMemoryRebound(to: UInt8.self, capacity: s, {
                Data(UnsafeBufferPointer(start: $0, count: s))
            })
        })
    }
}

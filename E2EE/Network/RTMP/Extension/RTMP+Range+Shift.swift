//
//  RTMP+Range+Shift.swift
//  E2EE
//
//  Created by CPU11899 on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

extension CountableClosedRange where Bound == Int {
    func shift(index: Int) -> CountableClosedRange<Int> {
        return self.lowerBound+index...self.upperBound+index
    }
}

extension CountableRange where Bound == Int {
    func shift(index: Int) -> CountableRange<Int> {
        return self.lowerBound+index..<self.upperBound+index
    }
}

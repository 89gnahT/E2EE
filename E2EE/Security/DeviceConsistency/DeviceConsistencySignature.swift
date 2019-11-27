//
//  DeviceConsistancySignature.swift
//  E2EE
//
//  Created by CPU11899 on 11/1/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct DeviceConsistencySignature {
    var signature: Data
    var vrfOutput: Data
    
    init(signature: Data, vrfOutput: Data) {
        self.signature = signature
        self.vrfOutput = vrfOutput
    }
}

extension DeviceConsistencySignature: Comparable {
    static func <(a: DeviceConsistencySignature, b: DeviceConsistencySignature) -> Bool {
        guard a.vrfOutput.count == b.vrfOutput.count else {
            return a.vrfOutput.count < b.vrfOutput.count
        }
        for i in 0..<a.vrfOutput.count {
            if a.vrfOutput[i] != b.vrfOutput[i] {
                return a.vrfOutput[i] < b.vrfOutput[i]
            }
        }
        return false
    }
    
    static func ==(lhs: DeviceConsistencySignature, rhs: DeviceConsistencySignature) -> Bool {
        return lhs.vrfOutput == rhs.vrfOutput
    }
}

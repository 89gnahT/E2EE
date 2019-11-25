//
//  RTMP+Array.swift
//  E2EE
//
//  Created by CPU11899 on 11/18/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

// MARK : - RTMP and Chunk
extension Array {
    func split(size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map({
            let end = $0 + size >= count ? count : $0 + size
            return Array(self[$0..<end])
        })
    }
}

//MARK : - RTMP and Safe Element
public extension Array {
    subscript (safe range: CountableRange<Int>) -> ArraySlice<Element>? {
        if range.lowerBound < 0 || range.count > self.count {
            return nil
        }
        return self[range]
    }
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

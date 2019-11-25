//
//  RTMP+Object+DecodeObject.swift
//  E2EE
//
//  Created by CPU11899 on 11/19/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

extension Dictionary {
    func decodeObject<T: Decodable>() -> T? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted), let obj = try? JSONDecoder().decode(T.self, from: data) {
            return obj
        }
        return nil
    }
}

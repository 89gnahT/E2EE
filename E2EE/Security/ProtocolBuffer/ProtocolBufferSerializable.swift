//
//  ProtocolBufferSerializable.swift
//  E2EE
//
//  Created by CPU11899 on 10/25/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
public protocol ProtocolBufferSerializable {
    func protoData() throws -> Data
    init(from protoData: Data) throws
}

//
//  ProtocolBufferEquivalent.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 10/26/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

protocol ProtocolBufferEquivalent: ProtocolBufferConvertiable {
    var protoObject: ProtocolBufferClass { get }
}

extension ProtocolBufferEquivalent {
    func asProtoObject() -> ProtocolBufferClass {
        return protoObject
    }
}

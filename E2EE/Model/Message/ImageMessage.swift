//
//  ImageMessage.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

class ImageMessage: Message {
    init(id : MsgID, senderId : UserID, contents : [String], time : MsgTime) {
        super.init(id: id, senderId: senderId, type: .image, contents: contents, time: time)
    }
}

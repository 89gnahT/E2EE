//
//  ImageMessageModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class ImageMessageModel: MessageModel {
    init(id : MessageID = "",
           conversationID : InboxID = "",
           sender : UserModel = UserModel(),
           contents : [String] = [],
           time : MessageTime = MessageTime())
      {
          super.init(id: id,
                     conversationID: conversationID,
                     sender: sender,
                     type: .image,
                     contents: contents,
                     time: time)
      }
}

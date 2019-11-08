//
//  TextMessage.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 10/23/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit

class TextMessage: Message {
    init(id : MsgID,
         conversationID : ConversationID,
         senderId : UserID,
         content : String,
         time : MsgTime)
    {
        super.init(id: id,
                   conversationID: conversationID,
                   senderId: senderId,
                   type: .text,
                   contents: [content],
                   time: time)
    }
}

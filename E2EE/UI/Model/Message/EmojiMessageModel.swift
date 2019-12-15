//
//  EmojiMessageModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 12/15/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

class EmojiMessageModel: MessageModel {
    init(id : MessageID = "",
         conversationID : InboxID = "",
         sender : UserModel = UserModel(),
         content : String = "",
         time : MessageTime = MessageTime())
    {
        super.init(id: id,
                   conversationID: conversationID,
                   sender: sender,
                   type: .emoji,
                   contents: [content],
                   time: time)        
    }
    
    var content : String{
        return contents.first ?? ""
    }
}

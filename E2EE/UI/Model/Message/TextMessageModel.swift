//
//  TextMessageModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class TextMessageModel: MessageModel {
    init(id : MessageID = "",
         conversationID : InboxID = "",
         sender : UserModel = UserModel(),
         content : String = "",
         time : MessageTime = MessageTime())
    {
        super.init(id: id,
                   conversationID: conversationID,
                   sender: sender,
                   type: .text,
                   contents: [content],
                   time: time)
    }
    
    var content : String{
        return contents.first ?? ""
    }
}
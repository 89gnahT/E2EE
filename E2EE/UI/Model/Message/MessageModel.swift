//
//  MessageModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class MessageModel: NSObject {
    var id : MessageID
    
    var inboxID : InboxID
    
    var sender : UserModel
    
    var type : MessageType
    
    var contents : [String]
    
    var time : MessageTime
    
    init(id : MessageID = "",
         conversationID : InboxID = "",
         sender : UserModel = UserModel(),
         type : MessageType = .text,
         contents : [String] = [],
         time : MessageTime = MessageTime())
    {
        self.id = id
        self.inboxID = conversationID
        self.sender = sender
        self.type = type
        self.contents = contents
        self.time = time
        
        super.init()
    }
    
    func isMyMessage()->Bool{
        return sender.id == DataManager.shared.you.id
    }
    
    func isRead() -> Bool{
        return time.seen != MessageTime.TimeInvalidate
    }
}

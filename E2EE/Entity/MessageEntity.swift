//
//  MessageEntity.swift
//  E2EE
//
//  Created by CPU12015 on 11/13/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

typealias MsgID = String

enum MsgType {
    case text
    case image
}

class MessageEntity {
    var id : MsgID
    var conversationID : ConversationID
    var senderId : UserID
    var msgType : MsgType
    var contents : [String]
    
    var sent : TimeInterval
    var deliveried : TimeInterval
    var seen : TimeInterval
    
    init(id : MsgID,
         conversationID : ConversationID,
         senderId : UserID,
         type : MsgType,
         contents : [String],
         timeSent : TimeInterval,
         timeDeliveried : TimeInterval,
         timeSeen : TimeInterval)
    {
        self.id = id
        self.conversationID = conversationID
        self.senderId = senderId
        self.msgType = type
        self.contents = contents
        self.sent = timeSent
        self.deliveried = timeDeliveried
        self.seen = timeSeen
    }
}

//
//  MessageEntity.swift
//  E2EE
//
//  Created by CPU12015 on 11/13/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

typealias MessageID = String

enum MessageType {
    case text
    case image
}

struct MessageTime {
    var sent : TimeInterval
    var deliveried : TimeInterval
    var seen : TimeInterval
    
    static let TimeInvalidate : TimeInterval = 0.0
    
    init(sent : TimeInterval = 0, deliveried : TimeInterval = 0, seen : TimeInterval = 0) {
        self.sent = sent
        self.deliveried = deliveried
        self.seen = seen
    }
}

struct MessageEntity {
    var id : MessageID
    var conversationID : ConversationID
    var senderId : UserID
    var msgType : MessageType
    var contents : [String]
    
    var sent : TimeInterval
    var deliveried : TimeInterval
    var seen : TimeInterval
    
    init(id : MessageID = "",
         conversationID : ConversationID = "",
         senderId : UserID = "",
         type : MessageType = .text,
         contents : [String] = [],
         timeSent : TimeInterval = 0.0,
         timeDeliveried : TimeInterval = 0.0,
         timeSeen : TimeInterval = 0.0)
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
    
    func isMyMessage() -> Bool{
        return senderId == SDataManager.shared.you.id
    }
    
    func isRead() -> Bool{
        return seen != MessageTime.TimeInvalidate
    }
}

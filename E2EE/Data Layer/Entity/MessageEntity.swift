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
    case emoji
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

class MessageEntity {
    var id : MessageID
    var inboxID : InboxID
    var senderId : UserID
    var msgType : MessageType
    var contents : [String]
    
    var sent : TimeInterval
    var deliveried : TimeInterval
    var seen : TimeInterval
    
    init(id : MessageID = "",
         conversationID : InboxID = "",
         senderId : UserID = "",
         type : MessageType = .text,
         contents : [String] = [],
         timeSent : TimeInterval = 0.0,
         timeDeliveried : TimeInterval = 0.0,
         timeSeen : TimeInterval = 0.0)
    {
        self.id = id
        self.inboxID = conversationID
        self.senderId = senderId
        self.msgType = type
        self.contents = contents
        self.sent = timeSent
        self.deliveried = timeDeliveried
        self.seen = timeSeen
    }
    
    func isMyMessage() -> Bool{
        return senderId == DataManager.shared.you.id
    }
    
    func isRead() -> Bool{
        return seen != MessageTime.TimeInvalidate
    }
    
    func convertToModel(withSender sender : UserModel) -> MessageModel{
        let time = MessageTime(sent: sent, deliveried: deliveried, seen: seen)
        switch msgType {
        case .image:
           return ImageMessageModel(id: id, conversationID: inboxID, sender: sender, contents: contents, time: time)
            
        case .text:
            return TextMessageModel(id: id, conversationID: inboxID, sender: sender, content: contents[0], time: time)
            
        case .emoji:
            return EmojiMessageModel(id: id, conversationID: inboxID, sender: sender, content: contents[0], time: time)
        }
    
    }
}

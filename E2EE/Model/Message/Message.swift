//
//  Message.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 10/23/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit

typealias MsgID = String

enum MsgType {
    case text
    case image
}

struct MsgTime {
    var sent : TimeInterval
    var deliveried : TimeInterval
    var seen : TimeInterval
    
    static let TimeInvalidate : TimeInterval = 0.0
    
    init(sent : TimeInterval, deliveried : TimeInterval, seen : TimeInterval) {
        self.sent = sent
        self.deliveried = deliveried
        self.seen = seen
    }
    
    init(sent : TimeInterval) {
        self.sent = sent
        self.deliveried = MsgTime.TimeInvalidate
        self.seen = MsgTime.TimeInvalidate
    }
}

class Message: NSObject {
    var id : MsgID
    var conversationID : ConversationID
    var senderId : UserID
    var msgType : MsgType
    var contents : [String]
    
    var time : MsgTime
    
    init(id : MsgID,
         conversationID : ConversationID,
         senderId : UserID,
         type : MsgType,
         contents : [String],
         time : MsgTime)
    {
        self.id = id
        self.conversationID = conversationID
        self.senderId = senderId
        self.msgType = type
        self.contents = contents
        self.time = time
        
        super.init()
    }
    
    func isUnread() -> Bool{
        return time.seen == MsgTime.TimeInvalidate || time.seen < time.sent
    }
    
    func markAsRead() -> Bool{
        if isUnread(){
            time.seen = thePresentTime
            return true
        }else{
            return false
        }
    }
}

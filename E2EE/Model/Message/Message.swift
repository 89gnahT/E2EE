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
}

class Message: NSObject {
    var id : MsgID
    var senderId : UserID
    var msgType : MsgType
    var contents : [String]
    
    var time : MsgTime
    
    init(id : MsgID, senderId : UserID, type : MsgType,contents : [String], time : MsgTime) {
        self.id = id
        self.senderId = senderId
        self.msgType = type
        self.contents = contents
        self.time = time
        
        super.init()
    }
}

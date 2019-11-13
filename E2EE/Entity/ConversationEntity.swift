//
//  ConversationEntity.swift
//  E2EE
//
//  Created by CPU12015 on 11/13/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

typealias ConversationID = String

enum ConversationType {
    case chat
    case groupChat
}

class ConversationEntity {
    var id : ConversationID
    var membersID : Array<UserID>
    var nameConversation : String
    var lastMsg : Message
    var type : ConversationType
    var muteTime : TimeInterval
    var numberOfNewMsg : Int
    
    init(cvsID : ConversationID,
         type : ConversationType,
         membersID : Array<UserID>,
         nameConversation : String,
         lastMsg : Message,
         muteTime : TimeInterval,
         numberOfUnreadMsg : Int = 0)
    {
        self.id = cvsID
        self.type = type
        self.membersID = membersID
        self.nameConversation = nameConversation
        self.lastMsg = lastMsg
        self.muteTime = muteTime
        self.numberOfNewMsg = numberOfUnreadMsg
    }
}

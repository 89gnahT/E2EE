//
//  ConversationEntity.swift
//  E2EE
//
//  Created by CPU12015 on 11/13/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public typealias ConversationID = String

public enum ConversationType {
    case chat
    case groupChat
}

struct ConversationEntity {
    var id : ConversationID
    var membersID : [UserID]
    var nameConversation : String
    var type : ConversationType
    var muteTime : TimeInterval
    
    init(cvsID : ConversationID = "",
         type : ConversationType = .chat,
         membersID : [UserID] = [],
         nameConversation : String = "",
         muteTime : TimeInterval = 0)
    {
        self.id = cvsID
        self.type = type
        self.membersID = membersID
        self.nameConversation = nameConversation
        self.muteTime = muteTime
    }
}

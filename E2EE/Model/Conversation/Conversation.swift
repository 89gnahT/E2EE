//
//  Conversation.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 10/23/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit

typealias ConversationID = String

enum ConversationType {
    case chat
    case groupChat
}

class Conversation: NSObject {
    var cvsID : ConversationID
    var membersID : Array<UserID>
    var nameConversation : String
    var lastMsg : Message
    var type : ConversationType
    var muteTime : TimeInterval
    
    init(cvsID : ConversationID, type : ConversationType, membersID : Array<UserID>, nameConversation : String, lastMsg : Message, muteTime : TimeInterval) {
        self.cvsID = cvsID
        self.type = type
        self.membersID = membersID
        self.nameConversation = nameConversation
        self.lastMsg = lastMsg
        self.muteTime = muteTime
        
        super.init()
    }
}

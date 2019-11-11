//
//  ChatConversation.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 10/25/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit

class ChatConversation: Conversation {
    init(cvsID: ConversationID,
         membersID: Array<UserID>,
         nameConversation: String,
         lastMsg: Message,
         muteTime : TimeInterval = MsgTime.TimeInvalidate,
         numberOfUnreadMsg : Int = 0)
    {
        super.init(cvsID: cvsID,
                   type: .chat,
                   membersID: membersID,
                   nameConversation: nameConversation,
                   lastMsg: lastMsg,
                   muteTime: muteTime,
                   numberOfUnreadMsg: numberOfUnreadMsg)
    }
}

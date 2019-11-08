//
//  GroupChatConversation.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 10/25/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit

class GroupChatConversation: Conversation {
     init(cvsID: ConversationID, membersID: Array<UserID>, nameConversation: String, lastMsg: Message, muteTime : TimeInterval) {
        super.init(cvsID: cvsID, type: .groupChat, membersID: membersID, nameConversation: nameConversation, lastMsg: lastMsg, muteTime: muteTime)
    }
}

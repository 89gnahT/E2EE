//
//  ChatConversationModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class ChatInboxModel: InboxModel {
    init(other : ChatInboxModel) {
        super.init(other: other)
    }
    
    init(cvsID : InboxID = "",
         members : Dictionary<UserID, UserModel> = [:],
         nameConversation : String = "",
         lastMsg : MessageModel = MessageModel(),
         muteTime : TimeInterval = 0,
         numberOfNewMessage : Int = 0,
         maskAsRead : Bool = false)
    {
        super.init(cvsID: cvsID,
                   type: .chat,
                   members: members,
                   nameConversation: nameConversation,
                   lastMsg: lastMsg,
                   numberOfNewMessage: numberOfNewMessage,
                   muteTime: muteTime,
                   maskAsRead: maskAsRead)
    }
    
    override func deepCopy() -> InboxModel {
        return ChatInboxModel(cvsID: id, members: members, nameConversation: nameConversation, lastMsg: lastMessage, muteTime: muteTime, numberOfNewMessage: numberOfNewMessage, maskAsRead: maskAsRead)
    }
}

//
//  GroupConversationModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class GroupInboxModel: InboxModel {
    init(other : GroupInboxModel) {
        super.init(other: other)
    }
    
    init(cvsID : InboxID = "",
         members : Dictionary<UserID, UserModel> = [:],
         nameConversation : String = "",
         lastMsg : MessageModel = MessageModel(),
         numberOfNewMessage : Int = 0,
         muteTime : TimeInterval = 0,
         maskAsRead : Bool = false)
    {
        super.init(cvsID: cvsID,
                   type: .groupChat,
                   members: members,
                   nameConversation: nameConversation,
                   lastMsg: lastMsg,
                   numberOfNewMessage: numberOfNewMessage,
                   muteTime: muteTime,
                   maskAsRead: maskAsRead)
    }
    
    override func deepCopy() -> InboxModel {
        return GroupInboxModel(cvsID: id, members: members, nameConversation: nameConversation, lastMsg: lastMessage, numberOfNewMessage: numberOfNewMessage, muteTime: muteTime, maskAsRead: maskAsRead)
    }
}

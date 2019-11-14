//
//  ChatConversationModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class ChatConversationModel: ConversationModel {
    init(cvsID : ConversationID = "",
         members : Dictionary<UserID, UserModel> = [:],
         nameConversation : String = "",
         lastMsgs : [MessageModel] = [],
         muteTime : TimeInterval = 0)
    {
        super.init(cvsID: cvsID,
                   type: .chat,
                   members: members,
                   nameConversation: nameConversation,
                   lastMsgs: lastMsgs,
                   muteTime: muteTime)
    }
}

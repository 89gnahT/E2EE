//
//  ConversationModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class ConversationModel: NSObject {
    var id : ConversationID
    
    var members : Dictionary<UserID, UserModel>
    
    var nameConversation : String
    
    // Content 1 last message (read or unread) or more unread message
    var lastMsgs : [MessageModel]
    
    var type : ConversationType
    
    var muteTime : TimeInterval
    
    init(cvsID : ConversationID = "",
         type : ConversationType = .chat,
         members : Dictionary<UserID, UserModel> = [:],
         nameConversation : String = "",
         lastMsgs : [MessageModel] = [],
         muteTime : TimeInterval = 0)
    {
        self.id = cvsID
        self.type = type
        self.members = members
        self.nameConversation = nameConversation
        self.lastMsgs = lastMsgs
        self.muteTime = muteTime
       
        super.init()
    }
    
    func isMuted() -> Bool{
        return muteTime > thePresentTime
    }
    
    func numberOfUnreadMessages() -> Int{
        var count = 0
        for m in lastMsgs{
            if !m.isRead() && !m.isMyMessage(){
                count += 1
            }
        }
        return count
    }
}

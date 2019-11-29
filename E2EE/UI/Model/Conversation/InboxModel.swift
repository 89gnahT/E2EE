//
//  ConversationModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public class InboxModel: NSObject {
    var id : InboxID
    
    var members : Dictionary<UserID, UserModel>
    
    var nameConversation : String

    var lastMessage : MessageModel
    
    var type : InboxType
    
    var numberOfNewMessage : Int
    
    var muteTime : TimeInterval
    
    var maskAsRead : Bool
    
    init(other : InboxModel) {
        self.id = other.id
        self.members = other.members
        self.nameConversation = other.nameConversation
        self.lastMessage = other.lastMessage
        self.type = other.type
        self.numberOfNewMessage = other.numberOfNewMessage
        self.muteTime = other.muteTime
        self.maskAsRead = other.maskAsRead
    }
    
    init(cvsID : InboxID = "",
         type : InboxType = .chat,
         members : Dictionary<UserID, UserModel> = [:],
         nameConversation : String = "",
         lastMsg : MessageModel = MessageModel(),
         numberOfNewMessage : Int = 0,
         muteTime : TimeInterval = 0,
         maskAsRead : Bool = false)
    {
        self.id = cvsID
        self.type = type
        self.members = members
        self.nameConversation = nameConversation
        self.lastMessage = lastMsg
        self.numberOfNewMessage = numberOfNewMessage
        self.muteTime = muteTime
        self.maskAsRead = maskAsRead
        
        super.init()
    }
    
    func isMuted() -> Bool{
        return muteTime > timeNow
    }
    
    func isUnread() -> Bool{
        return !maskAsRead && !lastMessage.isRead()
    }
    
    func deepCopy() -> InboxModel{
        return InboxModel(cvsID: id, type: type, members: members, nameConversation: nameConversation, lastMsg: lastMessage, numberOfNewMessage: numberOfNewMessage, muteTime: muteTime, maskAsRead: maskAsRead)
    }
}

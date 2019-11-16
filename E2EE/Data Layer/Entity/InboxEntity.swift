//
//  ConversationEntity.swift
//  E2EE
//
//  Created by CPU12015 on 11/13/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public typealias InboxID = String

public enum InboxType {
    case chat
    case groupChat
}

class InboxEntity {
    
    var id : InboxID
    
    var membersID : [UserID]
    
    var nameConversation : String
    
    var type : InboxType
    
    var numberOfNewMessage : Int
    
    var muteTime : TimeInterval
    
    var maskAsRead : Bool
    
    init(cvsID : InboxID = "",
         type : InboxType = .chat,
         membersID : [UserID] = [],
         nameConversation : String = "",
         numberOfNewMessage : Int = 0,
         muteTime : TimeInterval = 0,
         maskAsRead : Bool = false)
    {
        self.id = cvsID
        self.type = type
        self.membersID = membersID
        self.nameConversation = nameConversation
        self.numberOfNewMessage = 0
        self.muteTime = muteTime
        self.maskAsRead = maskAsRead
    }
    
    func isMuted() -> Bool{
        return muteTime > thePresentTime
    }
    
    func convertToModel(with membersModel : Dictionary<UserID, UserModel>, lastMessage : MessageModel) -> InboxModel{
       
        switch type {
        case .chat:
            return ChatInboxModel(cvsID: id, members: membersModel, nameConversation: nameConversation, lastMsg: lastMessage, muteTime: muteTime, numberOfNewMessage: 0, maskAsRead: maskAsRead)
            
        case .groupChat:
            return GroupInboxModel(cvsID: id, members: membersModel, nameConversation: nameConversation, lastMsg: lastMessage, numberOfNewMessage: 0, muteTime: muteTime, maskAsRead: maskAsRead)
        }
    }
}

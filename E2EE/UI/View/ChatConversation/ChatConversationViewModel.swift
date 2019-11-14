//
//  ConversationViewModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ChatConversationViewModel {
    private(set) var model : ChatConversationModel
    
    init(model : ChatConversationModel) {
        self.model = model
    }
    
    public var nameConversation : NSAttributedString = NSAttributedString()
    
    public var timeConversation : NSAttributedString = NSAttributedString()
    
    public var messageContent : NSAttributedString = NSAttributedString()
    
    public var avatarURL : URL?
    
    public var muteIcon : UIImage?
    
    public var numberOfUnreadMessage : NSAttributedString = NSAttributedString()
    
    public func reloadData(){
        guard let lastMsg = model.lastMsgs.last else {
            return
        }
        
        let isReadMsg = lastMsg.isRead()
        
        let friendChat = model.members.values.first { (a) -> Bool in
            return a.id != CDataManager.shared.you.id
        }
        avatarURL = URL(string: friendChat!.avatarURL)!
        
        nameConversation = atributedString(model.nameConversation, fontSize: 16, isHighLight: !isReadMsg, highLightColor: UIColor(named: "title_in_cell_color")!,
        normalColor: UIColor(named: "title_in_cell_color")!)
        
        messageContent = atributedString(messageString, fontSize: 14, isHighLight: !isReadMsg, highLightColor: UIColor(named: "highlight_sub_title_in_cell_color")!,
        normalColor: UIColor(named: "normal_sub_title_in_cell_color")!)
        
        timeConversation = atributedString(timeToString, fontSize: 12, isHighLight: !isReadMsg, highLightColor: UIColor(named: "highlight_sub_title_in_cell_color")!,
        normalColor: UIColor(named: "normal_sub_title_in_cell_color")!)
        
        muteIcon = model.isMuted() ? UIImage(named: "mute_icon.png") : nil
        
        numberOfUnreadMessage = atributedString(numberOfUnreadMessageString, fontSize: 12, isBold: true, foregroundColor: .white)
    }
}

extension ChatConversationViewModel{
    
    private var messageString : String{
        guard let lastMsg = model.lastMsgs.last else {
            return ""
        }
        
        return lastMsg.type == .text ? lastMsg.contents.first! : "[Hình ảnh]"
    }
    
    private var numberOfUnreadMessageString : String{
        let value = model.numberOfUnreadMessages()
        var string : String
        if value <= 0{
            string = ""
        }else{
            if value > 5{
                string = " 5+ "
            }else{
                string = "  " + String(value) + "  "
            }
        }
        return string
    }
    
    private var timeToString : String{
        let time = model.lastMsgs.last?.time.sent
        
        guard time != nil else {
            return ""
        }
        var timeString : String
        
        let deltaTime = thePresentTime - time!
        
        if deltaTime < MINUTE{
            timeString = round(deltaTime) + " giây"
        }else
            if deltaTime < HOURS{
                timeString = round(deltaTime / MINUTE) + " phút"
            }else
                if deltaTime < DAY{
                    timeString = round(deltaTime / HOURS) + " giờ"
                }else
                    if deltaTime < WEEK {
                        timeString = round(deltaTime / DAY) + " ngày"
                    }else{
                        func getTimeWithFormath(time : TimeInterval, format : String) -> String{
                            let date = Date(timeIntervalSinceReferenceDate: time)
                            let formatter = DateFormatter()
                            formatter.dateFormat = format
                            
                            return formatter.string(from: date as Date)
                        }
                        
                        timeString = getTimeWithFormath(time: time!, format: "dd/MM/yyyy")
                        
                        if timeString.hasSuffix(getTimeWithFormath(time: thePresentTime, format: "yyyy")){
                            timeString = getTimeWithFormath(time: time!, format: "dd/MM")
                        }
        }
        
        return timeString
    }
}

extension ChatConversationViewModel{
    private func round(_ x : Double)->String{
        return String(Int(x + 0.5))
    }
}

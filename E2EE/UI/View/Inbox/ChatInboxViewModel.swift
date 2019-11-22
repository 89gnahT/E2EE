//
//  ConversationViewModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ChatInboxViewModel {
    private(set) var model : ChatInboxModel
    
    init(model : ChatInboxModel) {
        self.model = model
    }
    
    public var modelID : InboxID{
        return model.id
    }
    
    public var nameConversation : NSAttributedString = NSAttributedString()
    
    public var timeConversation : NSAttributedString = NSAttributedString()
    
    public var messageContent : NSAttributedString = NSAttributedString()
    
    public var avatarURL : URL?
    
    public var muteIcon : UIImage?
    
    public var notifyUnreadMessage : UIImage?
    
    public func reloadData(_ completion : (() -> Void)?){
        ASPerformBlockOnBackgroundThread {
           
            let isRead = !self.model.isUnread()
            
            let friendChat = self.model.members.values.first { (a) -> Bool in
                return a.id != DataManager.shared.you.id
            }
            self.avatarURL = URL(string: friendChat!.avatarURL)!
            
            self.nameConversation = attributedString(self.model.nameConversation, fontSize: 16, isHighLight: !isRead, highLightColor: UIColor(named: "title_in_cell_color")!,
            normalColor: UIColor(named: "title_in_cell_color")!)
            
            self.messageContent = attributedString(self.messageString, fontSize: 14, isHighLight: !isRead, highLightColor: UIColor(named: "highlight_sub_title_in_cell_color")!,
            normalColor: UIColor(named: "normal_sub_title_in_cell_color")!)
            
            self.timeConversation = attributedString(self.timeToString, fontSize: 12, isHighLight: !isRead, highLightColor: UIColor(named: "highlight_sub_title_in_cell_color")!,
            normalColor: UIColor(named: "normal_sub_title_in_cell_color")!)
            
            self.muteIcon = self.model.isMuted() ? UIImage(named: "mute_icon") : nil
            
            self.notifyUnreadMessage = !isRead ? UIImage(named: "dot") : nil
            
            completion?()
        }
    }
}

extension ChatInboxViewModel{
    
    private var messageString : String{
        let lastMsg = model.lastMessage 
        
        return lastMsg.type == .text ? lastMsg.contents.first! : "[Hình ảnh]"
    }
    
    private var numberOfUnreadMessageString : String{
        let value = model.numberOfNewMessage
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
        let time = model.lastMessage.time.sent
        
        var timeString : String
        
        let deltaTime = thePresentTime - time
        
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
                        
                        timeString = getTimeWithFormath(time: time, format: "dd/MM/yyyy")
                        
                        if timeString.hasSuffix(getTimeWithFormath(time: thePresentTime, format: "yyyy")){
                            timeString.removeSubrange(Range<String.Index>(NSRange(location: 5, length: 5), in: timeString)!)
                        }
        }
        
        return timeString
    }
}

extension ChatInboxViewModel{
    private func round(_ x : Double)->String{
        return String(Int(x + 0.5))
    }
}

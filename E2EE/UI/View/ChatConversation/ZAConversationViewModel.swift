//
//  ZATableCellNodeModelView.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 10/30/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public typealias ImageDownloadCompletionClosure = (_ image: UIImage? ) -> Void

class ZAConversationViewModel  : NSObject{
    private var model : ChatConversation?
    
    init(conversation : ChatConversation) {
        super.init()
        self.model = conversation
    }
    
    public var avatarURL : URL?{
        let user = FakeData.shared.users.first { (u) -> Bool in
            return u.id == (self.model?.membersID.last)!}
        
        return URL(string: user!.avatarURL!)
    }
    
    public var title : String?{
        return model?.nameConversation
    }
    
    public var rightTitle : String?{
        let time = model?.lastMsg.time.sent
        
        guard time != nil else {
            return nil
        }
        var timeString : String
        
        let deltaTime = Date.timeIntervalSinceReferenceDate - time!
        func round(_ x : Double)->String{
            return String(Int(x + 0.5))
        }
        
        if deltaTime < 60{
            timeString = "Vừa xong"
        }else
            if deltaTime < 3600{
                timeString = round(deltaTime / 60 + 0.5) + " phút"
            }else
                if deltaTime < 24 * 3600{
                    timeString = round(deltaTime / 3600 + 0.5) + " giờ"
                }else
                    if deltaTime < 24 * 3600 * 7 {
                        timeString = round(deltaTime / 24 / 3600 + 0.5) + " ngày"
                    }else{
                        func getTimeWithFormath(time : TimeInterval, format : String) -> String{
                            let date = Date(timeIntervalSinceReferenceDate: time)
                            let formatter = DateFormatter()
                            formatter.dateFormat = format
                            return formatter.string(from: date as Date)
                        }
                        
                        timeString = getTimeWithFormath(time: time!, format: "dd/MM/yyyy")
                        
                        if timeString.hasSuffix(getTimeWithFormath(time: Date.timeIntervalSinceReferenceDate, format: "yyyy")){
                            timeString = getTimeWithFormath(time: time!, format: "dd/MM")
                        }
        }
        
        return timeString
    }
    
    public var subTitle : String?{
        guard (model != nil) else {
            return nil
        }
        
        var subTitle : String
        switch model?.lastMsg.msgType {
        case .text:
            subTitle = (model?.lastMsg.contents.first)!
        default:
            subTitle = "[Hình ảnh]"
        }
        
        return subTitle
    }
    
    public var isReadMsg : Bool?{
        guard (model != nil && model?.lastMsg != nil) else {
            return nil
        }
        let msgTime = model?.lastMsg.time
        if msgTime?.seen != MsgTime.TimeInvalidate{
            return true
        }
        return false
    }
    
    public var iconRightSubTitle : ASImageNode?{
        if Date.timeIntervalSinceReferenceDate > model!.muteTime{
            return nil
        }
        
        let icon = ASImageNode()
        icon.image = UIImage(named: "mute_icon.png")
        return icon
    }
    
    public var iconRightTitle : ASImageNode?{
        return nil
    }
    
    public var avatar : ASImageNode?{
        return ASImageNode()
    }
    public func getAvatarImage(completionHanlder : @escaping ImageDownloadCompletionClosure){
        DispatchQueue.global().async {
            let user = FakeData.shared.users.first { (u) -> Bool in
                return u.id == (self.model?.membersID.last)!
            }
            if user?.avatarURL != nil{
                // TODO
                
            }else{
                completionHanlder(self.defaultAvatarImage(gender: user?.gender ?? .none))
            }
            
        }
    }
    
    private func defaultAvatarImage(gender : Gender) -> UIImage?{
        var imageName : String
        switch gender {
        case .male:
            imageName = "male_avatar"
        case .female:
            imageName = "female_avatar"
        default:
            imageName = "default_avatar"
        }
        
        return UIImage(named: imageName)!
    }
}

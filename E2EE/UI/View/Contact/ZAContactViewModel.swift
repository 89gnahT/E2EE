//
//  ZAContactModelView.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/7/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public class ZAContactViewModel {
    private var model : User?
    
    init(model : User) {
        self.model = model
    }
    
    public var avatarURL : URL?{
        return URL(string: model!.avatarURL!)
    }
    
    public var title : String?{
        return model?.nickName
    }
    
    public var subTitle : String?{
        guard (model != nil) else {
            return nil
        }
        return nil
    }
    
    public var icon1RightTitle : ASImageNode?{
        let icon = ASImageNode()
        icon.image = UIImage(named: "call_icon")
        return icon
    }
    
    public var icon2RightTitle : ASImageNode?{
        let icon = ASImageNode()
        icon.image = UIImage(named: "videocall_icon")
        return icon
    }
    
    public var avatar : ASImageNode?{
        return ASImageNode()
    }
    
    public func getAvatarImage(completionHanlder : @escaping ImageDownloadCompletionClosure){
        DispatchQueue.global().async {
            var imageName : String
            switch self.model?.gender {
            case .male:
                imageName = "male_avatar"
            case .female:
                imageName = "female_avatar"
            default:
                imageName = "default_avatar"
            }
        
            let image = UIImage(named: imageName)
            completionHanlder(image)
        }
    }
    
}

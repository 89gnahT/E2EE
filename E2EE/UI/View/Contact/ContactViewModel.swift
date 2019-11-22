//
//  ZAContactModelView.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 11/7/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public class ContactViewModel {
    private(set) var model : UserModel
    
    init(model : UserModel) {
        self.model = model
    }
    
    public var avatarURL : URL?
    
    public var userName = NSAttributedString()
    
    public var detail = NSAttributedString()
    
    public var callIcon : UIImage?
    
    public var videoCallIcon : UIImage?
    
    public func reloadData(){
        avatarURL = URL(string: model.avatarURL)
        
        userName = attributedString(model.name, fontSize: 16, isBold: false, foregroundColor: UIColor(named: "title_in_cell_color")!)
        
        callIcon = UIImage(named: "call_icon")
        
        videoCallIcon = UIImage(named: "videocall_icon")
    }
}

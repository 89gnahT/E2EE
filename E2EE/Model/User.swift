//
//  User.swift
//  LearnTextureKit
//
//  Created by CPU12015 on 10/23/19.
//  Copyright © 2019 CPU12015. All rights reserved.
//

import UIKit

class User: NSObject {
    var id : UserID
    var name : String
    var nickName : String
    var avatarURL : String?
    var gender : Gender
    
    init(id : String,
         name : String,
         avatarURL : String? = nil,
         gender : Gender = .none)
    {
        self.id = id
        self.name = name
        self.nickName = name
        self.gender = gender
        self.avatarURL = avatarURL
        
        super.init()
    }
}

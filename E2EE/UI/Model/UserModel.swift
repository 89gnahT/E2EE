//
//  UserModel.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/14/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit


public class UserModel: NSObject {
    var id : UserID
    var name : String
    var nickName : String
    var avatarURL : String
    var gender : Gender
    
    init(id : String = "",
         name : String = "",
         avatarURL : String = "",
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

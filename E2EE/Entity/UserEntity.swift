//
//  UserEntity.swift
//  E2EE
//
//  Created by CPU12015 on 11/13/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

public typealias UserID = String

enum Gender {
    case male
    case female
    case other
    case none
}

class UserEntity {
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
    }
}

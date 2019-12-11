//
//  UserModel.swift
//  E2EE
//
//  Created by CPU11899 on 11/20/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import FirebaseAuth

public class UserModel: NSObject {
    private var userName: String = String()
    private var password: String = String()
    private var fullName: String = String()
    
    init(userName username: String, password: String, fullName fullname: String) {
        super.init()
        self.userName = username
        self.password = password
        self.fullName = fullname
    }
}

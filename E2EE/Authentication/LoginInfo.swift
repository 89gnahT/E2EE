//
//  LoginInfo.swift
//  E2EE
//
//  Created by Thang on 11/12/2019.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

class LoginToken {
    
}

class LoginInfo {
    let rawID: String
    let rawPwd: String
    
    init(ID: String, password: String) {
        self.rawID = ID
        self.rawPwd = password
    }
}

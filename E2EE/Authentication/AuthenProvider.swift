//
//  AuthenProvider.swift
//  E2EE
//
//  Created by Thang on 11/12/2019.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

enum AuthenError: Error {
    case invalidPhoneNumber
    case invalidPassword
    case noInternet
    case serverError
    case accountNotVerify
    case accountSuspend
    case missingFirebaseAuthVrfID
}

enum LoginServiceProvider {
    case none
    case Firebase
    case Google
    case Facebook
}


//protocol AuthenProvider {
//}

protocol RegularAuthenProvider {
    
    func resetPassword(completion:(Bool?, Error?) -> Void) -> Void
    
    func register(user: UserModel, completion: @escaping(LoginToken?, Error?) -> Void) -> Void
    
    func login(completion: @escaping(UserModel?, LoginToken?, Error?) -> Void) -> Void
}

protocol FirebasePhoneAuthenProvider {
    
    func receiveVrfCodeFor(phoneNumber: String, completion: @escaping(Error?) -> Void) -> Void
    
    func login(vrfCode: String, completion: @escaping(_ firstTimeLogin:Bool?, _ error:Error?) -> Void) -> Void
}

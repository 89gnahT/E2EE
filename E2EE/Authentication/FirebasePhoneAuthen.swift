//
//  FirebasePhoneAuthen.swift
//  E2EE
//
//  Created by Thang on 11/12/2019.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebasePhoneAuthen: FirebasePhoneAuthenProvider {
    
    func receiveVrfCodeFor(phoneNumber: String, completion: @escaping(Error?) -> Void) -> Void                  {
        Auth.auth().languageCode = "vi"
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (vrfID, error) in
            if let error = error {
                completion(error)
                return
            }
            UserDefaults.standard.set(vrfID, forKey: "FirebasePhoneAuthVrfID")
        }
    }
    
    func login(vrfCode: String, completion: @escaping(_ firstTimeLogin:Bool?, _ error:Error?) -> Void) -> Void {
        guard let vrfID = UserDefaults.standard.string(forKey: "FirebasePhoneAuthVrfID") else {
            completion(nil, AuthenError.missingFirebaseAuthVrfID)
            return
        }
        let credential = PhoneAuthProvider.provider().credential(
        withVerificationID: vrfID,
        verificationCode: vrfCode)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(authResult?.additionalUserInfo?.isNewUser, nil)
        }
    }
    
}

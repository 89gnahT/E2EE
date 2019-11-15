//
//  ContactModel.swift
//  E2EE
//
//  Created by Thang on 13/11/2019.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import Contacts

struct ContactModel {
    var identifier : String
    var givenName  : String
    var middleName : String
    var familyName : String
    var nameSuffix : String
    var phoneNumberArray = Array<String>()

    init(cnContact: CNContact) {
        self.identifier = cnContact.identifier
        self.givenName  = cnContact.givenName
        self.middleName = cnContact.middleName
        self.familyName = cnContact.familyName
        self.nameSuffix = cnContact.nameSuffix
        for label in cnContact.phoneNumbers {
            let phone = label.value.stringValue
            if phone.count > 0 {
                phoneNumberArray.append(phone)
            }
        }
    }
}

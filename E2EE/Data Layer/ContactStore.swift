//
//  ContactStore.swift
//  E2EE
//
//  Created by Thang on 13/11/2019.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation
import Contacts

class ContactStore {
    
    var callbackItemArray: Array<CallbackItem>
    var contactStoreSerialQueue: DispatchQueue
    var isFetching: Bool
    
    let arrayKey = [CNContactIdentifierKey,
                    CNContactFamilyNameKey,
                    CNContactMiddleNameKey,
                    CNContactGivenNameKey,
                    CNContactNameSuffixKey,
                    CNContactPhoneNumbersKey]
    static let shared = ContactStore()
    
    private init() {
        self.callbackItemArray = []
        self.contactStoreSerialQueue = DispatchQueue(label:" Serial queue: Thread-safe fetching queue")
        self.isFetching = false
    }
    
    func authorizationStatus() -> ContactAuthorizationStatus {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        @unknown default:
            return .unknown
        }
    }
    
    func requestAuthorization(callback: ((Bool, Error?)-> Void)?) {
        let store = CNContactStore()
        store.requestAccess(for: CNEntityType.contacts) { (granted, error) in
            callback?(granted, error)
        }
    }
    
    func fetchContact(callback: (([ContactModel]?, Error?) -> Void)?, currentQueue: DispatchQueue?) {
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            if (callback) != nil && (currentQueue) != nil {
                self.contactStoreSerialQueue.async {
                    let callbackItem = CallbackItem.init(callback: callback!, queue: currentQueue!)
                    self.callbackItemArray.append(callbackItem)
                    if !self.isFetching {
                        self.isFetching = true
                        DispatchQueue(label: "Concurrent queue: Fetching contact from phone", attributes: .concurrent).async {
                            let store = CNContactStore()
                            let keys = self.arrayKey
                            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                            var cnContactArray = [ContactModel]()
                            do {
                                try store.enumerateContacts(with: request){ (contact, cursor) -> Void in
                                    let contactModel: ContactModel = ContactModel.init(cnContact: contact)
                                    cnContactArray.append(contactModel)
                                }
                            } catch let error {
                                self.forwardAll(contactArray: cnContactArray, error: error)
                                print("Fetch contact error: \(error)")
                            }
                        }
                    }
                }
            }
        }
        else {
            print("Permisison to use contacts != authorized")
            self.forwardAll(contactArray: nil, error: ContactAuthorizationError.authorizationNotGranted)
        }
    }
    
    func forwardAll(contactArray: [ContactModel]?, error: Error?) {
        for item in callbackItemArray {
            item.queue.async {
                item.callback(contactArray, error)
            }
        }
        self.isFetching = false
        self.callbackItemArray.removeAll()
    }
}

class CallbackItem {
    var callback: ([ContactModel]?, Error?) -> Void
    var queue: DispatchQueue
    
    init(callback: (([ContactModel]?,Error?) -> Void)!, queue: DispatchQueue) {
        self.callback = callback
        self.queue = queue
    }
}

extension ContactStore {
    enum ContactAuthorizationStatus {
        case notDetermined
        case authorized
        case denied
        case restricted
        case unknown
    }
    
    enum ContactAuthorizationError: Error {
        case authorizationNotGranted
    }
}

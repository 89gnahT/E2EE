
//
//  ChatManager.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

enum DataError {
    case notFound
    case cannotDoIt
    case none
}

enum UpdateType {
    case new
    case changed
    case delete
}

enum ValueChanged{
    case messageChanged
    case conversationChanged
    case userChanged
}


protocol DataManagerListenerDelegate : NSObjectProtocol{
    func messageChanged(_ msg : MessageModel, updateType : UpdateType, oldValue : MessageModel?)
    
    func conversationChanged(_ cvs : InboxModel, updateType : UpdateType, oldValue : InboxModel?)
    
    func userChanged(_ user : UserModel, updateType : UpdateType, oldValue : UserModel?)
}

class DataManager: NSObject {
    static let shared = DataManager()
    
    private var taskQueue = DispatchQueue(label: "business layer: data manager task queue")
    
    private var callBackQueue = DispatchQueue(label: "business layer: data manager callback queue",
                                              qos: .default,
                                              attributes: .concurrent,
                                              autoreleaseFrequency: .inherit,
                                              target: nil)
    
    private var listenItems = Dictionary<ValueChanged, Array<ObserverItem>>()
    
    private var inboxes = Dictionary<InboxID, InboxModel>()
    
    private var people = Dictionary<UserID, UserModel>()
    
    private var friends = Dictionary<UserID, UserID>()
    
    private(set) var you = UserModel()
    
    private override init() {
        
    }
}

// MARK: - Fetching Data
extension DataManager{
    public func batchFetchingAllData(_ completion : @escaping () -> Void, callbackQueue : DispatchQueue?){
        taskQueue.async {
            Database.shared.batchFetchingAllData(with: { (you, friends, people, conversationsWithLastMessage) in
                self.you = you.convertToModel()
                
                for p in people{
                    self.people.updateValue(p.value.convertToModel(), forKey: p.key)
                }
                
                // Convert entity to model
                for i in conversationsWithLastMessage{
                    let tuple = i.value
                    
                    let sender = self.people[tuple.1.senderId]!
                    let lastMessageModel = tuple.1.convertToModel(with: sender)
                    
                    var members = [UserID : UserModel]()
                    for i in tuple.0.membersID{
                        members.updateValue(self.people[i]!, forKey: i)
                    }
                    let cvs = tuple.0.convertToModel(with: members, lastMessage: lastMessageModel)
                    
                    self.inboxes.updateValue(cvs, forKey: cvs.id)
                }
                
                self.friends = friends
                
                let queue = callbackQueue != nil ? callbackQueue : self.callBackQueue
                queue?.async {
                    completion()
                }
                
            }, callbackQueue: self.taskQueue)
        }
    }
    
    public func fetchConversationModels(_ completion : @escaping (_ models : [InboxModel]) -> Void, callbackQueue : DispatchQueue?){
        taskQueue.async {
            let models = self.inboxes.values.sorted { (a, b) -> Bool in
                return a.lastMessage.time.sent > b.lastMessage.time.sent
            }
            
            let queue = callbackQueue != nil ? callbackQueue : self.callBackQueue
            queue?.async {
                completion(models)
            }
        }
    }
    
    public func fetchContactModels(_ completion : @escaping (_ models : [UserModel]) -> Void, callbackQueue : DispatchQueue?){
        taskQueue.async {
            var contacts = [UserModel]()
            for i in self.friends{
                contacts.append(self.people[i.key]!)
            }
            
            let queue = callbackQueue != nil ? callbackQueue : self.callBackQueue
            queue?.async {
                completion(contacts)
            }
        }
    }
}

// MARK: - Public threadSafde Method
extension DataManager{
    public func deleteConversationWithID(_ id : InboxID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            guard let inbox = self.inboxes[id] else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            self.inboxes.removeValue(forKey: id)
            
            self.callback(WithError: .none, completion: completion)
            
            self.callbackForDataChanged(object: inbox, forEvent: .conversationChanged, updateType: .delete, oldVaule: nil)
        }
    }
    
    public func muteConversationWithID(_ id : InboxID, until time : TimeInterval, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            guard let inbox = self.inboxes[id] else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            DispatchQueue.main.async {
                let old = inbox.deepCopy()
                
                inbox.muteTime = time
                
                self.callback(WithError: .none, completion: completion)
                
                self.callbackForDataChanged(object: inbox, forEvent: .conversationChanged, updateType: .changed, oldVaule: old)
            }
        }
    }
    
    public func unmuteConversationWithID(_ id : InboxID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            guard let inbox = self.inboxes[id] else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            if inbox.isMuted(){
                DispatchQueue.main.async {
                    let old = inbox.deepCopy()
                    
                    inbox.muteTime = 0
                    
                    self.callback(WithError: .none, completion: completion)
                    
                    self.callbackForDataChanged(object: inbox, forEvent: .conversationChanged, updateType: .changed, oldVaule: old)
                }
            }else{
                self.callback(WithError: .cannotDoIt, completion: completion)
            }
            
        }
    }
    
    public func markAsRead(conversationID id : InboxID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            guard let inbox = self.inboxes[id] else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            if !inbox.maskAsRead{
                DispatchQueue.main.async {
                    let old = inbox.deepCopy()
                    
                    inbox.maskAsRead = true
                    
                    self.callback(WithError: .none, completion: completion)
                    
                    self.callbackForDataChanged(object: inbox, forEvent: .conversationChanged, updateType: .changed, oldVaule: old)
                }
            }else{
                self.callback(WithError: .none, completion: completion)
            }
        }
    }
    
    public func markAsRead(messageID id : MessageID, conversationID cvsID : InboxID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            
        }
    }
    
}

// MARK: - Private helper method
extension DataManager{
    private func u_markAsRead(message m : inout MessageEntity) -> Bool{
        if !m.isRead(){
            
            return true
        }
        return false
    }
    
    private func u_deleteConversation(_ c : InboxEntity) -> Bool{
        
        return true
    }
    
    private func callback(WithError error : DataError, completion : ((_ error : DataError) -> Void)?){
        if completion != nil{
            self.callBackQueue.async {
                completion!(error)
            }
        }
    }
}

// MARK: - Observer
extension DataManager{
    class ObserverItem : NSObject{
        var target : DataManagerListenerDelegate
        var queue : DispatchQueue
        
        init(target : DataManagerListenerDelegate, queue : DispatchQueue) {
            self.target = target
            self.queue = queue
        }
    }
    
    public func addObserver(for event : ValueChanged, target : DataManagerListenerDelegate, callBackQueue : DispatchQueue? = nil){
        taskQueue.async {
            let queue = callBackQueue != nil ? callBackQueue : self.callBackQueue
            
            let ob = ObserverItem(target: target, queue: queue!)
            
            if self.listenItems[event] != nil{
                self.listenItems[event]?.append(ob)
            }else{
                self.listenItems.updateValue([ob], forKey: event)
            }
        }
    }
    
    public func removeObserver(for event : ValueChanged, target : DataManagerListenerDelegate){
        taskQueue.async {
            self.listenItems[event]!.removeAll { (a) -> Bool in
                return a.target.isEqual(target)
            }
        }
    }
    
    private func callbackForDataChanged(object : NSObject, forEvent event : ValueChanged, updateType : UpdateType, oldVaule : NSObject?){
        taskQueue.async {
            guard self.listenItems[event] != nil else{
                return
            }
            for i in Array(self.listenItems[event]!){
                i.queue.async {
                    switch event{
                        
                    case .conversationChanged:
                        i.target.conversationChanged(object as! InboxModel, updateType: updateType, oldValue: oldVaule as? InboxModel)
                        
                    case .messageChanged:
                        i.target.messageChanged(object as! MessageModel, updateType: updateType, oldValue: oldVaule as? MessageModel)
                        
                    case .userChanged:
                        i.target.userChanged(object as! UserModel, updateType: updateType, oldValue: oldVaule as? UserModel)
                    }
                }
            }
        }
    }
}

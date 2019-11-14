
//
//  ChatManager.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit


protocol SDataManagerListenerDelegate{
    
}

class SDataManager: NSObject {
    static let shared = SDataManager()
    
    private var taskQueue = DispatchQueue(label: "business layer: data manager task queue")
    
    private var callBackQueue = DispatchQueue(label: "business layer: data manager callback server",
                                              qos: .default,
                                              attributes: .concurrent,
                                              autoreleaseFrequency: .inherit,
                                              target: nil)
    
    public var delegate : SDataManagerListenerDelegate?
    
    private var conversations = Dictionary<ConversationID, ConversationEntity>()
    
    private var people = Dictionary<UserID, UserEntity>()
    
    private var friends = Dictionary<UserID, UserID>()
    
    private var rooms = Dictionary<ConversationID, Dictionary<MsgID, MessageEntity>>()
    
    private var you : UserEntity = UserEntity()
    
    private override init() {
        
    }
    
    public func batchFetchingAllData(_ completion : @escaping (_ you : UserEntity,
        _ friends : [UserID],
        _ people : Dictionary<UserID, UserEntity>,
        _ conversations : Dictionary<ConversationID, ConversationEntity>,
        _ rooms : Dictionary<ConversationID, Dictionary<MsgID, MessageEntity>>) -> Void, callbackQueue : DispatchQueue?){
        taskQueue.async { [weak self] in
            Database.shared.batchFetchingAllData(with: { (you, friends, people, conversations, rooms) in
                self?.you = you
                self?.conversations = conversations
                self?.people = people
                self?.friends = friends
                self?.rooms = rooms
                
                let queue = callbackQueue != nil ? callbackQueue : self?.callBackQueue
                queue?.async {
                    completion(you, Array(friends.values), people, conversations, rooms)
                }
                
            }, callbackQueue: self?.taskQueue)
        }
    }
}

extension SDataManager{
    public func sentMessage(){
        
    }
}

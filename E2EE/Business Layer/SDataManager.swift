
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

protocol SDataManagerListenerDelegate{
    func messageChanged(_ msg : MessageEntity, dataChanged : DataChangedType)
    
    func conversationChanged(_ cvs : ConversationEntity, dataChanged : DataChangedType)
    
    func userChanged(_ user : UserEntity, dataChanged : DataChangedType)
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
    
    private var rooms = Dictionary<ConversationID, Dictionary<MessageID, MessageEntity>>()
    
    private var you : UserEntity = UserEntity()
    
    private override init() {
        delegate = CDataManager.shared
    }
    
    public func batchFetchingAllData(_ completion : @escaping (_ you : UserEntity,
        _ friends : [UserID],
        _ people : Dictionary<UserID, UserEntity>,
        _ conversations : Dictionary<ConversationID, ConversationEntity>,
        _ rooms : Dictionary<ConversationID, Dictionary<MessageID, MessageEntity>>) -> Void, callbackQueue : DispatchQueue?){
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
    
    public func markAsRead(messageID id : MessageID, conversationID cvsID : ConversationID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            guard var m = self.rooms[cvsID]![id] else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            if self.u_markAsRead(message: &m){
                self.callback(WithError: .none, completion: completion)
            }else{
                self.callback(WithError: .cannotDoIt, completion: completion)
            }
        }
    }
    
    public func deleteConversationWithID(_ id : ConversationID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            guard let c = self.conversations[id] else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            if self.u_deleteConversation(c){
                self.callback(WithError: .none, completion: completion)
            }else{
                self.callback(WithError: .cannotDoIt, completion: completion)
            }
        }
    }
    
    public func muteConversationWithID(_ id : ConversationID, until time : TimeInterval, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            guard var c = self.conversations[id] else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            if !c.isMuted(){
                c.muteTime = time
                
                self.conversations.updateValue(c, forKey: c.id)
                self.delegate?.conversationChanged(c, dataChanged: .changed)
                
                self.callback(WithError: .none, completion: completion)
            }else{
                self.callback(WithError: .cannotDoIt, completion: completion)
            }
        }
    }
    
    public func unmuteConversationWithID(_ id : ConversationID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            guard var c = self.conversations[id] else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            if c.isMuted(){
                c.muteTime = 0
                
                self.conversations.updateValue(c, forKey: c.id)
                self.delegate?.conversationChanged(c, dataChanged: .changed)
                
                self.callback(WithError: .none, completion: completion)
            }else{
                self.callback(WithError: .cannotDoIt, completion: completion)
            }
        }
    }
}

extension SDataManager{
    private func u_markAsRead(message m : inout MessageEntity) -> Bool{
        if !m.isRead(){
            m.seen = thePresentTime
            
            rooms[m.conversationID]!.updateValue(m, forKey: m.id)
            delegate?.messageChanged(m, dataChanged: .changed)
            
            // TODO: - Save in database
            
            return true
        }
        return false
    }
    
    private func u_deleteConversation(_ c : ConversationEntity) -> Bool{
        conversations.removeValue(forKey: c.id)
        rooms[c.id]!.removeAll()
        rooms.removeValue(forKey: c.id)
        
        delegate?.conversationChanged(c, dataChanged: .delete)
        
        return true
    }
}

extension SDataManager{
    private func callback(WithError error : DataError, completion : ((_ error : DataError) -> Void)?){
        if completion != nil{
            self.callBackQueue.async {
                completion!(error)
            }
        }
    }
}

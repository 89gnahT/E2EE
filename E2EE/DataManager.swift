//
//  ChatManager.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

protocol DataManagerListenerDelegate{
    func messageChanged(_ msg : Message, dataChanged : DataChangedType)
    
    func conversationChanged(_ cvs : Conversation, dataChanged : DataChangedType)
    
    func userChanged(_ user : User, dataChanged : DataChangedType)
}

extension DataManagerListenerDelegate {
    
}

class DataManager: NSObject {
    static let shared = DataManager()
    
    private var taskQueue = DispatchQueue(label: "data manager task queue")
    
    private var callBackQueue = DispatchQueue(label: "data manager callback", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    private var listenItems = Dictionary<Int, Array<ObserverItem>>()
    
    private var conversations = Dictionary<ConversationID, Conversation>()
    
    private var friends = Dictionary<UserID, User>()
    
    private var rooms = Dictionary<ConversationID, Dictionary<MsgID, Message>>()
    
    public var you : User!
    
    private override init() {
        super.init()
        
        
        DataStore.shared.fetchDataWhenStartAppWithCompletion({ (you, friends, conversations, rooms) in
            self.you = you
            self.friends = friends
            self.conversations = conversations
            self.rooms = rooms
        }, with: self.taskQueue)
        
        
        taskQueue.asyncAfter(deadline: DispatchTime.now() + 2) {
            var time : TimeInterval = 0
            //return
            for m in DataStore.shared.incomingMessages{
                
                self.taskQueue.asyncAfter(deadline: DispatchTime.now() + time) {
                    
                    m.time = MsgTime(sent: thePresentTime)
                    
                    let cvsID = m.conversationID
                    
                    if self.rooms[cvsID] != nil{
                        // New message
                        // Update conversation
                        let cvs = self.conversationWithID_unsafe(cvsID)
                        cvs?.lastMsg = m
                        cvs?.numberOfNewMsg += 1
                        
                        // Append message
                        self.rooms[cvsID]?.updateValue(m, forKey: m.id)
                        self.listenerCallbackForConversationChanged(cvs: cvs!, dataChanged: .changed)
                    }else{
                        // New conversation
                        let cvs = ChatConversation(cvsID: cvsID,
                                                   membersID: [self.you.id, m.senderId],
                                                   nameConversation: self.friendWithID_unsafe(m.senderId)!.name,
                                                   lastMsg: m)
                        cvs.numberOfNewMsg += 1
                        self.conversations.updateValue(cvs, forKey: cvsID)
                        self.rooms.updateValue(Dictionary<MsgID, Message>(dictionaryLiteral: (m.id, m)),
                                               forKey: m.conversationID)
                        self.listenerCallbackForConversationChanged(cvs: cvs, dataChanged: .new)
                    }
                }
                time += 4
            }
        }
    }
    
    public func fetchContacts(completion : @escaping (_ array : Array<User>) -> Void, callBackQueue : DispatchQueue? = nil){
        taskQueue.async {
            var queue = self.callBackQueue
            if callBackQueue != nil{
                queue = callBackQueue!
            }
            
            queue.async {
                completion(Array(self.friends.values))
            }
        }
    }
    
    public func fetchConversations(_ completion : @escaping ((_ array : Array<Conversation>) -> Void), callBackQueue : DispatchQueue? = nil){
        taskQueue.async {
            var queue = self.callBackQueue
            if callBackQueue != nil{
                queue = callBackQueue!
            }
            
            queue.async {
                completion(Array(self.conversations.values))
            }
        }
    }
    
    public func conversationWithID(_ id : ConversationID) -> Conversation?{
        var cvs : Conversation!
        taskQueue.sync {
            cvs = self.conversationWithID_unsafe(id)
        }
        return cvs
    }
    
    public func friendWithID(_ id : UserID) -> User?{
        var user : User!
        taskQueue.sync {
            user = self.friendWithID_unsafe(id)
        }
        return user
    }
    
    public func markMessageAsReadWithID(_ id : MsgID, conversationID : ConversationID){
        taskQueue.async {
            self.markMessageAsReadWithID(id, conversationID: conversationID)
        }
    }
    
    public func markConversationAsReadWithID(_ id : ConversationID, completion : (() -> Void)?){
        taskQueue.async {
            let cvs = self.conversations[id]
            if cvs == nil || cvs!.numberOfNewMsg == 0{
                if completion != nil{
                    completion!()
                }
                return
            }
            cvs?.numberOfNewMsg = 0
            for m in Array(self.rooms[id]!){
                if m.value.isUnread(){
                    _ = m.value.markAsRead()
                }
            }
            if completion != nil{
                completion!()
            }
        }
    }
    
    public func muteConversation(cvsID : ConversationID, time : TimeInterval, completion : (() -> Void)?){
        taskQueue.async {
            let conversation = self.conversationWithID_unsafe(cvsID)
            conversation?.muteTime = time
            
            if completion != nil{
                completion!()
            }
        }
    }
    
    public func unmuteConversation(cvsID : ConversationID, completion : (() -> Void)?){
        taskQueue.async {
            let conversation = self.conversationWithID_unsafe(cvsID)
            conversation?.muteTime = MsgTime.TimeInvalidate
            
            if completion != nil{
                completion!()
            }
        }
    }
    
    public func deleteConversationWithID(_ id : ConversationID, completion : (() -> Void)?){
        taskQueue.async {
            self.deleteMessageWithID(id)
            
            if completion != nil{
                completion!()
            }
        }
    }
    
    
    public func deleteMessageWithID(_ id : MsgID){
        taskQueue.async {
            
        }
    }
    
    public func removeFriendWithID(_ id : UserID){
        taskQueue.async {
            
        }
    }
}

extension DataManager{
    private func friendWithID_unsafe(_ id : UserID) -> User?{
        return self.friends[id]
    }
    
    private func conversationWithID_unsafe(_ id : ConversationID) -> Conversation?{
        return conversations[id]
    }
    
    private func messageWithID_unsafe(_ id : MsgID, conversationID : ConversationID) -> Message?{
        return self.rooms[conversationID]?[id]
    }
    
    
    private func markMessageAsReadWithID_unsafe(_ id : MsgID, conversationID : ConversationID){
        let msg = self.messageWithID_unsafe(id, conversationID: conversationID)
        _ = msg?.markAsRead()
    }
    
    private func deleteConversationWithID_unsafe(_ id : ConversationID){
        conversations.removeValue(forKey: id)
        rooms[id]?.removeAll()
        rooms.removeValue(forKey: id)
    }
    
}

enum DataChangedType {
    case new
    case changed
    case delete
}

enum ListenForEvent{
    case message
    case conversation
    case user
    
    public func toInt() -> Int{
        switch self {
        case .message:
            return 0
        case .conversation:
            return 1
        case .user:
            return 2
        }
    }
}

// MARK: Listener
extension DataManager{
    class ObserverItem : NSObject{
        var target : DataManagerListenerDelegate
        var queue : DispatchQueue
        
        init(target : DataManagerListenerDelegate, queue : DispatchQueue) {
            self.target = target
            self.queue = queue
        }
    }
    
    public func addObserver(for event : ListenForEvent, target : DataManagerListenerDelegate, callBackQueue : DispatchQueue? = nil){
        taskQueue.async {
            var queue = self.callBackQueue
            if callBackQueue != nil{
                queue = callBackQueue!
            }
            let ob = ObserverItem(target: target, queue: queue)
            if self.listenItems[event.toInt()] != nil{
                self.listenItems[event.toInt()]?.append(ob)
            }else{
                self.listenItems.updateValue([ob], forKey: event.toInt())
            }
        }
    }
    
    public func removeObserver(for event : ListenForEvent, target : DataManagerListenerDelegate){
        taskQueue.async {
            self.listenItems.removeValue(forKey: event.toInt())
        }
    }
    
    
    private func listenerCallbackForMessageChanged(msg : Message, dataChanged : DataChangedType){
        taskQueue.async {
            for i in Array(self.listenItems[ListenForEvent.message.toInt()]!){
                i.queue.async {
                    i.target.messageChanged(msg, dataChanged: dataChanged)
                }
            }
        }
    }
    
    private func listenerCallbackForUserChanged(user : User, dataChanged : DataChangedType){
        taskQueue.async {
            for i in Array(self.listenItems[ListenForEvent.user.toInt()]!){
                i.queue.async {
                    i.target.userChanged(user, dataChanged: dataChanged)
                }
            }
        }
    }
    
    private func listenerCallbackForConversationChanged(cvs : Conversation, dataChanged : DataChangedType){
        taskQueue.async {
            for i in Array(self.listenItems[ListenForEvent.conversation.toInt()]!){
                i.queue.async {
                    i.target.conversationChanged(cvs, dataChanged: dataChanged)
                }
            }
        }
    }
    
}

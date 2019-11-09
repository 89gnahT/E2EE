//
//  ChatManager.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

@objc protocol DataManagerListenerDelegate : NSObjectProtocol{
    @objc optional func receivedNewMessage(_ msg : Message)
    
    @objc optional func messageChanged(msgID : MsgID)
    
    @objc optional func createNewConversation(_ cvs : Conversation)
    
    @objc optional func conversationChanged(cvsID : ConversationID)
}

class DataManager: NSObject {
    static let shared = DataManager()
    
    private var taskQueue = DispatchQueue(label: "data manager task queue")
    
    private var callBackQueue = DispatchQueue(label: "data manager callback", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    private var listenItems = Array<ListenItem>()
    
    private var conversations = Array<Conversation>()
    
    private var friends = Array<User>()
    
    private var rooms = Dictionary<ConversationID, Array<Message>>()
    
    private override init() {
        super.init()
        rooms = DataStore.shared.rooms
        taskQueue.async {
            var time : TimeInterval = 2
            return
            for m in DataStore.shared.incomingMessages{
                
                m.time = MsgTime(sent: Date.timeIntervalSinceReferenceDate)
                
                self.taskQueue.asyncAfter(deadline: DispatchTime.now() + time) {
                    let cvsID = m.conversationID

                    if self.rooms[cvsID] != nil{
                        // New message
                        // Update conversation
                        let cvs = self.conversationWithID_unsafe(cvsID)
                        cvs?.lastMsg = m

                        // Append message
                        self.rooms[cvsID]?.append(m)

                        self.listenerCallbackForConversationChanged(cvsID: cvsID)
                    }else{
                        // New conversation
                        let cvs = ChatConversation(cvsID: cvsID, membersID: [self.you.id, m.senderId], nameConversation: self.friendWithID_unsafe(m.senderId)!.name, lastMsg: m)
                        self.conversations.append(cvs)
                        self.rooms.updateValue([m], forKey: cvsID)

                        self.listenerCallbackForNewConversation(conversation: cvs)
                    }
                }
                time += 0.1
            }
        }
    }
    
    public var you : User{
        return DataStore.shared.you
    }
    
    public func fetchContacts(completion : @escaping (_ array : Array<User>) -> Void, callBackQueue : DispatchQueue? = nil){
        taskQueue.async {
            var queue = self.callBackQueue
            if callBackQueue != nil{
                queue = callBackQueue!
            }
            
            let users = DataStore.shared.users
            queue.async {
                completion(users)
            }
            
            if self.friends.count != users.count{
                self.friends = users
            }
        }
    }
    
    public func fetchConversations(_ completion : @escaping ((_ array : Array<Conversation>) -> Void), callBackQueue : DispatchQueue? = nil){
        taskQueue.async {
            var queue = self.callBackQueue
            if callBackQueue != nil{
                queue = callBackQueue!
            }
            let conversations = DataStore.shared.conversations
            queue.async {
                completion(conversations)
            }
            
            if self.conversations.count != conversations.count{
                self.conversations = conversations
            }
        }
    }
}


extension DataManager{
    private func friendWithID_unsafe(_ id : UserID) -> User?{
        return self.friends.first { (u) -> Bool in
            return u.id == id
            }
    }
    
    public func friendWithID(_ id : UserID) -> User?{
        var user : User!
        taskQueue.sync {
            user = self.friendWithID_unsafe(id)
        }
        return user
    }
    
    private func conversationWithID_unsafe(_ id : ConversationID) -> Conversation?{
        return conversations.first { (c) -> Bool in
            return c.id == id
        }
    }
    
    public func conversationWithID(_ id : ConversationID) -> Conversation?{
        var cvs : Conversation!
        taskQueue.sync {
            cvs = self.conversationWithID_unsafe(id)
        }
        return cvs
    }
    
    private func messageWithID_unsafe(_ id : MsgID) -> Message?{
        return DataStore.shared.messages.first { (m) -> Bool in
            return m.id == id
        }
    }
    
    private func markMessageAsRead_unsafe(msg : Message){
        msg.time.seen = Date.timeIntervalSinceReferenceDate
    }
    
    public func markMessageAsReadWithID(_ id : MsgID){
        taskQueue.async {
            let msg = self.messageWithID_unsafe(id)
            if msg != nil{
                self.markMessageAsRead_unsafe(msg: msg!)
            }
        }
    }
    
    public func markConversationAsReadWithID(_ id : ConversationID){
        taskQueue.async {
            for m in self.rooms[id]!{
                self.markMessageAsRead_unsafe(msg: m)
            }
        }
    }
    
    public func muteConversation(cvsID : ConversationID, time : TimeInterval, completion : @escaping () -> Void?){
        taskQueue.async {
            let conversation = self.conversationWithID_unsafe(cvsID)
            conversation?.muteTime = time
            completion()
        }
    }
    
    public func unmuteConversation(cvsID : ConversationID, completion : @escaping () -> Void?){
        taskQueue.async {
            let conversation = self.conversationWithID_unsafe(cvsID)
            conversation?.muteTime = MsgTime.TimeInvalidate
            completion()
        }
    }
    
    public func deleteConversationWithID(_ id : ConversationID){
        taskQueue.async {
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


// MARK: Listener
extension DataManager{
    struct ListenItem {
        var target : DataManagerListenerDelegate
        var queue : DispatchQueue
        
        init(target : DataManagerListenerDelegate, queue : DispatchQueue) {
            self.target = target
            self.queue = queue
        }
    }
    
    public func addObserver(target : DataManagerListenerDelegate, callBackQueue : DispatchQueue? = nil){
        taskQueue.async {
            if self.listenItems.firstIndex(where: { (item) -> Bool in
                return item.target === target
            }) == nil{
                var queue = self.callBackQueue
                if callBackQueue != nil{
                    queue = callBackQueue!
                }
                self.listenItems.append(ListenItem(target: target, queue: queue))
            }
        }
    }
    
    public func removeObserver(target : DataManagerListenerDelegate){
        taskQueue.async {
            let index = self.listenItems.firstIndex { (i) -> Bool in
                return i.target === target
            }
            if index != nil{
                self.listenItems.remove(at: index!)
            }
        }
    }
    
    private func listenerCallbackForNewMessage(message : Message){
        taskQueue.async {
            for i in self.listenItems{
                i.queue.async {
                    
                }
            }
        }
    }
    
    private func listenerCallbackForMessageChanged(msgID : MsgID){
        taskQueue.async {
            for i in self.listenItems{
                i.queue.async {
                    
                }
            }
        }
    }
    
    private func listenerCallbackForNewConversation(conversation : Conversation){
        taskQueue.async {
            for i in self.listenItems{
                i.queue.async {
                    i.target.createNewConversation?(conversation)
                }
            }
        }
    }
    
    private func listenerCallbackForConversationChanged(cvsID : ConversationID){
        taskQueue.async {
            for i in self.listenItems{
                i.queue.async {
                    i.target.conversationChanged?(cvsID: cvsID)
                }
            }
        }
    }
}

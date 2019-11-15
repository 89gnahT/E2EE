//
//  ChatManager.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit


enum DataChangedType {
    case new
    case changed
    case delete
}

enum ListenForEvent{
    case message
    case conversation
    case user
}

protocol DataManagerListenerDelegate : NSObjectProtocol{
    func messageChanged(_ msg : MessageModel, dataChanged : DataChangedType)
    
    func conversationChanged(_ cvs : ConversationModel, dataChanged : DataChangedType)
    
    func userChanged(_ user : UserModel, dataChanged : DataChangedType)
}

class CDataManager: NSObject {
    static let shared = CDataManager()
    
    private var taskQueue = DispatchQueue(label: "client: data manager task queue")
    
    private var callBackQueue = DispatchQueue(label: "client: data manager callback",
                                              qos: .default,
                                              attributes: .concurrent,
                                              autoreleaseFrequency: .inherit,
                                              target: nil)
    
    private var listenItems = Dictionary<ListenForEvent, Array<ObserverItem>>()
    
    private var conversations = Dictionary<ConversationID, ConversationModel>()
    
    private var friends = Dictionary<UserID, UserID>()
    
    private var people = Dictionary<UserID, UserModel>()
    
    private var rooms = Dictionary<ConversationID, Dictionary<MessageID, MessageModel>>()
    
    public var you : UserModel!
    
    private override init() {
        super.init()
        
    }
    
    public func batchFetchingAllData(_ completion : @escaping () -> Void){
        self.taskQueue.async { [weak self] in
            SDataManager.shared.batchFetchingAllData({ (you, friends, people, conversations, rooms) in
                // Process data
                self?.you = UserModel(id: you.id, name: you.name, avatarURL: you.avatarURL, gender: you.gender)
                
                for p in people.values{
                    let u = UserModel(id:p.id, name: p.name, avatarURL: p.avatarURL, gender: p.gender)
                    self?.people.updateValue(u, forKey: u.id)
                }
                
                for f in friends{
                    self?.friends.updateValue(f, forKey: f)
                }
                
                for r in rooms{
                    self?.rooms.updateValue(Dictionary<MessageID, MessageModel>(), forKey: r.key)
                    
                    // Process message
                    for m in r.value.values{
                        let msg = MessageModel(id: m.id,
                                               conversationID: m.conversationID,
                                               sender: self?.people[m.senderId] ?? UserModel(),
                                               type: m.msgType,
                                               contents: m.contents,
                                               time: MessageTime(sent: m.sent, deliveried: m.deliveried, seen: m.seen))
                        self?.rooms[r.key]?.updateValue(msg, forKey: msg.id)
                    }
                    
                    // Prpcess Conversation
                    let c = conversations[r.key]
                    if c == nil{
                        break
                    }
                    
                    // Sort message by timeSent
                    let messages = self?.rooms[r.key]?.values.sorted(by: { (a, b) -> Bool in
                        return a.time.sent < b.time.sent
                    })
                    
                    // Create last messages
                    var lastMsg : [MessageModel] = []
                    for m in messages!{
                        if !m.isRead(){
                            lastMsg.append(m)
                        }
                    }
                    if lastMsg.count == 0 && messages!.count > 0{
                        lastMsg.append((messages?.last)!)
                    }
                    
                    // Create member
                    var member = Dictionary<UserID, UserModel>()
                    for i in c!.membersID{
                        member.updateValue(((self?.people[i])!), forKey: i)
                    }
                    
                    let conversation = ChatConversationModel(cvsID: c!.id,
                                                             members: member,
                                                             nameConversation: c!.nameConversation,
                                                             lastMsgs: lastMsg,
                                                             muteTime: c!.muteTime)
                    self?.conversations.updateValue(conversation, forKey: conversation.id)
                }
                
                self?.callBackQueue.async {
                    completion()
                }
            }, callbackQueue: self?.taskQueue)
        }
    }
    
    public func fetchContacts(completion : @escaping (_ array : Array<UserModel>) -> Void, callBackQueue : DispatchQueue? = nil){
        taskQueue.async {[weak self] in
            var contacts = [UserModel]()
            for f in self!.friends{
                let u = self!.people[f.key]
                
                if u != nil{
                    contacts.append(u!)
                }
            }
            
            let queue = callBackQueue != nil ? callBackQueue : self!.callBackQueue
            queue?.async{
                completion(contacts)
            }
        }
    }
    
    public func fetchConversations(_ completion : @escaping ((_ array : [ConversationModel]) -> Void), callBackQueue : DispatchQueue? = nil){
        taskQueue.async { [weak self] in
            let conversations = self!.conversations.values.sorted { (a, b) -> Bool in
                return a.lastMsgs.last!.time.sent > b.lastMsgs.last!.time.sent
            }
            
            let queue = callBackQueue != nil ? callBackQueue : self!.callBackQueue
            queue?.async {
                completion(conversations)
            }
        }
    }
    
    public func fetchMessageInConversation(withID id : ConversationID, completion : @escaping ((_ array : [MessageModel]) -> Void), callBackQueue : DispatchQueue? = nil){
        taskQueue.async { [weak self] in
            let queue = callBackQueue != nil ? callBackQueue : self!.callBackQueue
            queue?.async {
                completion(Array(self!.rooms[id]!.values))
            }
        }
    }
}

extension CDataManager{
    public func markAsRead(conversationID id : ConversationID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            
            guard let conversation = self.conversations[id] else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            for m in conversation.lastMsgs{
                SDataManager.shared.markAsRead(messageID: m.id, conversationID: m.conversationID, completion: completion)
            }
        }
    }
    
    public func deleteConversationWithID(_ id : ConversationID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            
            guard self.conversations[id] != nil else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            SDataManager.shared.deleteConversationWithID(id, completion: completion)
        }
    }
    
    public func muteConversationWithID(_ id : ConversationID, until time : TimeInterval, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            
            guard self.conversations[id] != nil else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            SDataManager.shared.muteConversationWithID(id, until: time, completion: completion)
        }
    }
    
    public func unmuteConversationWithID(_ id : ConversationID, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            guard self.conversations[id] != nil else{
                self.callback(WithError: .notFound, completion: completion)
                return
            }
            
            SDataManager.shared.unmuteConversationWithID(id, completion: completion)
        }
    }
}

extension CDataManager{
    private func u_markAsRead(conversation : ConversationModel){
        for m in conversation.lastMsgs{
            u_markAsRead(messageID: m.id, conversationID: m.conversationID)
        }
        
        if conversation.lastMsgs.count > 1{
            let last = conversation.lastMsgs.last!
            conversation.lastMsgs.removeAll()
            conversation.lastMsgs.append(last)
        }
    }
    
    private func u_markAsRead(messageID id : MessageID, conversationID cvsID : ConversationID){
        guard let msg = self.rooms[cvsID]![id] else {
            return
        }
        if !msg.isRead(){
            msg.time.seen = thePresentTime
        }
    }
    
    private func u_deleteConversation(conversation : ConversationModel){
        conversations.removeValue(forKey: conversation.id)
        rooms[conversation.id]?.removeAll()
        rooms.removeValue(forKey: conversation.id)
    }
    
    private func u_muteConversation(conversation : ConversationModel, until time : TimeInterval){
        conversation.muteTime = time
    }
    
    private func u_unmuteConversation(conversation : ConversationModel){
        conversation.muteTime = 0
    }
    
    private func u_deleteConversationWithID(_ id : ConversationID) -> ConversationModel{
        rooms[id]!.removeAll()
        rooms.removeValue(forKey: id)
        
        return conversations.removeValue(forKey: id)!
    }
}

// MARK: - Delegate
extension CDataManager : SDataManagerListenerDelegate{
    func messageChanged(_ msg: MessageEntity, dataChanged: DataChangedType) {
        print(msg)
    }
    
    func conversationChanged(_ cvs: ConversationEntity, dataChanged: DataChangedType) {
        taskQueue.async {
            switch dataChanged {
            case .new:
                print("create new cvs")
            case .changed:
                print("changed cvs")
            case .delete:
                let c = self.u_deleteConversationWithID(cvs.id)
                self.callbackForDataChanged(object: c, forEvent: .conversation, dataChanged: .delete)
                
            }
        }
    }
    
    func userChanged(_ user: UserEntity, dataChanged: DataChangedType) {
        
    }
    
    
}

// MARK: Observer
extension CDataManager{
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
            if self.listenItems[event] != nil{
                self.listenItems[event]?.append(ob)
            }else{
                self.listenItems.updateValue([ob], forKey: event)
            }
        }
    }
    
    public func removeObserver(for event : ListenForEvent, target : DataManagerListenerDelegate){
        taskQueue.async {
            self.listenItems[event]!.removeAll { (a) -> Bool in
                return a.target.isEqual(target)
            }
        }
    }
    
    private func callbackForDataChanged(object : NSObject, forEvent event : ListenForEvent, dataChanged : DataChangedType){
        taskQueue.async {
            for i in Array(self.listenItems[event]!){
                i.queue.async {
                    switch event{
                        
                    case .conversation:
                        i.target.conversationChanged(object as! ConversationModel, dataChanged: dataChanged)
                        
                    case .message:
                        i.target.messageChanged(object as! MessageModel, dataChanged: dataChanged)
                        
                    case .user:
                        i.target.userChanged(object as! UserModel, dataChanged: dataChanged)
                    }
                }
            }
        }
    }
    
}

extension CDataManager{
    private func callback(WithError error : DataError, completion : ((_ error : DataError) -> Void)?){
        if completion != nil{
            self.callBackQueue.async {
                completion!(error)
            }
        }
    }
}

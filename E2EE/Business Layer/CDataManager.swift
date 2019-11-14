//
//  ChatManager.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/8/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

protocol DataManagerListenerDelegate{
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
    
    private var listenItems = Dictionary<Int, Array<ObserverItem>>()
    
    private var conversations = Dictionary<ConversationID, ConversationModel>()
    
    private var friends = Dictionary<UserID, UserID>()
    
    private var people = Dictionary<UserID, UserModel>()
    
    private var rooms = Dictionary<ConversationID, Dictionary<MsgID, MessageModel>>()
    
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
                    self?.rooms.updateValue(Dictionary<MsgID, MessageModel>(), forKey: r.key)
                    
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
    
    public func fetchConversations(_ completion : @escaping ((_ array : Array<ConversationModel>) -> Void), callBackQueue : DispatchQueue? = nil){
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
    
    
    private func listenerCallbackForMessageChanged(msg : MessageModel, dataChanged : DataChangedType){
        taskQueue.async {
            for i in Array(self.listenItems[ListenForEvent.message.toInt()]!){
                i.queue.async {
                    i.target.messageChanged(msg, dataChanged: dataChanged)
                }
            }
        }
    }
    
    private func listenerCallbackForUserChanged(user : UserModel, dataChanged : DataChangedType){
        taskQueue.async {
            for i in Array(self.listenItems[ListenForEvent.user.toInt()]!){
                i.queue.async {
                    i.target.userChanged(user, dataChanged: dataChanged)
                }
            }
        }
    }
    
    private func listenerCallbackForConversationChanged(cvs : ConversationModel, dataChanged : DataChangedType){
        taskQueue.async {
            for i in Array(self.listenItems[ListenForEvent.conversation.toInt()]!){
                i.queue.async {
                    i.target.conversationChanged(cvs, dataChanged: dataChanged)
                }
            }
        }
    }
    
}


//        taskQueue.asyncAfter(deadline: DispatchTime.now() + 2) {
//            var time : TimeInterval = 0
//            //return
//            for m in DataStore.shared.incomingMessages{
//
//                self.taskQueue.asyncAfter(deadline: DispatchTime.now() + time) {
//
//                    m.time = MsgTime(sent: thePresentTime)
//
//                    let cvsID = m.conversationID
//
//                    if self.rooms[cvsID] != nil{
//                        // New message
//                        // Update conversation
//                        let cvs = self.conversationWithID_unsafe(cvsID)
//                        cvs?.lastMsg = m
//                        cvs?.numberOfNewMsg += 1
//
//                        // Append message
//                        self.rooms[cvsID]?.updateValue(m, forKey: m.id)
//                        self.listenerCallbackForConversationChanged(cvs: cvs!, dataChanged: .changed)
//                    }else{
//                        // New conversation
//                        let cvs = ChatConversation(cvsID: cvsID,
//                                                   membersID: [self.you.id, m.senderId],
//                                                   nameConversation: self.friendWithID_unsafe(m.senderId)!.name,
//                                                   lastMsg: m)
//                        cvs.numberOfNewMsg += 1
//                        self.conversations.updateValue(cvs, forKey: cvsID)
//                        self.rooms.updateValue(Dictionary<MsgID, Message>(dictionaryLiteral: (m.id, m)),
//                                               forKey: m.conversationID)
//                        self.listenerCallbackForConversationChanged(cvs: cvs, dataChanged: .new)
//                    }
//                }
//                time += 4
//            }
        //        }

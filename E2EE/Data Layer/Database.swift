//
//  Database.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/13/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

class Database: NSObject {
    static let shared = Database()
    
    private var taskQueue = DispatchQueue(label: "data layer: data manager task queue")
    
    private var callBackQueue = DispatchQueue(label: "data layer: data manager callback server",
                                              qos: .default,
                                              attributes: .concurrent,
                                              autoreleaseFrequency: .inherit,
                                              target: nil)
    
    fileprivate var you  = UserEntity()
    fileprivate var people = Dictionary<UserID, UserEntity>()
    fileprivate var friends = Dictionary<UserID, UserID>()
    fileprivate var conversations = Dictionary<InboxID, InboxEntity>()
    fileprivate var rooms = Dictionary<InboxID, Dictionary<MessageID, MessageEntity>>()
    
    private override init() {
        
    }
    
    public func batchFetchingAllData(with completion: @escaping (_ you : UserEntity,
        _ friends : Dictionary<UserID, UserID>,
        _ people : Dictionary<UserID, UserEntity>,
        _ conversations : Dictionary<InboxID, (InboxEntity, MessageEntity)>) -> Void, callbackQueue : DispatchQueue?){
        taskQueue.async {
            self.fetchPeople()
            self.fetchOwnerData()
            self.fetchConversations()
            self.fetchRoomsChat()
            
            var conversationWithLastMessage = Dictionary<InboxID, (InboxEntity, MessageEntity)>()
            for i in self.conversations{
                let lastMessage = self.rooms[i.key]!.values.max { (a, b) -> Bool in
                    return a.sent > b.sent
                }
                conversationWithLastMessage.updateValue((i.value, lastMessage!), forKey: i.key)
            }
            
            let queue = callbackQueue != nil ? callbackQueue : self.callBackQueue
            queue?.async {
                completion(self.you, self.friends, self.people, conversationWithLastMessage)
            }
        }
    }
    
    public func fetchMesaages(with inboxID : InboxID, _ completion: @escaping (([MessageEntity]) -> Void), callbackQueue : DispatchQueue?){
        taskQueue.async {
            let messages = self.rooms[inboxID]!.values.sorted { (a, b) -> Bool in
                return a.sent < b.sent
            }
            let queue = callbackQueue != nil ? callbackQueue : self.callBackQueue
            queue?.async {
                completion(messages)
            }
        }
    }
}

extension Database{
    private func fetchOwnerData(){
        self.you = UserEntity(id: self.randomUserID(),
                              name: "Anh Trường",
                              avatarURL: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrg_fNLiyMUKhe8KVqfUTxgHy5e8WhaUky3RQxqGaa5X8WK905&s",
                              gender: .male)
        for i in self.people.keys{
            if self.random() % 2 == 0{
                self.friends.updateValue(i, forKey: i)
            }
        }
        self.people.updateValue(self.you, forKey: self.you.id)
    }
    
    private func fetchPeople(){
        let imageURLs = self.imageURLMessage
        for name in self.userName{
            let u = UserEntity(id: self.randomUserID(),
                               name: name,
                               avatarURL: imageURLs[Int.random(in: 0..<imageURLs.count)],
                               gender: self.randomGender())
            self.people.updateValue(u, forKey: u.id)
        }
    }
    
    private func fetchConversations(){
        for i in self.people.values{
            if i.id != self.you.id {
                let c = self.createConversationFrom(i.id)
                self.conversations.updateValue(c, forKey: c.id)
            }
        }
    }
    
    private func fetchRoomsChat(){
        for c in self.conversations.values{
            self.rooms.updateValue(Dictionary<MessageID, MessageEntity>(), forKey: c.id)
            let numberOfMessage = self.randomInt(50, 200)
            
            for _ in 0..<numberOfMessage{
                let m = self.createMsgFrom(c)
                self.rooms[c.id]?.updateValue(m, forKey: m.id)
            }
        }
    }
    
}

extension Database{
    private func randomImageURL(_ number : Int) -> [String]{
        var contents = [String]()
        for _ in 0..<number{
            contents.append(self.imageURLMessage[self.randomInt(self.imageURLMessage.count)])
        }
        return contents
    }
    
    private func createMsgFrom(_ cvs : InboxEntity) -> MessageEntity{
        
        let senderID = self.random() % 2 == 0 ? cvs.membersID.first! : cvs.membersID.last!
        let msgID = senderID + String(timeNow)
        let (contents, type) = self.random() % 30 == 0 ?
            (self.randomImageURL(self.randomInt(10) + 1), MessageType.image) :
            ([self.textMsg[self.randomInt(self.textMsg.count)]], MessageType.text)
        let (sent, delivered, seen) = self.randomMsgTime()
        
        return MessageEntity(id: msgID,
                             conversationID: cvs.id,
                             senderId: senderID,
                             type: type,
                             contents: contents,
                             timeSent: sent,
                             timeDeliveried: delivered,
                             timeSeen: seen)
    }
    
    private func createConversationFrom(_ userID : UserID) -> InboxEntity{
        let cvsID = self.you.id < userID ? self.you.id + userID : userID + self.you.id
        return InboxEntity(cvsID: cvsID,
                                  type: .chat,
                                  membersID: [self.you.id, userID],
                                  nameConversation: self.people[userID]!.name,
                                  muteTime: self.randomMuteTime())
    }
}

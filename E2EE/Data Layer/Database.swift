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
    
    public func fetchMesaages(with inboxID : InboxID, currentNumberMessages number: Int, howManyMessageReceive receive: Int, _ completion: @escaping (([MessageEntity]) -> Void), callbackQueue : DispatchQueue?){
        taskQueue.async {
            let messages = self.rooms[inboxID]!.values.sorted { (a, b) -> Bool in
                return a.sent < b.sent
            }
            
            var messageReceive = [MessageEntity]()
            if messages.count > number{
                var minCount = number + receive
                minCount = minCount > messages.count ? messages.count : minCount
                for i in number..<minCount{
                    messageReceive.append(messages[i])
                    print("choose message ", i, " witdh id ", messages[i].id, " with content: ", messages[i].contents[0])
                }
            }
            
            let queue = callbackQueue != nil ? callbackQueue : self.callBackQueue
            queue?.async {
                completion(messageReceive)
            }
        }
    }
}

extension Database{
    public func deleteMessage(withInboxID iID : InboxID, messageID: MessageID, completion :  ((_ error : DataError, _ messageEntity: MessageEntity?) -> Void)?, callbackQueue : DispatchQueue?){
        taskQueue.async {
            let messageRemoved = self.rooms[iID]?.removeValue(forKey: messageID)
            let error: DataError = messageRemoved != nil ? .none : .notFound
            
            let queue = callbackQueue != nil ? callbackQueue : self.callBackQueue
            queue?.async {
                completion?(error, messageRemoved)
            }
        }
    }
    
    public func receiveMessage(_ message: MessageEntity, completion :  ((_ error : DataError) -> Void)?){
        taskQueue.async {
            if self.rooms[message.inboxID] == nil{
                self.rooms.updateValue(Dictionary<MessageID, MessageEntity>(), forKey: message.inboxID)
            }
            self.rooms[message.inboxID]?.updateValue(message, forKey: message.id)
            
            self.callBackQueue.async {
                completion?(.none)
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
            if i.id != self.you.id && self.randomInt(100) % 7 == 0{
                let c = self.createConversationFrom(i.id)
                self.conversations.updateValue(c, forKey: c.id)
            }
        }
    }
    
    private func fetchRoomsChat(){
        for c in self.conversations.values{
            self.rooms.updateValue(Dictionary<MessageID, MessageEntity>(), forKey: c.id)
            let numberOfMessage = self.randomInt(500, 2000)
            
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
        let msgID = self.randomMsgID(with: senderID)
//        print("create message id ", msgID)
        let (contents, type) = self.random() % 25 == 0 ?
            (self.randomImageURL(self.randomInt(1, 10)), MessageType.image) :
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

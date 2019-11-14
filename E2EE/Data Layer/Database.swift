//
//  Database.swift
//  E2EE
//
//  Created by Truong Nguyen on 11/13/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import UIKit

enum ZAEror : Error {
    case dataEmpty
    case none
}

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
    fileprivate var conversations = Dictionary<ConversationID, ConversationEntity>()
    fileprivate var rooms = Dictionary<ConversationID, Dictionary<MsgID, MessageEntity>>()
    
    private override init() {
        
    }
    
    public func batchFetchingAllData(with completion: @escaping (_ you : UserEntity,
        _ friends : Dictionary<UserID, UserID>,
        _ people : Dictionary<UserID, UserEntity>,
        _ conversations : Dictionary<ConversationID, ConversationEntity>,
        _ rooms : Dictionary<ConversationID, Dictionary<MsgID, MessageEntity>>) -> Void, callbackQueue : DispatchQueue?){
        taskQueue.async {
            self.fetchPeople()
            self.fetchOwnerData()
            self.fetchConversations()
            self.fetchRoomsChat()
            
            let queue = callbackQueue != nil ? callbackQueue : self.callBackQueue
            queue?.async {
                completion(self.you, self.friends, self.people, self.conversations, self.rooms)
                
                self.people.removeAll()
                self.friends.removeAll()
                for i in self.conversations.keys{
                    self.rooms[i]?.removeAll()
                }
                self.rooms.removeAll()
                self.conversations.removeAll()
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
        self.people.updateValue(self.you, forKey: self.you.id)
        for i in self.people.keys{
            if self.random() % 2 == 0{
                self.friends.updateValue(i, forKey: i)
            }
        }
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
            if i.id != self.you.id && self.random() % 2 == 0{
                let c = self.createConversationFrom(i.id)
                self.conversations.updateValue(c, forKey: c.id)
            }
        }
    }
    
    private func fetchRoomsChat(){
        for c in self.conversations.values{
            self.rooms.updateValue(Dictionary<MsgID, MessageEntity>(), forKey: c.id)
            let numberOfMessage = self.randomInt(10) + 1
            
            for _ in 0..<numberOfMessage{
                let m = self.createMsgFrom(c)
                self.rooms[c.id]?.updateValue(m, forKey: m.id)
            }
        }
    }
    
}

extension Database{
    private func createMsgFrom(_ cvs : ConversationEntity) -> MessageEntity{
        let senderID = self.random() % 2 == 0 ? cvs.membersID.first! : cvs.membersID.last!
        let msgID = senderID + String(thePresentTime)
        let (contents, type) = self.random() % 2 == 0 ?
            ([self.imageURLMessage[self.randomInt(self.imageURLMessage.count)]], MessageType.image) :
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
    
    private func createConversationFrom(_ userID : UserID) -> ConversationEntity{
        let cvsID = self.you.id < userID ? self.you.id + userID : userID + self.you.id
        return ConversationEntity(cvsID: cvsID,
                                  type: .chat,
                                  membersID: [self.you.id, userID],
                                  nameConversation: self.people[userID]!.name,
                                  muteTime: self.randomMuteTime())
    }
}

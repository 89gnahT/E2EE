//
//  GroupComunicationTest.swift
//  E2EETests
//
//  Created by CPU11899 on 11/26/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import XCTest
@testable import E2EE

class GroupComunicationTest: XCTestCase {
    var aliceAddress: SignalAddress?
    var aliceKeyStore: SignalKeyStore?
    var alicePreKeyBundle: SessionPreKeyBundle?
    var aliceGroupCipher: GroupCipher<SignalGroupKeyStore>?
    var aliceGroupKeyStore: SignalGroupKeyStore?
    
    var bobAddress: SignalAddress?
    var bobKeyStore: SignalKeyStore?
    var bobPreKeyBundle: SessionPreKeyBundle?
    var bobGroupCipher: GroupCipher<SignalGroupKeyStore>?
    var bobGroupKeyStore: SignalGroupKeyStore?
    
    var carlAddress: SignalAddress?
    var carlKeyStore: SignalKeyStore?
    var carlPreKeyBundle: SessionPreKeyBundle?
    var carlGroupCipher: GroupCipher<SignalGroupKeyStore>?
    var carlGroupKeyStore: SignalGroupKeyStore?
    
    let crypto: CommonSignalCrypto = CommonSignalCrypto()
    
    var groupSender: SignalSenderKeyName?
    var cipherMessage: CipherTextMessage?
    var distributionMessage: Data?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func aliceSignUp() {
        self.aliceAddress = SignalAddress(identifier: "022116648661", deviceId: 1)
        do {
            let identityKey = try crypto.generateIdentityKeyPair()
            self.aliceKeyStore = SignalKeyStore(withKeyPair: identityKey)
            self.aliceGroupKeyStore = SignalGroupKeyStore(withKeyPair: identityKey)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch {
            XCTFail("Other Error")
        }
        
        do {
            let publicKey = try self.aliceKeyStore?.identityKeyStore.getPublicIdentityKey()
            let preKeys = try self.aliceKeyStore?.createPreKeys(count: 10)
            let signedPreKey = try self.aliceKeyStore?.updateSignedPrekey()
            self.alicePreKeyBundle = try SessionPreKeyBundle(preKey: preKeys!.first!, signedPreKey: signedPreKey!, identityKey: publicKey!)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch {
            XCTFail("Other error")
        }
    }

    func bobSignUp()  {
        self.bobAddress = SignalAddress(identifier: "0561351813", deviceId: 1)
        do {
            let identityKey = try crypto.generateIdentityKeyPair()
            self.bobKeyStore = SignalKeyStore(withKeyPair: identityKey)
            self.bobGroupKeyStore = SignalGroupKeyStore(withKeyPair: identityKey)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch {
            XCTFail("Other error")
        }
        
        do {
            let publicKey = try self.aliceKeyStore?.identityKeyStore.getPublicIdentityKey()
            let preKeys = try self.bobKeyStore?.createPreKeys(count: 10)
            let signedPreKey = try self.bobKeyStore?.updateSignedPrekey()
            self.bobPreKeyBundle = try SessionPreKeyBundle(preKey: preKeys!.first!, signedPreKey: signedPreKey!, identityKey: publicKey!)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch {
            XCTFail("Other error")
        }
    }

    func carlSignUp() {
        self.carlAddress = SignalAddress(identifier: "02213456", deviceId: 1)
        do {
            let identityKey = try crypto.generateIdentityKeyPair()
            self.carlKeyStore = SignalKeyStore(withKeyPair: identityKey)
            self.carlGroupKeyStore = SignalGroupKeyStore(withKeyPair: identityKey)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch {
            XCTFail("Other error")
        }
        do {
            let publicKey = try self.carlKeyStore?.identityKeyStore.getPublicIdentityKey()
            let preKeys = try self.carlKeyStore?.createPreKeys(count: 10)
            let signedPreKey = try self.carlKeyStore?.updateSignedPrekey()
            self.carlPreKeyBundle = try SessionPreKeyBundle(preKey: preKeys!.first!, signedPreKey: signedPreKey!, identityKey: publicKey!)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch {
            XCTFail("Other error")
        }
    }
    
    func aliceCreateGroupChat() {
        self.groupSender = SignalSenderKeyName(groupid: "Group truyen cuoi", sender: self.aliceAddress!)
        self.aliceGroupCipher = GroupCipher(address: groupSender!, store: aliceGroupKeyStore!)
    }
    
    func aliceProcessDistributionMessage() {
        do {
            let distributionMessage = try SenderKeyDistributionMessage(from: self.distributionMessage!)
            try aliceGroupCipher?.process(distributionMessage: distributionMessage)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch let error {
            print("Fail to process distribution message")
            XCTFail(error.localizedDescription)
        }
    }
    
    func bobCreateGroupCipherAndSendMessage() {
        self.bobGroupCipher = GroupCipher(address: groupSender!, store: aliceGroupKeyStore!)
        let messageData = "This is Group truyen cuoi".data(using: .utf8)
        
        guard let sentBobDistributionMessage = try? self.bobGroupCipher?.createSession() else {
            XCTFail("Failed to create distribution message")
            return
        }
        
        guard let distributionMessage = try? sentBobDistributionMessage.protoData() else {
            XCTFail("Failed to serialize SenderKeyDistributionMessage")
            return
        }
        
        do {
            self.distributionMessage = distributionMessage
            self.cipherMessage = try bobGroupCipher?.encrypt(messageData!)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch {
            XCTFail("Other error")
        }
    }
    
    func carlCreateGroupCipher() {
        self.carlGroupCipher = GroupCipher(address: groupSender!, store: carlGroupKeyStore!)
    }
    
    func carlProcessDistributionMessage() {
        do {
            let distributionMessage = try SenderKeyDistributionMessage(from: self.distributionMessage!)
            try carlGroupCipher?.process(distributionMessage: distributionMessage)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch let error {
            print("Fail to process distribution message")
            XCTFail(error.localizedDescription)
        }
    }
    
    func aliceSendMessage(message: Data) {
        do {
            self.cipherMessage = try aliceGroupCipher?.encrypt(message)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func aliceReceiveMessage() {
        do {
            guard let data = self.cipherMessage?.data else {
                XCTFail("Not receive message or message damaged")
                return
            }
            let cipherMess = try SenderKeyMessage(from: data)
            let messageData = try aliceGroupCipher?.decrypt(ciphertext: cipherMess)
            let plaintext = String(decoding: messageData!, as: UTF8.self)
            print("Alice received: \(plaintext)")
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func bobSendMessage(message: Data) {
        do {
            self.cipherMessage = try bobGroupCipher?.encrypt(message)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func bobReceiveMessage() {
        do {
            guard let data = self.cipherMessage?.data else {
                XCTFail("Not receive message or message damaged")
                return
            }
            let cipherMess = try SenderKeyMessage(from: data)
            let messageData = try bobGroupCipher?.decrypt(ciphertext: cipherMess)
            let plaintext = String(decoding: messageData!, as: UTF8.self)
            print("Bob received: \(plaintext)")
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func carlSendMessage(message: Data) {
        do {
            self.cipherMessage = try carlGroupCipher?.encrypt(message)
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func carlReceiveMessage() {
        do {
            guard let data = self.cipherMessage?.data else {
                XCTFail("Not receive message or message damaged")
                return
            }
            let cipherMess = try SenderKeyMessage(from: data)
            let messageData = try carlGroupCipher?.decrypt(ciphertext: cipherMess)
            let plaintext = String(decoding: messageData!, as: UTF8.self)
            print("Carl received: \(plaintext)")
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testComunication() {
        aliceSignUp()
        bobSignUp()
        carlSignUp()
        aliceCreateGroupChat()
        bobCreateGroupCipherAndSendMessage()
        carlCreateGroupCipher()
        aliceProcessDistributionMessage()
        carlProcessDistributionMessage()
        
        aliceReceiveMessage()
        carlReceiveMessage()
        
        let aliceMessages = ["Hello everyone, can you talk vietnamese?", "Tau hai is real", "This is tau hai time"]
        let bobMessages = ["Oke", "Yeah tau hai cuc manh", "Hai Hoai Linh iz da bezt"]
        let carlMessages = ["Im from Dong Lao", "Mua quat di ae", "No no, Minh Beo tau hai manh hon"]
        
        for i in 0..<3 {
            var data = aliceMessages[i].data(using: .utf8)
            aliceSendMessage(message: data!)
            bobReceiveMessage()
            carlReceiveMessage()
            
            data = bobMessages[i].data(using: .utf8)
            bobSendMessage(message: data!)
            aliceReceiveMessage()
            carlReceiveMessage()
            
            data = carlMessages[i].data(using: .utf8)
            carlSendMessage(message: data!)
            aliceReceiveMessage()
            bobReceiveMessage()
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

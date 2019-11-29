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
    var message: CipherTextMessage?

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
            print(error.description)
        } catch {
            print("Other error")
        }
        
        do {
            let publicKey = try self.aliceKeyStore?.identityKeyStore.getPublicIdentityKey()
            let preKeys = try self.aliceKeyStore?.createPreKeys(count: 10)
            let signedPreKey = try self.aliceKeyStore?.updateSignedPrekey()
            self.alicePreKeyBundle = try SessionPreKeyBundle(preKey: preKeys!.first!, signedPreKey: signedPreKey!, identityKey: publicKey!)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }

    func bobSignUp()  {
        self.bobAddress = SignalAddress(identifier: "0561351813", deviceId: 1)
        do {
            let identityKey = try crypto.generateIdentityKeyPair()
            self.bobKeyStore = SignalKeyStore(withKeyPair: identityKey)
            self.bobGroupKeyStore = SignalGroupKeyStore(withKeyPair: identityKey)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
        
        do {
            let publicKey = try self.aliceKeyStore?.identityKeyStore.getPublicIdentityKey()
            let preKeys = try self.bobKeyStore?.createPreKeys(count: 10)
            let signedPreKey = try self.bobKeyStore?.updateSignedPrekey()
            self.bobPreKeyBundle = try SessionPreKeyBundle(preKey: preKeys!.first!, signedPreKey: signedPreKey!, identityKey: publicKey!)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }

    func carlSignUp() {
        self.carlAddress = SignalAddress(identifier: "02213456", deviceId: 1)
        do {
            let identityKey = try crypto.generateIdentityKeyPair()
            self.carlKeyStore = SignalKeyStore(withKeyPair: identityKey)
            self.carlGroupKeyStore = SignalGroupKeyStore(withKeyPair: identityKey)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
        do {
            let publicKey = try self.carlKeyStore?.identityKeyStore.getPublicIdentityKey()
            let preKeys = try self.carlKeyStore?.createPreKeys(count: 10)
            let signedPreKey = try self.carlKeyStore?.updateSignedPrekey()
            self.carlPreKeyBundle = try SessionPreKeyBundle(preKey: preKeys!.first!, signedPreKey: signedPreKey!, identityKey: publicKey!)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }
    
    func aliceCreateGroupChat() {
        self.groupSender = SignalSenderKeyName(groupid: "Group truyen cuoi", sender: self.aliceAddress!)
        self.aliceGroupCipher = GroupCipher(address: groupSender!, store: aliceGroupKeyStore!)
        
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
            self.message = try bobGroupCipher?.encrypt(messageData!)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }
    
    func carlCreateGroupCipher() {
        self.carlGroupCipher = GroupCipher(address: groupSender!, store: carlGroupKeyStore!)
    }
    
    func aliceSendMessage(message: Data) {
        
    }
    
    func testComunication() {
        aliceSignUp()
        bobSignUp()
        carlSignUp()
        aliceCreateGroupChat()
        bobCreateGroupCipherAndSendMessage()
        carlCreateGroupCipher()
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

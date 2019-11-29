//
//  E2EETests.swift
//  E2EETests
//
//  Created by Thang on 18/10/2019.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import XCTest
@testable import E2EE

class UnitTestUser {
    var session: SessionCipher<SignalKeyStore>?
    var address: SignalAddress?
    var keyStore: SignalKeyStore?
    var preKeyBundle: SessionPreKeyBundle?
    
    init(address: SignalAddress , keyStore: SignalKeyStore, preKeyBundle: SessionPreKeyBundle) {
        self.address = address
        self.keyStore = keyStore
        self.preKeyBundle = preKeyBundle
    }
}

class PairComunicationTest: XCTestCase {
    
    let crypto = CommonSignalCrypto()
    var socket: NetWorkSocket?
    
    var alicePreKeyBundle: SessionPreKeyBundle?
    var aliceKeyStore: SignalKeyStore?
    var aliceAddress: SignalAddress?
    var aliceSession: SessionCipher<SignalKeyStore>?
    
    var bobPreKeyBundle: SessionPreKeyBundle?
    var bobKeyStore: SignalKeyStore?
    var bobAddress: SignalAddress?
    var bobSession: SessionCipher<SignalKeyStore>?
    
    var testSignalModelArray: [SignalIdentityKeyStore]?
    
    var message: CipherTextMessage?
    
    var array: [UnitTestUser?]?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.socket = try! NetWorkSocket(withHost: "127.0.0.1", and: "8000")
        array = [UnitTestUser]()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSignUp(identifier: String, deviceID: UInt32) {
        let newAddress = SignalAddress(identifier: identifier, deviceId: deviceID)
        let identityKey  = try? crypto.generateIdentityKeyPair()
        guard let iKey = identityKey else {
            XCTFail("Can't create identity key pair")
            return
        }
        
        let newKeyStore = SignalKeyStore(withKeyPair: iKey)
        
        var prekeyBundle: SessionPreKeyBundle?
        do {
            let newPublicKey = try newKeyStore.identityKeyStore.getPublicIdentityKey()
            let preKeys = try newKeyStore.createPreKeys(count: 10)
            let signedPrekey = try newKeyStore.updateSignedPrekey()
            prekeyBundle = try SessionPreKeyBundle(preKey: preKeys.first!, signedPreKey: signedPrekey, identityKey: newPublicKey)
        }
        catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
        
        let newUser = UnitTestUser(address: newAddress, keyStore: newKeyStore, preKeyBundle: prekeyBundle!)
        self.array?.append(newUser)
    }
    
    func testSendMessage(sender: UnitTestUser!, receiverAdd: SignalAddress!, message: Data) {
        do {
            self.message = try sender.session!.encrypt(message)
            //self.message = try session.encrypt(message)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
        print("Sending ....")
    }
    
    func testReceiveMessage(receiver: UnitTestUser!) {
        do {
            let data = try receiver.session?.decrypt(self.message!)
            let message = String(decoding: data!, as: UTF8.self)
            print("received: \(message)")
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }
    
    func testAliceInitializeChatSession() {
        let alice = self.array![0]
        let bob = self.array![1]
        alice!.session = SessionCipher(store: alice!.keyStore!, remoteAddress: bob!.address!)
        do {
            try alice!.session!.process(preKeyBundle: bob!.preKeyBundle!)
            let initializeMessage = "Hello Bob, it's Alice. This is setup key message".data(using: .utf8)
            if let message = initializeMessage {
                do {
                    self.message = try alice?.session!.encrypt(message)
                } catch let error as SignalError {
                    print(error.description)
                } catch {
                    print("Other error")
                }
            }
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }
    
    func testBobSetupByRecieveAliceMessage() {
        let alice = self.array![0]
        let bob = self.array![1]
        bob!.session = SessionCipher(store: bob!.keyStore!, remoteAddress: alice!.address!)
        guard let cipherMessage = self.message else {
            XCTFail("Not receive message")
            return
        }
        
        do {
            let decryptedMessage = try bob!.session!.decrypt(cipherMessage)
            let message = String(decoding: decryptedMessage, as: UTF8.self)
            print("Bob receive \(message)")
        } catch let error as SignalError {
            print(error.longDescription)
        } catch {
            print("Other Error")
        }
    }
    
    func testDriver() {
        testSignUp(identifier: "AliceIdentifier", deviceID: 1)
        testSignUp(identifier: "BobIdentifier", deviceID: 2)
        testAliceInitializeChatSession()
        testBobSetupByRecieveAliceMessage()
        let bob = array![1]
        let alice = array![0]
        
        let aliceMessage : [String] = ["Oh hi Bob", "Yeah", "Welcome home", "My heart are broken", "Long time no see"]
        let bobMessage : [String] = ["Hello you", "Are you ready?", "Hello world", "Can you love me?", "Old But Gold"]
        
        for i in 0..<5 {
            var data = bobMessage[i].data(using: .utf8)
            testSendMessage(sender: bob, receiverAdd: alice?.address, message: data!)
            testReceiveMessage(receiver: alice)
            data = aliceMessage[i].data(using: .utf8)
            testSendMessage(sender: alice, receiverAdd: bob?.address, message: data!)
            testReceiveMessage(receiver: bob)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}




extension PairComunicationTest: NetbaseSocketDelegate {
    func receive(_ data: Data) {
        print("Receive data")
    }
    
    func stateDidChange(_ state: ConnectivityState) {
        switch state {
        case .canceled:
            print("Connect is canceled")
        case .failed:
            print("Connect is failed")
        case .preparing:
            print("Connect is preparing")
        case .ready:
            print("Connect is ready")
        case .setup:
            print("Connect is setting up")
        case .waiting:
            print("Connect is waiting")
        }
    }
    
    
}

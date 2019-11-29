//
//  E2EETests.swift
//  E2EETests
//
//  Created by Thang on 18/10/2019.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import XCTest
@testable import E2EE

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
    
    var message: CipherTextMessage?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.socket = try! NetWorkSocket(withHost: "127.0.0.1", and: "8000")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBobSignUp() {
        self.bobAddress = SignalAddress(identifier: "02468", deviceId: 1)
        
        let identityKey = try? crypto.generateIdentityKeyPair()
        guard let IKey = identityKey else {
            XCTFail("Can't create key")
            return
        }
        let keyStore = SignalKeyStore(withKeyPair: IKey)
        self.bobKeyStore = keyStore
        
        do {
            let publicKey = try keyStore.identityKeyStore.getPublicIdentityKey()
            let preKeys = try keyStore.createPreKeys(count: 10)
            let signedPreKey = try keyStore.updateSignedPrekey()
            
            self.bobPreKeyBundle = try SessionPreKeyBundle(preKey: preKeys.first!, signedPreKey: signedPreKey, identityKey: publicKey)
            
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }

    func testAliceSignUp() {
        self.aliceAddress = SignalAddress(identifier: "13579", deviceId: 2)
        
        let identityKey = try? crypto.generateIdentityKeyPair()
        guard let IKey = identityKey else {
            XCTFail("Can't create key")
            return
        }
        let keyStore = SignalKeyStore(withKeyPair: IKey)
        self.aliceKeyStore = keyStore
        
        do {
            let publicKey = try keyStore.identityKeyStore.getPublicIdentityKey()
            let preKeys = try keyStore.createPreKeys(count: 10)
            let signedPreKey = try keyStore.updateSignedPrekey()
            
            self.alicePreKeyBundle = try SessionPreKeyBundle(preKey: preKeys.first!, signedPreKey: signedPreKey, identityKey: publicKey)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
        
        
        //Send preKey bundle to server by socket
    }
    
    func testAliceInitializeChatSession() {
        testBobSignUp()
        testAliceSignUp()
        //Assume that Alice want to initialize chat session with Bob and downloaded Bob preKey bundle
        guard let bobPreKeyBundle = self.bobPreKeyBundle, let _ = self.alicePreKeyBundle else {
            XCTFail("Error with network or key has damage")
            return
        }
        guard let bobAddress = self.bobAddress, let _ = self.aliceAddress, let aliceKeyStore = self.aliceKeyStore, let _ = self.bobKeyStore else {
            XCTFail("Error with sign up process")
            return
        }
        //let session = SessionCipher(store: aliceKeyStore, remoteAddress: bobAddress)
        self.aliceSession = SessionCipher(store: aliceKeyStore, remoteAddress: bobAddress)
        do {
            //try session.process(preKeyBundle: bobPreKeyBundle)
            try self.aliceSession?.process(preKeyBundle: bobPreKeyBundle)
            let initializeMessage = "Hello Bob, it's Alice".data(using: .utf8)
            if let message = initializeMessage {
                do {
                    //self.message = try session.encrypt(message)
                    self.message = try self.aliceSession?.encrypt(message)
                    //let encryptedMessage = String(decoding: self.message!.data, as: UTF8.self)
                    //print(encryptedMessage)
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
        testBobSignUp()
        testAliceSignUp()
        testAliceInitializeChatSession()
        //By accept making friend with Alice, Bob has Alice Address
        guard let bobStore = self.bobKeyStore, let aliceAddress = self.aliceAddress else {
            XCTFail("Sign up failed or didn't make friend")
            return
        }
        self.bobSession = SessionCipher(store: bobStore, remoteAddress: aliceAddress)
        guard let cipherMessage = self.message else {
            XCTFail("Not receive message")
            return
        }
        
        do {
            //let decryptedMessage = try session.decrypt(cipherMessage)
            let decryptedMessage = try self.bobSession?.decrypt(cipherMessage)
            let message = String(decoding: decryptedMessage!, as: UTF8.self)
            print(message)
        } catch let error as SignalError {
            print(error.longDescription)
        } catch {
            print("Other Error")
        }
    }
    
    //Bob send message
    func sendBobMessage(message: Data) {
        guard let bobStore = self.bobKeyStore, let aliceAddress = self.aliceAddress else {
            XCTFail("Sign up failed or didn't making friend")
            return
        }
        do {
            self.message = try self.bobSession?.encrypt(message)
            //self.message = try session.encrypt(message)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
        
        //Send message to server
    }
    
    //Bob receive message
    func receiveAliceMessage() {
        guard let bobStore = self.bobKeyStore, let aliceAddress = self.aliceAddress else {
            XCTFail("Sign up failed or didn't making friend")
            return
        }
        do {
            let data = try self.bobSession?.decrypt(self.message!)
            //let data = try session.decrypt(self.message!)
            let message = String(decoding: data!, as: UTF8.self)
            print("Bob received: \(message)")
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }
    
    //Alice send message
    func sendAliceMessage(message: Data) {
        guard let aliceStore = self.aliceKeyStore, let bobAddress = self.bobAddress else {
            XCTFail("Sign up failed or did'nt making friend")
            return
        }
        do {
            //self.message = try session.encrypt(message)
            self.message = try self.aliceSession?.encrypt(message)
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }
    
    //Alice received message
    func receiveBobMessage()  {
        guard let aliceStore = self.aliceKeyStore, let bobAddress = self.bobAddress else {
            XCTFail("Sign up failed or didn't making friend")
            return
        }
        do {
            let data = try self.aliceSession?.decrypt(self.message!)
            //let data = try session.decrypt(self.message!)
            let message = String(decoding: data!, as: UTF8.self)
            print("Alice receive: \(message)")
        } catch let error as SignalError {
            print(error.description)
        } catch {
            print("Other error")
        }
    }
    
    func testBobAndAliceComunication() {
        testBobSignUp()
        testAliceSignUp()
        testAliceInitializeChatSession()
        testBobSetupByRecieveAliceMessage()
        
        let bobMessage : [String] = ["Hello you", "Are you ready?", "Hello world", "Can you love me?", "Old But Gold"]
        let aliceMessage : [String] = ["Oh hi Bob", "Yeah", "Welcome home", "My heart are broken", "Long time no see"]
//        for i in 0..<5 {
//            var data = bobMessage[i].data(using: .utf8)
//            sendBobMessage(message: data!)
//            receiveBobMessage()
//            data = aliceMessage[i].data(using: .utf8)
//            sendAliceMessage(message: data!)
//            receiveAliceMessage()
//        }
        
        var data = bobMessage[0].data(using: .utf8)
        sendBobMessage(message: data!)
        data = bobMessage[1].data(using: .utf8)
        sendBobMessage(message: data!)
        receiveBobMessage()
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
        default:
            print("No thing happen")
        }
    }
    
    
}

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
    
    var bobPreKeyBundle: SessionPreKeyBundle?
    var bobKeyStore: SignalKeyStore?
    var bobAddress: SignalAddress?
    
    var message: CipherTextMessage?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.socket = try! NetWorkSocket(withHost: "127.0.0.1", and: "8000")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBobSignUp() {
        _ = UserModel(userName: "leminhtam", password: "abcdef", fullName: "LeMinhTam")
        self.bobAddress = SignalAddress(identifier: "02468", deviceId: 1)
        
        let identityKey = try? crypto.generateIdentityKeyPair()
        guard let socket = self.socket else {
            XCTFail("Socket init failed")
            return
        }
        guard let IKey = identityKey else {
            XCTFail("Can't create key")
            return
        }
        let keyStore = SignalKeyStore(withKeyPair: IKey)
        let publicKey = try? keyStore.identityKeyStore.getPublicIdentityKey()
        let preKeys = try? keyStore.createPreKeys(count: 10)
        let signedPreKey = try? keyStore.updateSignedPrekey()
        
        guard let pKey = publicKey, let pKeys = preKeys, let sPreKey = signedPreKey else {
            XCTFail("Can't create key")
            return
        }
        self.bobPreKeyBundle = try? SessionPreKeyBundle(preKey: pKeys.first!, signedPreKey: sPreKey, identityKey: pKey)
        //Send preKey bundle to Server
        //socket.send(pKey)
        //socket.send(pKeys.first!)
        //socket.send(sPreKey)
    }

    func testAliceSignUp() {
        _ = UserModel(userName: "phusidcn", password: "123456", fullName: "HuynhLamPhuSi")
        self.aliceAddress = SignalAddress(identifier: "13579", deviceId: 2)
        
        let identityKey = try? crypto.generateIdentityKeyPair()
        guard let IKey = identityKey else {
            XCTFail("Can't create key")
            return
        }
        let keyStore = SignalKeyStore(withKeyPair: IKey)
        let publicKey = try? keyStore.identityKeyStore.getPublicIdentityKey()
        let preKeys = try? keyStore.createPreKeys(count: 10)
        let signedPreKey = try? keyStore.updateSignedPrekey()
        guard let pKey = publicKey, let pKeys = preKeys, let sKey = signedPreKey else {
            XCTFail("Can't create file")
            return
        }
        self.alicePreKeyBundle = try? SessionPreKeyBundle(preKey: pKeys.first!, signedPreKey: sKey, identityKey: pKey)
        
        //Send preKey bundle to server by socket
    }
    
    func testAliceInitializeChatSession() {
        //Assume that Alice want to initialize chat session with Bob and downloaded Bob preKey bundle
        guard let bobPreKeyBundle = self.bobPreKeyBundle, let _ = self.alicePreKeyBundle else {
            XCTFail("Error with network or key has damage")
            return
        }
        guard let bobAddress = self.bobAddress, let _ = self.aliceAddress, let aliceKeyStore = self.aliceKeyStore, let _ = self.bobKeyStore else {
            XCTFail("Error with sign up process")
            return
        }
        let session = SessionCipher(store: aliceKeyStore, remoteAddress: bobAddress)
        try? session.process(preKeyBundle: bobPreKeyBundle)
        
        let initializeMessage = "Hello Bob, it's Alice".data(using: .utf8)
        if let message = initializeMessage {
            self.message = try? session.encrypt(message)
            //Send message to server by socket
        }
    }
    
    func testBobInitializeByRecieveAliceMessage() {
        //By accept making friend with Alice, Bob has Alice Address
        guard let bobStore = self.bobKeyStore, let aliceAddress = self.aliceAddress else {
            XCTFail("Sign up failed or didn't make friend")
            return
        }
        let session = SessionCipher(store: bobStore, remoteAddress: aliceAddress)
        guard let cipherMessage = self.message else {
            XCTFail("Not receive message")
            return
        }
        let decryptedMessage = try? session.decrypt(cipherMessage)
        //Show message to UI
    }
    
    //Bob send message
    func sendMessage(message: Data) {
        guard let bobStore = self.bobKeyStore, let aliceAddress = self.aliceAddress else {
            XCTFail("Sign up failed or didn't making friend")
            return
        }
        let session = SessionCipher(store: bobStore, remoteAddress: aliceAddress)
        self.message = try? session.encrypt(message)
        //Send message to server
    }
    
    //Alice received message
    func receiveMessage(message: Data)  {
        guard let aliceStore = self.aliceKeyStore, let bobAddress = self.bobAddress, let cipherMessage = self.message else {
            XCTFail("Sign up failed or didn't making friend")
            return
        }
        let session = SessionCipher(store: aliceStore, remoteAddress: bobAddress)
        let message = try? session.decrypt(cipherMessage)
        //Show message to UI
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

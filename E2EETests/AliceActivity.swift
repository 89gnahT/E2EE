//
//  AliceActivity.swift
//  E2EETests
//
//  Created by CPU11899 on 12/9/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import XCTest
@testable import E2EE

class AliceActivity: XCTestCase {
    var socket: GenericSocket?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.socket = StreamSocket()
        do {
            try self.socket?.loadSetting(host: "127.0.0.1", port: "8000")
            self.socket?.delegate = self
        } catch let error as NetBaseError {
            XCTFail(error.description)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSignUp() {
        let crypto = CommonSignalCrypto()
        do {
            let address = SignalAddress(identifier: "01217410648", deviceId: 1)
            let identityKey = try crypto.generateIdentityKeyPair()
            let keyStore = SignalKeyStore(withKeyPair: identityKey)
            let publicKey = try keyStore.identityKeyStore.getPublicIdentityKey()
            let signedPreKey = try keyStore.updateSignedPrekey()
            let preKeys = try keyStore.createPreKeys(count: 10)
            let keyBundle = try SessionPreKeyBundle(preKey: preKeys.first!, signedPreKey: signedPreKey, identityKey: publicKey)
            let remoteKeyBundle = FirebaseKeyStorage(identityKey: identityKey, SignedPreKey: signedPreKey, OneTimePreKeys: preKeys)
            let userIdentifier = FirebaseUserStorage(address: address, keyBundle: remoteKeyBundle)
            let currentUser = CurrentLoginUser(localKey: keyBundle, firebaseKey: userIdentifier)
            currentUser.uploadKeyBunde("Alice")
        } catch let error as SignalError {
            XCTFail(error.description)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension AliceActivity: NetbaseSocketDelegate {
    func receive(_ data: Data) {
        print("Received message")
    }
    
    func stateDidChange(_ state: ConnectivityState) {
        switch state {
        case .ready:
            print("socket ready")
        default:
            print("socket not ready")
        }
    }
    
    
}

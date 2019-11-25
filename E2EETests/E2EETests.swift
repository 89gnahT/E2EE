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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.socket = try! NetWorkSocket(withHost: "127.0.0.1", and: "8000")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBobSignUp() {
        _ = UserModel(userName: "leminhtam", password: "abcdef", fullName: "LeMinhTam")
        _ = SignalAddress(identifier: "02468", deviceId: 1)
        
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
        _ = try? SessionPreKeyBundle(preKey: pKeys.first!, signedPreKey: sPreKey, identityKey: pKey)
        socket.send(pKey)
        socket.send(pKeys.first!)
        socket.send(sPreKey)
    }

    func testAliceSignUp() {
        _ = UserModel(userName: "phusidcn", password: "123456", fullName: "HuynhLamPhuSi")
        _ = SignalAddress(identifier: "13579", deviceId: 2)
        
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
        _ = try? SessionPreKeyBundle(preKey: pKeys.first!, signedPreKey: sKey, identityKey: pKey)
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

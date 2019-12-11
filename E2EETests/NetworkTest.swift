//
//  NetworkTest.swift
//  E2EETests
//
//  Created by CPU11899 on 12/2/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import XCTest
@testable import E2EE

class NetworkTest: XCTestCase {
    private var socket: GenericSocket?
    let semaphore = DispatchSemaphore(value: 0)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.socket = StreamSocket()
        do {
            try socket?.loadSetting(host: "127.0.0.1", port: "8000")
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

    func testSendMessage() {
        let message = "200\r\n"
        let data = message.data(using: .utf8)
        self.socket?.send(data!)
        RunLoop.current.run()
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

extension NetworkTest: NetbaseSocketDelegate {
    func receive(_ data: Data) {
        let message = String(decoding: data, as: UTF8.self)
        print(message)
    }
    
    func stateDidChange(_ state: ConnectivityState) {
        switch state {
        case .ready:
            print("Ready")
        default:
            print("Not ready")
        }
    }
    
    
}

//
//  SignalSocket.swift
//  E2EE
//
//  Created by Huynh Lam Phu Si on 11/6/19. Hail hello bye underwear daddy and mom Latin sad
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

@available(iOS 12.0, *)
class SignalProtocol {
    var userStorage: SignalGroupKeyStore
    var socket: NetWorkSocket? {
        do {
            let s = try NetWorkSocket(withHost: "127.0.0.1", and: "8000")
            return s
        } catch {
            print("Error")
        }
        return nil
    }
    
    init(_ user: UserModel) {
        userStorage = SignalGroupKeyStore()
        do {
            try signUpAccount(user)
        } catch {
            print("Error when Sign up account")
        }
    }
    
    func signUpAccount(_ user: UserModel) throws {
        socket?.delegate = self
        let crypto = CommonSignalCrypto()
        do {
//            let identity = try crypto.generateIdentityKeyPair()
//            let bobStore = SignalGroupKeyStore(withKeyPair: identity)
//            let publicKey: Data = try bobStore.identityKeyStore.getPublicIdentityKey()
//            let preKeys: [Data] = try bobStore.createPreKeys(count: 10)
//            let signedKeys = try bobStore.updateSignedPrekey()
//            self.socket?.send(publicKey)
//            self.socket?.send(signedKeys)
//            self.socket?.send(preKeys.first!)
        } catch {
            throw SignalError(.unknown, "Generate key error")
        }
    }
    
    func startCommunicationWith() {
        
    }
    
    func receiveInvitedOf() {
        
    }
    
    func sendMessage(message: Data) {
        
    }
    
    func receiveMessage(message: Data) {
        
    }
}

@available(iOS 12.0, *)
extension SignalProtocol: NetbaseSocketDelegate {
    
    func receive(_ data: Data) {
        print("Received message")
    }
    
    func stateDidChange(_ state: ConnectivityState) {
        switch state {
        case .canceled:
            print("Connect cancelled")
        case .failed:
            print("Connect failed")
        case .preparing:
            print("Connect is preparing")
        case .ready:
            print("Connect is ready")
        case .setup:
            print("Connect is setting up")
        case .waiting:
            print("Connectio in waiting")
        }
    }

}

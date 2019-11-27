//
//  SessionRecord.swift
//  E2EE
//
//  Created by CPU11899 on 10/28/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

final class SessionRecord: ProtocolBufferEquivalent {
    private static let archiveStateMax = 40
    private(set) var state: SessionState
    private(set) var previousStates: [SessionState]
    private(set) var isFresh: Bool
    
    init(state: SessionState?) {
        if state == nil {
            self.state = SessionState()
            self.isFresh = true
        } else {
            self.state = state!
            self.isFresh = false
        }
        self.previousStates = [SessionState]()
    }
    
    func hasSessionState(baseKey: PublicKey) -> Bool {
        if state.aliceBaseKey == baseKey {
            return true
        }
        return previousStates.contains {
            $0.aliceBaseKey == baseKey
        }
//        return previousStates.contains(where: {(sessionState: SessionState) in
//            sessionState.aliceBaseKey == baseKey
//        })
    }
    
    func archiveCurrentState() {
        let newState = SessionState()
        promoteState(state: newState)
    }
    
    func promoteState(state: SessionState) {
        if let baseKey = state.aliceBaseKey {
            removeState(for: baseKey)
        }
        previousStates.insert(self.state, at: 0)
        self.state = state
        if previousStates.count > SessionRecord.archiveStateMax {
            previousStates = Array(previousStates[0..<SessionRecord.archiveStateMax])
        }
    }
    
    private func removeState(for baseKey: PublicKey) {
        if let i = previousStates.firstIndex(where: {(sessionState: SessionState) in
            sessionState.aliceBaseKey == baseKey
        }) {
            previousStates.remove(at: i)
        }
    }
    
    var protoObject: Signal_Record {
        return Signal_Record.with {
            $0.currentSession = self.state.protoObject
            $0.previousSessions = self.previousStates.map({return $0.protoObject})
        }
    }
    
    init(from protoObject: Signal_Record) throws {
        guard protoObject.hasCurrentSession else {
            throw SignalError(.invalidProtoBuf, "Invalid ProtoObject for Session Record")
        }
        self.state = try SessionState(from: protoObject.currentSession)
        self.previousStates = try protoObject.previousSessions.map{
            try SessionState(from: $0)
        }
        self.isFresh = false
    }
}


extension SessionRecord: Equatable {
    public static func ==(lhs: SessionRecord, rhs: SessionRecord) -> Bool {
        return lhs.state == rhs.state && lhs.isFresh == rhs.isFresh && lhs.previousStates == rhs.previousStates
    }
}

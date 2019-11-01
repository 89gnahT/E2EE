//
//  DeviceConsistencyMessage.swift
//  E2EE
//
//  Created by CPU11899 on 11/1/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

struct DeviceConsistencyMessage {
    var signature: DeviceConsistencySignature
    var generation: UInt32
    
    init(commitment: DeviceConsistencyCommitmentV0, identityKeyPair: KeyPair) throws {
        let serialized = commitment.serialized
        let signature = try identityKeyPair.privateKey.signVRF(message: serialized)
        let vrfOutput = try identityKeyPair.publicKey.verify(vrfSignature: signature, for: serialized)
        self.signature = DeviceConsistencySignature(signature: signature, vrfOutput: vrfOutput)
        self.generation = commitment.generation
    }
}

extension DeviceConsistencyMessage {
    var protoObject: Signal_DeviceConsistencyCodeMessage {
        return Signal_DeviceConsistencyCodeMessage.with {
            $0.generation = self.generation
            $0.signature = self.signature.signature
        }
    }
    
    init(from protoObject: Signal_DeviceConsistencyCodeMessage, commitment: DeviceConsistencyCommitmentV0, identityKey: PublicKey) throws {
        guard protoObject.hasSignature, protoObject.hasGeneration else {
            throw SignalError(.invalidProtoBuf, "Missing data in protobuf object")
        }
        let vrfOutput = try identityKey.verify(vrfSignature: protoObject.signature, for: commitment.serialized)
        self.signature = DeviceConsistencySignature(signature: protoObject.signature, vrfOutput: vrfOutput)
        self.generation = protoObject.generation
    }
    
    func data() throws -> Data {
        do {
            return try protoObject.serializedData()
        } catch {
            throw SignalError(.invalidProtoBuf, "Could not serialize Device Consistency message:\(error.localizedDescription)")
        }
    }
    
    init(from data: Data, commitment: DeviceConsistencyCommitmentV0, identityKey: PublicKey) throws {
        let object: Signal_DeviceConsistencyCodeMessage
        do {
            object = try Signal_DeviceConsistencyCodeMessage(serializedData: data)
        } catch {
            throw SignalError(.invalidProtoBuf, "Could not deserialize DeviceConsistencyMessage:\(error.localizedDescription)")
        }
        try self.init(from: object, commitment: commitment, identityKey: identityKey)
    }
}

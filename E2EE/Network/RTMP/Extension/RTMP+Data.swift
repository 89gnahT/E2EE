//
//  RTMP+Data.swift
//  E2EE
//
//  Created by CPU11899 on 11/18/19.
//  Copyright © 2019 ThangNVH. All rights reserved.
//

import Foundation

// MARK :- Get bytes and Split bytes
public protocol ExtendDataWriterProtocol: class {
    func write(_ value: UInt8) -> Self
    func write(_ value: UInt16, bigEndian: Bool) -> Self
    func write(_ value: Int16, bigEndian: Bool) -> Self
    func write(_ value: UInt32, bigEndian: Bool) -> Self
    func write(_ value: Int32, bigEndian: Bool) -> Self
    func write(_ value: Double, bigEndian: Bool) -> Self
    func writeU24(_ value: Int, bigEndian: Bool) -> Self
    func write(_ data: Data) -> Self
}

class ExtendDataWriter {
    var base: UnsafeMutablePointer<Data>
    init(_ base: UnsafeMutablePointer<Data>) {
        self.base = base
    }
}

extension Data {
    public var bytes:[UInt8] {
        return withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> [UInt8] in
            let typedBuffer = buffer.bindMemory(to: UInt8.self)
            let pointer = typedBuffer.baseAddress!
            return [UInt8](UnsafeBufferPointer(start: pointer, count: count))
        })
    }
    
    public func split(size: Int) -> [Data] {
        return self.bytes.split(size: size).map({return Data($0)})
    }
}
// MARK : - Decode from data to typed
extension Data {
    var int: Int {
        return withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> Int in
            let typedBuffer = buffer.bindMemory(to: Int.self)
            let pointer = typedBuffer.baseAddress!
            return pointer.pointee
        })
    }
    
    var uint8: UInt8 {
        return withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> UInt8 in
            let typedBuffer = buffer.bindMemory(to: UInt8.self)
            let pointer = typedBuffer.baseAddress!
            return pointer.pointee
        })
    }
    
    var uint16: UInt16 {
        return withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> UInt16 in
            let typedBuffer = buffer.bindMemory(to: UInt16.self)
            let pointer = typedBuffer.baseAddress!
            return pointer.pointee
        })
    }
    
    var uint32: UInt32 {
        return withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> UInt32 in
            let typedBuffer = buffer.bindMemory(to: UInt32.self)
            let pointer = typedBuffer.baseAddress!
            return pointer.pointee
        })
    }
    
    var int32: Int32 {
        return withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> Int32 in
            let typedBuffer = buffer.bindMemory(to: Int32.self)
            let pointer = typedBuffer.baseAddress!
            return pointer.pointee
        })
    }
    
    var float: Float {
        return withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> Float in
            let typedBuffer = buffer.bindMemory(to: Float.self)
            let pointer = typedBuffer.baseAddress!
            return pointer.pointee
        })
    }
    
    var double: Double {
        return withUnsafeBytes({(buffer: UnsafeRawBufferPointer) -> Double in
            let typedBuffer = buffer.bindMemory(to: Double.self)
            let pointer = typedBuffer.baseAddress!
            return pointer.pointee
        })
    }
    
    var string: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}

// MARK : - Data extension with range

extension Data {
    subscript (r: Range<Int>) -> Data {
        let range = Range(uncheckedBounds: (lower: Swift.max(0, r.lowerBound), Swift.min(count, r.upperBound)))
        return self.subdata(in: range)
    }
    
    subscript (safe range: CountableRange<Int>) -> Data? {
        if range.lowerBound < 0 || range.upperBound > self.count {
            return nil
        }
        return self[range]
    }
    
    subscript (safe range: CountableClosedRange<Int>) -> Data? {
        if range.lowerBound < 0 || range.upperBound >= self.count {
            return nil
        }
        return self[range]
    }
    
    subscript (safe index: Int) -> UInt8? {
        if index > 0 && index < self.count {
            return self[index]
        }
        return nil
    }
}

// MARK : - Data extension with append

extension Data {
    var extendWrite: ExtendDataWriter {
        mutating get {
            return ExtendDataWriter(&self)
        }
    }
}

extension ExtendDataWriter: ExtendDataWriterProtocol {
    @discardableResult
    func write(_ value: UInt8) -> Self {
        base.pointee.append(value)
        return self
    }
    
    @discardableResult
    func write(_ value: [UInt8]) -> Self {
        base.pointee.append(Data(value))
        return self
    }
    
    @discardableResult
    func write(_ value: Int16, bigEndian: Bool = true) -> Self {
        let newValue = bigEndian ? value.bigEndian : value
        base.pointee.append(newValue.data)
        return self
    }
    
    @discardableResult
    func write(_ value: Int32, bigEndian: Bool = true) -> Self {
        let newValue = bigEndian ? value.bigEndian : value
        base.pointee.append(newValue.data)
        return self
    }
    
    @discardableResult
    func write(_ value: Double, bigEndian: Bool = true) -> Self {
        let newValue = bigEndian ? Data(value.data.reverse()) : value.data
        base.pointee.append(newValue)
        return self
    }
    
    @discardableResult
    func write(_ value: UInt16, bigEndian: Bool = true) -> Self {
        let newValue = bigEndian ? value.bigEndian : value
        base.pointee.append(newValue.data)
        return self
    }
    
    @discardableResult
    func write(_ value: UInt32, bigEndian: Bool = true) -> Self {
        let newValue = bigEndian ? value.bigEndian : value
        base.pointee.append(newValue.data)
        return self
    }
    
    @discardableResult
    func writeU24(_ value: Int, bigEndian: Bool = true) -> Self {
        if bigEndian {
            let convert = UInt32(value).bigEndian.data
            base.pointee.append(convert[1...(convert.count-1)])
        } else {
            let convert = UInt32(value).data
            base.pointee.append(convert[0..<convert.count-1])
        }
        return self
    }
    
    @discardableResult
    func writeUTF8(_ value: String) -> Self {
        base.pointee.append(Data(value.utf8))
        return self
    }
    
    @discardableResult
    func write(_ data: Data) -> Self {
        base.pointee.append(data)
        return self
    }
}

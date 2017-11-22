//
//  ByteUtils.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 13/11/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation

class ByteUtils {
    func getByteArray(m: UInt32) -> [UInt8] {
        var bigEndian = m.bigEndian;
        let count = MemoryLayout<UInt32>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        
        let n = Array(bytePtr)
        
        return n
    }
    
    func getByteArray(m: UInt16) -> [UInt8] {
        var bigEndian = m.bigEndian
        let count = MemoryLayout<UInt16>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        
        let n = Array(bytePtr)
        
        return n
    }
    
    func getShortFromByte(bytes: [UInt8]) -> UInt16 {
        let short = UnsafePointer(bytes).withMemoryRebound(to: UInt16.self, capacity: 1) {
            $0.pointee
        }
        return UInt16(short)
    }
    
    func getIntFromBytes(bytes: [UInt8]) -> Int {
        
        let int = UnsafePointer(bytes).withMemoryRebound(to: Int.self, capacity: 1) {
            $0.pointee
        }
        
        return int
    }
}

//
//  ByteUtils.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 13/11/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation

class ByteUtils {
    /**
        Byte Utilities class for conversions between several unsigned types.
    */
    
    func getByteArray(m: UInt32) -> [UInt8] {
        /**
            Get Bytes in a UInt8 Array from a UInt32
            
            *Values*
            `m` A 32 Bit Unsigned Integer (UInt32)
        */
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
        /**
            Get Bytes in a UInt8 Array from a UInt16
            
            *Values*
            `m` A 16 Bit Unsigned Integer (UInt16)
        */
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
        /** Convert Bytes to a Short (UInt16)
        
            *Values*
        
            `bytes` An array of Unsigned 8 Bit Integers
        */
        let short = UnsafePointer(bytes).withMemoryRebound(to: UInt16.self, capacity: 1) {
            $0.pointee
        }
        return UInt16(short)
    }
    
    func getIntFromBytes(bytes: [UInt8]) -> Int {
        /** Convert Bytes to a Integer
        
            *Values*
        
            `bytes` An array of Unsigned 8 Bit Integers
        */
        let int = UnsafePointer(bytes).withMemoryRebound(to: Int.self, capacity: 1) {
            $0.pointee
        }
        return int
    }
}

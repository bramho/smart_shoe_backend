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
}

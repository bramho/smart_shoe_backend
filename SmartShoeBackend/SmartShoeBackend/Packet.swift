//
//  Packet.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 13/11/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation

class Packet {
    var verifiedPacket : Bool = false
    var CIPHER_CODES : [UInt8] = [115, 97, 108, 116]
    var advertisingTimeout : UInt8 = 0
    var calibrationMode: UInt8 = 0
    var command : UInt8 = 0
    var curveFitFactor : UInt8 = 0
    var deviceSyncTime : Int = 0
    var ledControlMode : UInt8 = 0
    var ledStatus : UInt8 = 0
    var majorFirmwareVersion : UInt8 = 0
    var minorFirmwareVersion : UInt8 = 0
    var majorProtocolVersion : UInt8 = 0
    var minorProtocolVerison : UInt8 = 0
    var numSensor : UInt8  = 0
    var originalSyncTime : Int = 0
    var pairingMode : UInt8 = 0
    var sensorFrequency : UInt8 = 0
    var sensorValue1 : UInt16 = 0
    var sensorValue2 : UInt16 = 0
    var sensorValue3 : UInt16 = 0
    var sensorValue4 : UInt16 = 0
    var serialNumber : Int = 0
    var shoeCategory : UInt8 = 0
    var shoeType : UInt8 = 0
    var status : UInt8 = 0
    var voltageFactor : UInt16 = 0
    let byteUtils = ByteUtils()
    
    func generateRequest(requestType: Int, requestValue: Int, shoeType: Int) -> [UInt8] {
        /// Depending on the type of the shoe (left or right) certain bits regarding the request will need to be appended to the device in order to activate readout.
        switch requestType {
            
        case 4:
            var n : Int = 119 + 96
            let currentTime : UInt32 = UInt32(NSDate().timeIntervalSince1970)
            let byteArray: [UInt8] = ByteUtils().getByteArray(m: currentTime)
            let b3 : UInt8 = byteArray[0] ^ 0x6c
            let b4 : UInt8 = byteArray[1] ^ 0x74
            let b5 : UInt8 = byteArray[2] ^ 0x73
            let b6 : UInt8 = byteArray[3] ^ 0x61
            
            n = (((n + Int(b6)) + 108) + 116)
            
            while(n > 255) {
                n -= 256;
            }
            // BITS: 02 41 00 10 00 0c 00 04 00 52 0e 00 77 60
            if(shoeType == 1){
                let c : [UInt8] = [2, 65, 0, 16, 0, 12, 0, 4, 0, 82, 14, 0, 119, 96, b3, b4, b5, b6, 108, 116, UInt8(n)]
                return c
            } else if (shoeType == 2) {
                let c : [UInt8] = [2, 66, 0, 16, 0, 12, 0, 4, 0, 82, 14, 0, 119, 96, b3, b4, b5, b6, 108, 116, UInt8(n)]
                return c
            } else {
                return [0]
            }
            
        case 3:
            let n : Int = 112 + 96
            let b2 : UInt8 = UInt8(requestValue) ^ 0x6c
            var d : Int = ((n + Int(b2)) + 116)
            
            while d > 255 {
                d -= 256
            }
            
            let c : [UInt8] = [112, 96, b2, 116, UInt8(d)]
            
            return c
            
        case 2:
            var n : Int = 113 + 96 + 110 + 117 + 115 + 97 + 108 + 116 + 114
            
            while n > 255 {
                n -= 256
            }
            
            let b : UInt8 = UInt8(requestValue) ^ 0x61
            
            let c : [UInt8] = [113, 96, 110, 117, 115, 97, 108, 116, 114, b, 108, UInt8((n + Int(b)) + 108)]
            
            return c
            
        case 32:
            var n : Int = 83 + 96
            var byteArray2 : [UInt8] = ByteUtils().getByteArray(m: UInt16(requestValue))
            let b7 : UInt8 = byteArray2[0] ^ 0x6c
            n += Int(b7)
            let b8 : UInt8 = byteArray2[1] ^ 0x74
            n += Int(b8)
            
            while n > 255 {
                n -= 256
            }
            
            let c : [UInt8] = [83, 96, b7, b8, UInt8(n)]
            
            return c
            
        default:
            return [0]
        }
        
    }
    
    
    func parseByteToPacket(array: [UInt8]) -> Packet {
        var packet = Packet()
        var byteArray = array;
        print("count")
        print(byteArray.count)
        if(byteArray.count != 20){
            print("empty")
            return packet;
        } else {
            print("else")
            var b : Int = 0 // REMEMBER TO CAST THIS TO A UINT8 - IT'S A BYTE BUT WE CAN'T AUTO-OVERFLOW BYTES IN SWIFT
            var i : Int = 0
            var n : Int = 0
            while (i < 19) {
                b += Int(byteArray[i])
                let b2 : UInt8 = byteArray[i]
                let n2 : Int = n + 1;
                byteArray[i] = b2 ^ CIPHER_CODES[n]
                n = n2
                if(n > 3) {
                    n = 0
                }
                i += 1
            }
            
            print(byteArray)
            print(b)
            
            while(b > 255){
                b -= 256
            }
            
            print (b)
            print (byteArray[19])
            
            if(UInt8(b) != byteArray[19]){
                return packet
            }
            
            let packet2 = Packet()
            packet2.command = byteArray[0]
            packet2.verifiedPacket = true
            packet = packet2;
            print("Command")
            print(packet2.command)
            switch(packet2.command) {
                
            case 2:
                packet2.status = byteArray[2]
                packet2.shoeType = byteArray[3]
                packet2.shoeCategory = byteArray[4]
                packet2.majorProtocolVersion = byteArray[5]
                packet2.minorProtocolVerison = byteArray[6]
                packet2.majorFirmwareVersion = byteArray[7]
                packet2.minorFirmwareVersion = byteArray[8]
                packet2.sensorFrequency = byteArray[9]
                packet2.numSensor = byteArray[10]
                packet2.curveFitFactor = byteArray[11]
                packet2.advertisingTimeout = byteArray[12]
                packet2.ledStatus = byteArray[13]
                packet2.serialNumber = byteUtils.getIntFromBytes(bytes: [byteArray[14], byteArray[15], byteArray[16], byteArray[17]])
                return packet2
                
                
            case 3:
                packet2.status = byteArray[2]
                packet2.pairingMode = byteArray[3]
                return packet2
                
            case 32:
                packet2.status = byteArray[2]
                packet2.voltageFactor = byteUtils.getShortFromByte(bytes: [byteArray[3], byteArray[4]])
                return packet2
                
            case 4:
                packet2.status = byteArray[2]
                packet2.sensorValue1 = byteUtils.getShortFromByte(bytes: [byteArray[3], byteArray[4]])
                packet2.sensorValue2 = byteUtils.getShortFromByte(bytes: [byteArray[5], byteArray[6]])
                packet2.sensorValue3 = byteUtils.getShortFromByte(bytes: [byteArray[7], byteArray[8]])
                packet2.sensorValue4 = byteUtils.getShortFromByte(bytes: [byteArray[9], byteArray[10]])
                return packet2
                
            case 16:
                packet2.status = byteArray[2]
                return packet2
                
            case 64:
                packet2.originalSyncTime = byteUtils.getIntFromBytes(bytes: [byteArray[1], byteArray[2], byteArray[3], byteArray[4]])
                packet2.deviceSyncTime = byteUtils.getIntFromBytes(bytes: [byteArray[5], byteArray[6], byteArray[7], byteArray[8]])
                packet2.sensorValue1 = byteUtils.getShortFromByte(bytes: [byteArray[9], byteArray[10]])
                packet2.sensorValue2 = byteUtils.getShortFromByte(bytes: [byteArray[11], byteArray[12]])
                packet2.sensorValue3 = byteUtils.getShortFromByte(bytes: [byteArray[13], byteArray[14]])
                packet2.sensorValue4 = byteUtils.getShortFromByte(bytes: [byteArray[15], byteArray[16]])
                packet2.voltageFactor = byteUtils.getShortFromByte(bytes: [byteArray[17], byteArray[18]])
                return packet2
                
            case 5:
                packet2.status = byteArray[2]
                packet2.calibrationMode = byteArray[3]
                return packet2
            
            case 6:
                packet2.status = byteArray[2]
                return packet2
                
            default :
                return packet2
            }
            
        }
    }
    
}

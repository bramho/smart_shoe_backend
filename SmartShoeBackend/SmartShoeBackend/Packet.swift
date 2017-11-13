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
    
    
    func parseByteToPacket(array: [UInt8]) -> Packet {
        var packet = Packet()
        var byteArray = array;
        print(byteArray.count)
        if(byteArray.count != 20){
            return packet;
        } else {
            var b : Int = 0 // REMEMBER TO CAST THIS TO A UINT8 - IT'S A BYTE BUT WE CAN'T AUTO-OVERFLOW BYTES IN SWIFt
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
                b -= 255
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

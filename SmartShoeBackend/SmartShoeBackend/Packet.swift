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
    var sensorValue1 : CShort = 0
    var sensorValue2 : CShort = 0
    var sensorValue3 : CShort = 0
    var sensorValue4 : CShort = 0
    var serialNumber : Int = 0
    var shoeCategory : UInt8 = 0
    var shoeType : UInt8 = 0
    var status : UInt8 = 0
    var voltageFactor : CShort = 0
    
    
    func parseByteToPacket(array: [UInt8]) -> Packet {
        var packet = Packet()
        var byteArray = array;
        if(byteArray.count != 20){
            return packet;
        } else {
            var b : Int = 0 // REMEMBER TO CAST THIS TO A UINT8 - IT'S A BYTE BUT WE CAN'T AUTO-OVERFLOW BYTES IN SWIFt
            var i : Int = 0
            var n : Int = 0
            while (i < 19) {
                b += Int(byteArray[i])
                var b2 : UInt8 = byteArray[i]
                var n2 : Int = n + 1;
                byteArray[i] = b2 ^ CIPHER_CODES[n]
                n = n2
                if(n > 3) {
                    n = 0
                }
                i += 1
            }
            
            if(UInt8(b) != byteArray[19]){
                return packet
            }
            
            let packet2 = Packet()
            packet2.command = byteArray[0]
            packet2.verifiedPacket = true
            packet = packet2;
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
                return packet2;
                break
                
            case 3:
                packet2.status = byteArray[2]
                packet2.pairingMode = byteArray[3]
                break
                
            case 32:
                packet2.status = byteArray[2]
                break
                
            case 4:
                packet2.status(array[2])
                break
                
            default :
                return packet2;
            }
            
        }
    }
    
}

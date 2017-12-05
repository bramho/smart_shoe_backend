//
//  Connector.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 15/11/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

class Connector :
    NSObject,
    CBPeripheralDelegate {
    
    weak var delegate: ConnectorDelegate?
    
    let SERVICE_UUID = CBUUID.init(string: "058D0001-CA72-4C8B-8084-25E049936B31")
    let REQUEST_UUID = CBUUID.init(string: "058D0002-CA72-4C8B-8084-25E049936B31")
    let RESPONSE_UUID = CBUUID.init(string: "058D0003-CA72-4C8B-8084-25E049936B31")
    let DESCRIPTOR_UUID = CBUUID.init(string: "00002902-0000-1000-8000-00805f9b34fb")

    var device: CBPeripheral!
    var shoe: Shoe!
    
    var canSendCommand: Bool = true;
    
    var n4 = 0
    var n5 = 0
    
    var requestCharacteristic : CBCharacteristic!
    var deviceName : String!
    var shoeType : Int!
    
    init(newDevice: CBPeripheral, shoeType: Int) {
        super.init()
        device = newDevice
        
        self.shoeType = shoeType
        
        device.delegate = self
        device.discoverServices([SERVICE_UUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if(service.uuid == SERVICE_UUID) {
                peripheral.discoverCharacteristics([RESPONSE_UUID, REQUEST_UUID], for: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if(thisCharacteristic.uuid == REQUEST_UUID) {
                self.device.setNotifyValue(true, for: thisCharacteristic)
                requestCharacteristic = thisCharacteristic
            }
            
            if(thisCharacteristic.uuid == RESPONSE_UUID) {
                self.device.setNotifyValue(true, for: thisCharacteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        let data = characteristic.value
        let values = [UInt8](data!)
        
        let packet = Packet()
        
        if(data?.count == 20){
            let result = packet.parseByteToPacket(array: values)
            if(result.command == 4 || result.command == 64){
                if(canSendCommand){
                    shoe = Shoe.init(shoeType: shoeType, sensor1: Int(result.sensorValue1), sensor2: Int(result.sensorValue2), sensor3: Int(result.sensorValue3), sensor4: Int(result.sensorValue4))
                    canSendCommand = false
                    delegate?.connectorHasReceivedData(self, shoeData: shoe)
                } else {
                    shoe.setSensor1(sensor1: Int(result.sensorValue1))
                    shoe.setSensor2(sensor2: Int(result.sensorValue2))
                    shoe.setSensor3(sensor3: Int(result.sensorValue3))
                    shoe.setSensor4(sensor4: Int(result.sensorValue4))
                    delegate?.connectorHasReceivedData(self, shoeData: shoe)
                }
            }
            if(result.gameOver == 4) {
                canSendCommand = true
            }
        }
    }
    
    func requestCommand(n: Int) {
        let n2 : Int = 0
        let n3 : Int = 0
        let packet = Packet()
        
        switch(n) {
        case 1:
            n4 = 2
            n5 = 33
            break
        case 2:
            n4 = 4
            n5 = 1 //current time is set in packet class
            break
        case 3:
            n4 = 16
            n5 = n3
            break
        case 4:
            n4 = 32
            n5 = n3
            break
        case 5:
            n4 = 3
            n5 = 1
            break
        case 6:
            n4 = 3
            n5 = 2
            break
        case 7:
            n4 = 5
            n5 = 1
            break
        case 8:
            print(device.state.rawValue)
            let generateRequest : [UInt8] = packet.generateRequest(requestType: n4, requestValue: n5, shoeType: self.shoeType)
            if requestCharacteristic.uuid == REQUEST_UUID {
                if(generateRequest.count < 20) {
                    let reqData = NSData(bytes: generateRequest, length: generateRequest.count * MemoryLayout<UInt8>.size)
                    device.writeValue(reqData as Data, for: requestCharacteristic, type: CBCharacteristicWriteType.withResponse)
                } else {
                    var dataPackets : [[UInt8]] = generateRequest.chunk(20)
                    
                    for i in 0 ..< dataPackets.count {
                        let dataPacket = dataPackets[i]
                        
                        let reqData = NSData(bytes: dataPacket, length: dataPacket.count * MemoryLayout<UInt8>.size)
                        device.writeValue(reqData as Data, for: requestCharacteristic, type: CBCharacteristicWriteType.withResponse)
                    }
                    
                    
                }
            }
            break
        case 9:
            n4 = 6
            n5 = 2
            break
        case 10:
            n4 = 6
            n5 = 1
            break
        case 11:
            n4 = 69
            n5 = 1
            break
        default:
            n5 = n3
            n4 = n2
            break
        }
    }
}

extension Array {
    func chunk(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map({
            (startIndex) -> [Element] in let endIndex = (startIndex.advanced(by: chunkSize) > self.count) ? self.count-startIndex : chunkSize
            return Array(self[startIndex..<startIndex.advanced(by: endIndex)])
        })
    }
}

protocol ConnectorDelegate: class {
    func connectorHasReceivedData(_ connector: Connector?, shoeData: Shoe)
}

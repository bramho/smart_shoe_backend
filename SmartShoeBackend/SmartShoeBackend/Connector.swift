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
        
    /**
       Connector that links to each of the shoes for use in the applications.
    */
    
    weak var delegate: ConnectorDelegate?
    
    let SERVICE_UUID = CBUUID.init(string: "058D0001-CA72-4C8B-8084-25E049936B31")
    let REQUEST_UUID = CBUUID.init(string: "058D0002-CA72-4C8B-8084-25E049936B31")
    let RESPONSE_UUID = CBUUID.init(string: "058D0003-CA72-4C8B-8084-25E049936B31")
    let DESCRIPTOR_UUID = CBUUID.init(string: "00002902-0000-1000-8000-00805f9b34fb")

    var device: CBPeripheral!
    var shoe: Shoe!
    
    var canSendCommand: Bool = true;
    
    var requestNumber = 0 
    var requestValue = 0
    
    var requestCharacteristic : CBCharacteristic!
    var deviceName : String!
    var shoeType : Int!
    
    init(newDevice: CBPeripheral, shoeType: Int) {
        /**
            Initialize a new instance of the Connector Class
        
            *Values*
        
            `newDevice` A CBPeripheral object that is connected to and shall be used internally.
        
            `shoeType` An identifier for the type of shoe, left or right. (1 or 2)
        */
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
                    
                    StateManager.instance.setCurrentState(StateManager.States.activated)
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
                StateManager.instance.setCurrentState(StateManager.States.completed)
            }
        }
        
        if(error != nil) {
            StateManager.instance.setCurrentState(StateManager.States.errorThree)
        }
    }
    
    func requestCommand(n: Int) {
        /**
            Set or request a command based on the input.
        
            *values*
        
            `n` The command requested. The default for performing a requesting the command is 8. 
        */
        let n2 : Int = 0
        let n3 : Int = 0
        let packet = Packet()
        
        switch(n) {
        case 1:
            requestNumber = 2
            requestValue = 33
            break
        case 2:
            requestNumber = 4
            requestValue = 1 //current time is set in packet class
            break
        case 3:
            requestNumber = 16
            requestValue = n3
            break
        case 4:
            requestNumber = 32
            requestValue = n3
            break
        case 5:
            requestNumber = 3
            requestValue = 1
            break
        case 6:
            requestNumber = 3
            requestValue = 2
            break
        case 7:
            requestNumber = 5
            requestValue = 1
            break
        case 8:
            print(device.state.rawValue)
            let generateRequest : [UInt8] = packet.generateRequest(requestType: requestNumber, requestValue: requestValue, shoeType: self.shoeType)
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
            requestNumber = 6
            requestValue = 2
            break
        case 10:
            requestNumber = 6
            requestValue = 1
            break
        case 11:
            requestNumber = 69
            requestValue = 1
            break
        default:
            requestValue = n3
            requestNumber = n2
            break
        }
    }
}

extension Array {
    func chunk(_ chunkSize: Int) -> [[Element]] {
        /**
            Chunk an array into equal pieces
        */
        return stride(from: 0, to: self.count, by: chunkSize).map({
            (startIndex) -> [Element] in let endIndex = (startIndex.advanced(by: chunkSize) > self.count) ? self.count-startIndex : chunkSize
            return Array(self[startIndex..<startIndex.advanced(by: endIndex)])
        })
    }
}

protocol ConnectorDelegate: class {
    func connectorHasReceivedData(_ connector: Connector?, shoeData: Shoe)
}

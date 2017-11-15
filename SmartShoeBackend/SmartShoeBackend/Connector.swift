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
    CBCentralManagerDelegate,
    CBPeripheralDelegate {
    
    let SERVICE_UUID = CBUUID.init(string: "058D0001-CA72-4C8B-8084-25E049936B31")
    let REQUEST_UUID = CBUUID.init(string: "058D0002-CA72-4C8B-8084-25E049936B31")
    let RESPONSE_UUID = CBUUID.init(string: "058D0003-CA72-4C8B-8084-25E049936B31")
    let DESCRIPTOR_UUID = CBUUID.init(string: "00002902-0000-1000-8000-00805f9b34fb")
    let REQUEST_CANCEL_CALIBRATION_MODE = 8;
    let REQUEST_CHECK_CAPABILITY = 1;
    let REQUEST_CHECK_STATUS = 4;
    let REQUEST_PAIRING_MODE_OFF = 6;
    let REQUEST_PAIRING_MODE_ON = 5;
    let REQUEST_SET_SYNC_TIME = 2;
    let REQUEST_START_CALIBRATION_MODE = 7;
    let REQUEST_STOP_DATA_TRANSFER = 3;
    let WAITING_DELAY = 1000
    var manager : CBCentralManager!
    var device: CBPeripheral!
    
    var requestCharacteristic : CBCharacteristic!
    var deviceName : String!
    
    init(newDevice: String) {
        super.init()
        deviceName = newDevice
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth not available")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let deviceData = (advertisementData as NSDictionary)
        .object(forKey: (CBAdvertisementDataLocalNameKey)) as? NSString
        
        if deviceData?.contains(deviceName) == true {
            self.device = peripheral
            self.device.delegate = self
            
            print(" Connected with Shoe: " + deviceName)
            
            manager.connect(peripheral, options: nil)
            
            manager.stopScan()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid == SERVICE_UUID {
                peripheral.discoverCharacteristics([RESPONSE_UUID, REQUEST_UUID], for: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == REQUEST_UUID {
                self.device.setNotifyValue(true, for: thisCharacteristic)
                requestCharacteristic = thisCharacteristic
            }
            
            if thisCharacteristic.uuid == RESPONSE_UUID {
                self.device.setNotifyValue(true, for: thisCharacteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        let data = characteristic.value
        
        print(data!)
        
        let values = [UInt8](data!)
        
        let packet = Packet()
        
        if(data?.count == 20){
            let result = packet.parseByteToPacket(array: values)
            print(result)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
        print(error)
        if(characteristic.uuid == REQUEST_UUID) {
            print(peripheral.readValue(for: characteristic))
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func requestCommand(n: Int) {
        let n2 : Int = 0
        let n3 : Int = 0
        var n4 = n2
        var n5 = n3
        let packet = Packet()
        
        switch(n) {
        case 1:
            n4 = 2
            n5 = 33
            break
        case 2:
            n4 = 4
            n5 = 1//current time
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
            let generateRequest : [UInt8] = packet.generateRequest(requestType: n4, requestValue: n5, shoeType: 1)
            if requestCharacteristic.uuid == REQUEST_UUID {
                let reqData = NSData(bytes: generateRequest, length: generateRequest.count * MemoryLayout<UInt8>.size)
                device.writeValue(reqData as Data, for: requestCharacteristic, type: CBCharacteristicWriteType.withResponse)
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
        default:
            n5 = n3
            n4 = n2
            break
        }
    }
}

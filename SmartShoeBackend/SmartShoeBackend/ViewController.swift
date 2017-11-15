//
//  ViewController.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 20/09/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController:
    UIViewController,
    CBCentralManagerDelegate,
    CBPeripheralDelegate {
    
    ///Mark properties:
    
    var manager: CBCentralManager!
    var leftShoe: CBPeripheral!
    var rightShoe: CBPeripheral!
    
    let leftShoeName = "IOFIT_Left"
    let rightShoeName = "IOFIT_Right"
    
    let SERVICE_UUID = CBUUID.init(string: "058D0001-CA72-4C8B-8084-25E049936B31")
    let REQUEST_UUID = CBUUID.init(string: "058D0002-CA72-4C8B-8084-25E049936B31")
    let RESPONSE_UUID = CBUUID.init(string: "058D0003-CA72-4C8B-8084-25E049936B31")
    let DESCRIPTOR_UUID = CBUUID.init(string: "00002902-0000-1000-8000-00805f9b34fb")
    
    var leftShoeVerified = false
    var rightShoeVerified = false
    
    var leftShoeCharacteristic : CBCharacteristic!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
        .object(forKey: (CBAdvertisementDataLocalNameKey)) as? NSString
        
        if device?.contains(leftShoeName) == true {
            self.leftShoe = peripheral
            
            self.leftShoe.delegate = self
            
            self.leftShoeVerified = true
            
            print(" Connected with left shoe: " + (device! as String))
            
            manager.connect(peripheral, options: nil)
        } else if device?.contains(rightShoeName) == true {
            self.rightShoe = peripheral
            
            self.rightShoe.delegate = self
            
            self.rightShoeVerified = true
            
            print(" Connected with right shoe: " + (device! as String))
            
            manager.connect(peripheral, options: nil)
        }
        
        if leftShoeVerified && rightShoeVerified {
            manager.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil);
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if (peripheral.name?.contains(leftShoeName))! {
                let thisService = service as CBService
                
                if service.uuid == SERVICE_UUID {
                    peripheral.discoverCharacteristics([RESPONSE_UUID, REQUEST_UUID], for: thisService)
                }
            }
            
            if(peripheral.name?.contains(rightShoeName))! {
                let thisService = service as CBService
                
                if service.uuid == SERVICE_UUID {
                    peripheral.discoverCharacteristics([RESPONSE_UUID, REQUEST_UUID], for: thisService)
                }
            }
            
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            let packet = Packet()
            
            if thisCharacteristic.uuid == REQUEST_UUID {
                if(peripheral.name?.contains(leftShoeName))! {
                    self.leftShoe.setNotifyValue(true, for: thisCharacteristic)
                    
                    leftShoeCharacteristic = thisCharacteristic
                    
                    requestCommand(n: 1)
                    
                    requestCommand(n: 8)
//                    let request = packet.generateRequest(requestType: 32, requestValue: 0, shoeType: 1)
//                    let request : [UInt8] = []
//
//                    let reqData = NSData(bytes: request, length: request.count * MemoryLayout<UInt8>.size)
//                    print(reqData)
//                    peripheral.writeValue(reqData as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    
                } else if (peripheral.name?.contains(rightShoeName))! {
                    self.rightShoe.setNotifyValue(true, for: thisCharacteristic)
                    
//                    let request = packet.generateRequest(requestType: 32, requestValue: 0, shoeType: 2)
//                    let request : [UInt8] = []
//                    let reqData = NSData(bytes: request, length: request.count * MemoryLayout<UInt8>.size)
//                    print(reqData)
//                    peripheral.writeValue(reqData as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    
                    
                }
            }
            
            if(thisCharacteristic.uuid == RESPONSE_UUID) {
                if(peripheral.name?.contains(leftShoeName))! {
                    self.leftShoe.setNotifyValue(true, for: thisCharacteristic)
                    self.leftShoe.discoverDescriptors(for: thisCharacteristic)
                } else if (peripheral.name?.contains(rightShoeName))! {
                    self.rightShoe.setNotifyValue(true, for: thisCharacteristic)
                    self.rightShoe.discoverDescriptors(for: thisCharacteristic)
                }
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        /// TODO: Set Value of Descriptor to ENABLE_NOTIFICATION_VALUE
        
        let descriptors : [CBDescriptor]? = characteristic.descriptors;
        
        if(descriptors?.count != 0) {
            for descriptor in descriptors! {
              
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        
        let data = characteristic.value
        
        print(data)
        
        let values = [UInt8](data!)
        
        let packet = Packet()
        
        if(data?.count == 20) {
            var result = packet.parseByteToPacket(array: values)
            print(result)
        }

        //reverseCypher(cypher: values[0], outcome: values[1])
        
        
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
    
    
    
    func reverseCypher(cypher: UInt8, outcome: UInt8) -> Int {
        var bitOutcome = String(outcome, radix: 2)
        var bitCypher = String(cypher, radix: 2)
        var bitResult = ""
        for _ in 0...cypher.leadingZeroBitCount {
            bitCypher = "0" + bitCypher
        }
        
        for _ in 0...outcome.leadingZeroBitCount {
            bitOutcome = "0" + bitOutcome
        }
        
        for i in 0..<bitCypher.count {
            let indexOutcome = bitOutcome.index(bitOutcome.startIndex, offsetBy: i)
            let indexCypher = bitCypher.index(bitCypher.startIndex, offsetBy: i)
            if(String(bitOutcome[indexOutcome]) == "0") {
                bitResult += String(bitCypher[indexCypher])
            } else {
                if(String(bitCypher[indexCypher]) == "0") {
                    bitResult += "1"
                } else {
                    bitResult += "0"
                }
            }
        }
        
        return Int(bitResult, radix: 10)!
    }
}


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
                
                if service.uuid == RESPONSE_UUID {
                    peripheral.discoverCharacteristics(nil, for: thisService)
                }
                
                if service.uuid == REQUEST_UUID {
                    peripheral.discoverCharacteristics(nil, for: thisService)
                }
                
                if service.uuid == SERVICE_UUID {
                    peripheral.discoverCharacteristics([RESPONSE_UUID, REQUEST_UUID], for: thisService)
                }
            }
            
            if(peripheral.name?.contains(rightShoeName))! {
                let thisService = service as CBService
                
                if service.uuid == RESPONSE_UUID {
                    peripheral.discoverCharacteristics(nil, for: thisService)
                }
                
                if service.uuid == REQUEST_UUID {
                    peripheral.discoverCharacteristics(nil, for: thisService)
                }
                
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
            
            if thisCharacteristic.uuid == REQUEST_UUID {
                if(peripheral.name?.contains(leftShoeName))! {
                    self.leftShoe.setNotifyValue(true, for: thisCharacteristic)
                    
//                    var a = [119, 96, 108, 116, 115, 97, 108, 116, 267]
//                    var arr = [UInt8](repeating: 0x01, count: 9)
//                    for i in 0...(a.count - 1){
//                        arr[i] = UInt8(a[i]);
//                    }
//
//                    let data = Data(bytes: arr)
//
//                    self.leftShoe.writeValue(data,
//                                             for: thisCharacteristic,
//                                             type: CBCharacteristicWriteType.withResponse)
                }
                
//                if(peripheral.name?.contains(rightShoeName))! {
//                    self.rightShoe.setNotifyValue(true, for: thisCharacteristic)
//
//                    print(thisCharacteristic)
//
//                    var b = [2, 66, 0, 16, 0, 12, 0, 4, 0, 82, 14, 0, 0, 119, 96, 7, 220, 142, 244, 108,  28]
//                    var brr = [UInt8](repeating: 0x01, count: 21)
//                    for i in 0...(b.count - 1){
//                        brr[i] = UInt8(b[i]);
//                    }
//
//                    let dataB = Data(bytes: brr)
//
//                    self.rightShoe.writeValue(dataB,
//                                              for:thisCharacteristic,
//                                              type: CBCharacteristicWriteType.withResponse)
//                }
            }
            
            if(thisCharacteristic.uuid == RESPONSE_UUID) {
                if(peripheral.name?.contains(leftShoeName))! {
                    let descriptors: [CBDescriptor]? = thisCharacteristic.descriptors;
                    if(descriptors != nil) {
                        for descriptor in descriptors! {
                            if descriptor.uuid == DESCRIPTOR_UUID {
                                print(descriptor)
                                print(descriptor.description)
                            }
                        }
                    }
                    self.leftShoe.setNotifyValue(true, for: thisCharacteristic)
                    self.leftShoe.discoverDescriptors(for: thisCharacteristic)
                } else if (peripheral.name?.contains(rightShoeName))! {
                    let descriptors: [CBDescriptor]? = thisCharacteristic.descriptors;
                    if(descriptors != nil) {
                        for descriptor in descriptors! {
                            if descriptor.uuid == DESCRIPTOR_UUID {
                                print(descriptor)
                                print(descriptor.description)
                            }
                        }
                    }
                    
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
                print(descriptor)
                print(descriptor.uuid)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        
        let data = characteristic.value
        
        let values = [UInt8](data!)
        //reverseCypher(cypher: values[0], outcome: values[1])
        let request = generateRequest()
        print(request)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
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
    
    func generateRequest() -> [UInt8] {
        var n : Int = 119 + 96
        let currentTime : UInt32 = UInt32(NSDate().timeIntervalSince1970)
        let byteArray: [UInt8] = getByteArray(m: currentTime)
        let b3 : UInt8 = byteArray[0] ^ 0x6c
        let b4 : UInt8 = byteArray[1] ^ 0x74
        let b5 : UInt8 = byteArray[2] ^ 0x73
        let b6 : UInt8 = byteArray[3] ^ 0x61
        print (b3, b4, b5, b6)
        
        n = (((n + Int(b6)) + 108) + 116)
        
        while(n > 255) {
            n -= 256;
        }
        
        let c : [UInt8] = [119, 96, b3, b4, b5, b6, 108, 116, UInt8(n)]
        
        return c
    }
    
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
    
    func parseBytesToPacket(array: [UInt8]) {
        
    }
    
    



}


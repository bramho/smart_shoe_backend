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
    
    @IBOutlet weak var log: UITextView!
    
    var manager: CBCentralManager!
    var leftShoe: CBPeripheral!
    var rightShoe: CBPeripheral!
    
    let leftShoeName = "IOFIT_Left"
    let rightShoeName = "IOFIT_Right"
    
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
            log.insertText("Bluetooth not available.")
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
            
            log.insertText(" Connected with left shoe: " + (device! as String))
            
            manager.connect(peripheral, options: nil)
        } else if device?.contains(rightShoeName) == true {
            self.rightShoe = peripheral
            
            self.rightShoe.delegate = self
            
            self.rightShoeVerified = true
            
            log.insertText(" Connected with right shoe: " + (device! as String))
            
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
            let thisService = service as CBService
            
            if thisService.includedServices != nil {
                for secondaryService in thisService.includedServices! {
                    let thisSecondaryService = secondaryService as CBService
                    
                    log.insertText("Secondary Service discovered: " + thisSecondaryService.description)
                    
                    peripheral.discoverCharacteristics(nil, for: thisSecondaryService)
                }
            }
            
            log.insertText("Service discovered: " + thisService.description)
            peripheral.discoverCharacteristics(nil, for: thisService)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            log.insertText("Characteristic discovered: "  + thisCharacteristic.description)
            self.leftShoe.setNotifyValue(true, for: thisCharacteristic)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        let data = characteristic.value
        let values = [UInt8](data!)
        
        print(values)
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    
    


}


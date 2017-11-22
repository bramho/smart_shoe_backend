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
    CBCentralManagerDelegate{
    
    ///Mark properties:
    var manager: CBCentralManager!
    var leftShoe: Connector!
    var rightShoe: Connector!
    var leftShoePeripheral: CBPeripheral!
    var rightShoePeripheral: CBPeripheral!
    
    
    let leftShoeName = "IOFIT_Left"
    let rightShoeName = "IOFIT_Right"
    
    var leftShoeVerify = false;
    var rightShoeVerify = false;
    
    let SERVICE_UUID = CBUUID.init(string: "058D0001-CA72-4C8B-8084-25E049936B31")
    let REQUEST_UUID = CBUUID.init(string: "058D0002-CA72-4C8B-8084-25E049936B31")
    let RESPONSE_UUID = CBUUID.init(string: "058D0003-CA72-4C8B-8084-25E049936B31")
    let DESCRIPTOR_UUID = CBUUID.init(string: "00002902-0000-1000-8000-00805f9b34fb")
    
    var keepRequesting : Bool = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func VerifyButton(_ sender: Any) {
        leftShoe.requestCommand(n: 1)
        rightShoe.requestCommand(n: 1)
    }
    
    @IBAction func Initiate(_ sender: Any) {
        leftShoe.requestCommand(n: 11)
        rightShoe.requestCommand(n: 11)
    }
    
    @IBAction func ActivateButton(_ sender: Any) {
        leftShoe.requestCommand(n: 2)
        rightShoe.requestCommand(n: 2)
    }
    
    @IBAction func SendCommandButton(_ sender: Any) {
        leftShoe.requestCommand(n: 8)
        rightShoe.requestCommand(n: 8)
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
        
        if deviceData?.contains(leftShoeName) == true  && !leftShoeVerify{
            manager.connect(peripheral, options: nil)
            
            leftShoePeripheral = peripheral
            print(" connected with " + leftShoeName)
            leftShoeVerify = true
            
        } else if deviceData?.contains(rightShoeName) == true && !rightShoeVerify {
            manager.connect(peripheral, options: nil)

            rightShoePeripheral = peripheral
            print(" connected with " + rightShoeName)
            rightShoeVerify = true
        }
        
        if leftShoeVerify && rightShoeVerify {
            manager.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if(peripheral.name == leftShoeName) {
            leftShoe = Connector(newDevice: leftShoePeripheral, shoeType: 1)
        } else if (peripheral.name == rightShoeName) {
            rightShoe = Connector(newDevice: rightShoePeripheral, shoeType: 2)
        }
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print("encountered problem and forced disconnect")
        print(error)
        if (peripheral.name?.contains(leftShoeName))! {
            leftShoeVerify = false
        } else if (peripheral.name?.contains(rightShoeName))! {
            rightShoeVerify = false
        }
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


//
//  ShoeManager.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 30/11/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation
import CoreBluetooth

class ShoeManager : NSObject, CBCentralManagerDelegate, ConnectorDelegate {

    weak var delegate: ShoeManagerDelegate?
    
    var manager: CBCentralManager!
    var leftShoe: Connector!
    var rightShoe: Connector!
    var leftShoePeripheral: CBPeripheral!
    var rightShoePeripheral: CBPeripheral!
    
    let leftShoeName = "IOFIT_Left"
    let rightShoeName = "IOFIT_Right"
    
    var leftShoeVerify = false;
    var rightShoeVerify = false;
    
//     let SERVICE_UUID = CBUUID.init(string: "058D0001-CA72-4C8B-8084-25E049936B31")
//     let REQUEST_UUID = CBUUID.init(string: "058D0002-CA72-4C8B-8084-25E049936B31")
//     let RESPONSE_UUID = CBUUID.init(string: "058D0003-CA72-4C8B-8084-25E049936B31")
//     let DESCRIPTOR_UUID = CBUUID.init(string: "00002902-0000-1000-8000-00805f9b34fb")
    
    var keepRequesting : Bool = false;
    
    var timer : Timer?
    
    override init(){
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startConnectionSession() {
        leftShoe.requestCommand(n: 11)
        rightShoe.requestCommand(n: 11)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.leftShoe.requestCommand(n: 8)
            self.rightShoe.requestCommand(n: 8)
            
            self.leftShoe.requestCommand(n: 1)
            self.rightShoe.requestCommand(n: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self.leftShoe.requestCommand(n: 8)
                self.rightShoe.requestCommand(n: 8)
                
                self.leftShoe.requestCommand(n: 2)
                self.rightShoe.requestCommand(n: 2)
                
                if self.timer == nil {
                    self.timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector:#selector(self.execute), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    @objc func execute(){
        if(self.leftShoe.canSendCommand && self.rightShoe.canSendCommand) {
            self.leftShoe.requestCommand(n: 8)
            self.rightShoe.requestCommand(n: 8)
        }
    }
    
    func stopConnectionSession() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
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
        let deviceData = (advertisementData as NSDictionary).object(forKey: (CBAdvertisementDataLocalNameKey)) as? NSString
        
        if(deviceData?.contains(leftShoeName) == true  && !leftShoeVerify) {
            manager.connect(peripheral, options: nil)
            
            leftShoePeripheral = peripheral
            print("connected with " + leftShoeName)
            leftShoeVerify = true
            
        } else if(deviceData?.contains(rightShoeName) == true && !rightShoeVerify) {
            manager.connect(peripheral, options: nil)
            
            rightShoePeripheral = peripheral
            print("connected with " + rightShoeName)
            rightShoeVerify = true
        }
        
        if(leftShoeVerify && rightShoeVerify) {
            manager.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if(peripheral.name == leftShoeName) {
            leftShoe = Connector(newDevice: leftShoePeripheral, shoeType: 1)
            leftShoe.delegate = self
        } else if(peripheral.name == rightShoeName) {
            rightShoe = Connector(newDevice: rightShoePeripheral, shoeType: 2)
            rightShoe.delegate = self
        }
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print("encountered problem and forced disconnect")
        print(error as Any)
        if(peripheral.name?.contains(leftShoeName))! {
            leftShoeVerify = false
        } else if(peripheral.name?.contains(rightShoeName))! {
            rightShoeVerify = false
        }
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func connectorHasReceivedData(_ connector: Connector?, shoeData: Shoe) {
        delegate?.sensorDataReceivedFromShoe(shoeData)
    }
}

protocol ShoeManagerDelegate: class {
    func sensorDataReceivedFromShoe(_ data: Shoe)
}

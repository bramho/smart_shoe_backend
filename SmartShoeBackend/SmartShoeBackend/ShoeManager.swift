//
//  ShoeManager.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 30/11/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation
import CoreBluetooth

class ShoeManager : NSObject, CBCentralManagerDelegate, ConnectorDelegate, StateManagerDelegate {
    
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
    
    var keepRequesting : Bool = false;
    
    var timer : Timer?
    var interval: Double = 0.4
    var maxTime: Double = 60.0
    var timeTaken: Double = 0.0
    
    override init(){
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
        StateManager.instance.delegate = self
    }
    
    func startConnectionSession() {
        StateManager.instance.setCurrentState(StateManager.States.starting)
        leftShoe.requestCommand(n: 11)
        rightShoe.requestCommand(n: 11)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            StateManager.instance.setCurrentState(StateManager.States.initialized)
            self.leftShoe.requestCommand(n: 8)
            self.rightShoe.requestCommand(n: 8)
            
            self.leftShoe.requestCommand(n: 1)
            self.rightShoe.requestCommand(n: 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                StateManager.instance.setCurrentState(StateManager.States.verified)
                self.leftShoe.requestCommand(n: 8)
                self.rightShoe.requestCommand(n: 8)
                
                self.leftShoe.requestCommand(n: 2)
                self.rightShoe.requestCommand(n: 2)
                StateManager.instance.setCurrentState(StateManager.States.activating)
                
                if self.timer == nil {
                    self.timer = Timer.scheduledTimer(timeInterval: self.interval, target: self, selector:#selector(self.execute), userInfo: nil,  repeats: true)
                }
            }
        }
    }
    
    @objc func execute(){
        if(self.leftShoe.canSendCommand && self.rightShoe.canSendCommand) {
            // TODO: Find a maximum time of activation to throw error two in
            timeTaken += interval
            if(timeTaken > maxTime) {
                StateManager.instance.setCurrentState(StateManager.States.errorTwo)
                stopConnectionSession()
                timeTaken = 0
                startConnectionSession()
            }
            
            self.leftShoe.requestCommand(n: 8)
            self.rightShoe.requestCommand(n: 8)
        }
    }
    
    func stopConnectionSession() {
        if self.timer != nil {
            StateManager.instance.setCurrentState(StateManager.States.stopped)
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
            
            StateManager.instance.setCurrentState(StateManager.States.connecting)
            
            leftShoePeripheral = peripheral
            print("connected with " + leftShoeName)
            leftShoeVerify = true
            
        } else if(deviceData?.contains(rightShoeName) == true && !rightShoeVerify) {
            manager.connect(peripheral, options: nil)
            
            StateManager.instance.setCurrentState(StateManager.States.connecting)
            
            rightShoePeripheral = peripheral
            print("connected with " + rightShoeName)
            rightShoeVerify = true
        }
        
        if(leftShoeVerify && rightShoeVerify) {
            StateManager.instance.setCurrentState(StateManager.States.connected)
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
        StateManager.instance.setCurrentState(StateManager.States.disconnected)
        
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
    
    func stateUpdated(_ state: Int, _ error: String?) {
        if(error != nil) {
            print(error ?? "")
        }
        print(state)
    }
}

protocol ShoeManagerDelegate: class {
    func sensorDataReceivedFromShoe(_ data: Shoe)
}

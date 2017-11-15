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
    UIViewController {
    
    ///Mark properties:
    var leftShoe: Connector!
    var rightShoe: Connector!
    
    let leftShoeName = "IOFIT_Left"
    let rightShoeName = "IOFIT_Right"
    
    let SERVICE_UUID = CBUUID.init(string: "058D0001-CA72-4C8B-8084-25E049936B31")
    let REQUEST_UUID = CBUUID.init(string: "058D0002-CA72-4C8B-8084-25E049936B31")
    let RESPONSE_UUID = CBUUID.init(string: "058D0003-CA72-4C8B-8084-25E049936B31")
    let DESCRIPTOR_UUID = CBUUID.init(string: "00002902-0000-1000-8000-00805f9b34fb")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftShoe = Connector(newDevice: leftShoeName)
        rightShoe = Connector(newDevice: rightShoeName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


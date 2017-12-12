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
    ShoeManagerDelegate {
    
    var shoeManager : ShoeManager!
    ///Mark properties:

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shoeManager = ShoeManager.init()
        shoeManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sensorDataReceivedFromShoe(_ data: Shoe) {
        print(data.getSensors())
    }
    
    @IBAction func stopSession(_ sender: Any){
        shoeManager.stopConnectionSession()
    }
    @IBAction func startSession(_ sender: Any) {
        shoeManager.startConnectionSession()
    }
}


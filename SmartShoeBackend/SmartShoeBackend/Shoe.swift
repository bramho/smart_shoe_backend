//
//  Shoe.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 29/11/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation

class Shoe {
    var shoeType : Int
    var sensor1 : Double
    var sensor2 : Double
    var sensor3 : Double
    var sensor4 : Double
    
    init(shoeType: Int, sensor1: Int, sensor2: Int, sensor3: Int, sensor4: Int) {
        self.shoeType = shoeType
        self.sensor1 = Double(sensor1)
        self.sensor2 = Double(sensor2)
        self.sensor3 = Double(sensor3)
        self.sensor4 = Double(sensor4)
    }
    
    func getShoeType() -> Int {
        return shoeType
    }
    
    func setShoeType(shoeType: Int) {
        self.shoeType = shoeType
    }
    
    func getSensor1() -> Double {
        return sensor1
    }
    
    func setSensor1(sensor1: Int) {
        self.sensor1 = Double(sensor1)
    }
    
    func getSensor2() -> Double {
        return sensor2
    }
    
    func setSensor2(sensor2: Int) {
        self.sensor2 = Double(sensor2)
    }
    
    func getSensor3() -> Double {
        return sensor3
    }
    
    func setSensor3(sensor3: Int) {
        self.sensor3 = Double(sensor3)
    }
    
    func getSensor4() -> Double {
        return sensor4
    }
    
    func setSensor4(sensor4: Int) {
        self.sensor4 = Double(sensor4)
    }
    
    func getSensors() -> [Double] {
        return [sensor1, sensor2, sensor3, sensor4]
    }
    
    func getShoe(maxValue: Int) -> Shoe {
        setSensor1(sensor1: Int(convertSensor(sensor: getSensor1(), maxValue: maxValue)))
        setSensor2(sensor2: Int(convertSensor(sensor: getSensor2(), maxValue: maxValue)))
        setSensor3(sensor3: Int(convertSensor(sensor: getSensor3(), maxValue: maxValue)))
        setSensor4(sensor4: Int(convertSensor(sensor: getSensor4(), maxValue: maxValue)))
        return self
    }
    
    func convertSensor(sensor: Double, maxValue: Int) -> Double {
        return sensor / Double(maxValue)
    }
}

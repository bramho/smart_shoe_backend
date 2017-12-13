//
//  Shoe.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 29/11/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation

class Shoe {
    /**
        Shoe data structure to hold the data from the pressure sensors in the shoe.
    */
    var shoeType : Int
    var sensor1 : Double
    var sensor2 : Double
    var sensor3 : Double
    var sensor4 : Double
    
    init(shoeType: Int, sensor1: Int, sensor2: Int, sensor3: Int, sensor4: Int) {
        /**
            Initialize a new instance of the Shoe Class.
        
            *Values*
            
            `shoeType` Determines which shoe the data is from. 1 is left, 2 is right
        
            `sensor1` First Sensor of the shoe
        
            `sensor2` Second Sensor of the shoe
        
            `sensor3` Third Sensor of the shoe

            `sensor4` Fourth Sensor of the shoe
        */
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
    
    public func getShoe(maxValue: Int) -> Shoe {
        /**
            Get the Shoe with the sensor values normalized to values between 0 and 1.
        
            *Values*
        
            `maxValue` Maximum Value to normalize the values of the sensors on
        */
        self.sensor1 = convertSensor(sensor: getSensor1(), maxValue: maxValue)
        self.sensor2 = convertSensor(sensor: getSensor2(), maxValue: maxValue)
        self.sensor3 = convertSensor(sensor: getSensor3(), maxValue: maxValue)
        self.sensor4 = convertSensor(sensor: getSensor4(), maxValue: maxValue)
        return self
    }
    
    func convertSensor(sensor: Double, maxValue: Int) -> Double {
        /**
            Convert Sensor Value to a normalized value.
        
            *Values*
        
            `sensor` Sensor value to be converted
        
            `maxValue` Value to divide by
        */
        return sensor / Double(maxValue)
    }
}

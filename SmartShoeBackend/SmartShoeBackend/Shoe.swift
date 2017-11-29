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
    var sensor1 : Int
    var sensor2 : Int
    var sensor3 : Int
    var sensor4 : Int
    
    init(shoeType: Int, sensor1: Int, sensor2: Int, sensor3: Int, sensor4: Int) {
        self.shoeType = shoeType
        self.sensor1 = sensor1
        self.sensor2 = sensor2
        self.sensor3 = sensor3
        self.sensor4 = sensor4
    }
    
    func getShoeType() -> Int {
        return shoeType
    }
    
    func setShoeType(shoeType: Int) {
        self.shoeType = shoeType
    }
    
    func getSensor1() -> Int {
        return sensor1
    }
    
    func setSensor1(sensor1: Int) {
        self.sensor1 = sensor1
    }
    
    func getSensor2() -> Int {
        return sensor2
    }
    
    func setSensor2(sensor2: Int) {
        self.sensor2 = sensor2
    }
    
    func getSensor3() -> Int {
        return sensor3
    }
    
    func setSensor3(sensor3: Int) {
        self.sensor3 = sensor3
    }
    
    func getSensor4() -> Int {
        return sensor4
    }
    
    func setSensor4(sensor4: Int) {
        self.sensor4 = sensor4
    }
    
    func getShoe() -> Shoe {
        return self
    }
}

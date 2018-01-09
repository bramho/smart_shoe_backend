//
//  StateManager.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 06/12/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation

class StateManager {
    /**
        Internal StateManager for the BackEnd to track its state.
    
        This uses a Singleton pattern, use StateManager.instance to call functionality or variables. 
    */
    static let instance = StateManager()
    
    weak var delegate: StateManagerDelegate!
    var currentState : States = States.base
    
    enum States: Int {
        /**
            States that are integrated into the application.
        */
        case connecting = 0
        case connected = 1
        case starting = 2
        case initialized = 3
        case verified = 4
        case activating = 5
        case activated = 6
        case completed = 7
        case idle = 8
        case disconnected = 9
        case stopped = 10
        
        case base = 90
        case errorOne = 21
        case errorTwo = 22
        case errorThree = 23
    }
    
    func getCurrentState() -> States {
        /**
            Retrieve the current state of the BackEnd
        */
        return currentState
    }
    
    func setCurrentState(_ value: States) {
        /**
            Sets the current state of the Backend.
        
            *Values*   
        
            `value` State to set.
        */
        currentState = value
        
        switch(value){
        case .errorOne:
            let errorMessage : String = " Error 1: "
            if(delegate != nil){
                delegate.stateUpdated(currentState.rawValue, errorMessage)
            }
            break
        case .errorTwo:
            let errorMessage : String = " Error 2: "
            if(delegate != nil){
                delegate.stateUpdated(currentState.rawValue, errorMessage)
            }
            break
        case .errorThree:
            let errorMessage : String = " Error 3: "
            if(delegate != nil){
                delegate.stateUpdated(currentState.rawValue, errorMessage)
            }
            break
            
        default:
            if(delegate != nil){
                delegate.stateUpdated(currentState.rawValue, nil)
            }
            break;
        }
    }
}

protocol StateManagerDelegate: class {
    func stateUpdated(_ state: Int, _ error: String?)
}

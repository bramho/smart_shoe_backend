//
//  SessionPlayer.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 20/12/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation

class SessionPlayer: NSObject {
    
    static let instance = SessionPlayer()
    var delegate: SessionPlayerDelegate!
    
    var sessions: [Session] = []
    
    override init() {
        super.init()
        
        sessions = SessionStorage.instance.loadSessions()
    }
    
    func refreshSessions() {
        sessions = SessionStorage.instance.loadSessions()
        print(sessions)
    }
    
    func playSession(_ selectedSession: Session) {
        print(selectedSession.sessionDate)
        var dataLeftShoe = selectedSession.dataLeftShoe
        var dataRightShoe = selectedSession.dataRightShoe
        if(dataLeftShoe.count != 0 || dataRightShoe.count != 0) {
            for i in 0..<dataLeftShoe.count {
                let leftShoe = Shoe(1, sensor1: Int(dataLeftShoe[i][0]), sensor2: Int(dataLeftShoe[i][1]), sensor3: Int(dataLeftShoe[i][2]), sensor4: Int(dataLeftShoe[i][3]))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (0.01 * Double(i)), execute: {
                    self.delegate?.sessionPlayDataUpdated(leftShoe)
                })
            }
            
            for j in 0..<dataRightShoe.count {
                let rightShoe = Shoe(2, sensor1: Int(dataRightShoe[j][0]), sensor2: Int(dataRightShoe[j][1]), sensor3: Int(dataRightShoe[j][2]), sensor4: Int(dataRightShoe[j][3]))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (0.01 * Double(j)), execute: {
                    self.delegate?.sessionPlayDataUpdated(rightShoe)
                })
            }
        }
    }
    
    func demoSession(){
        if(sessions.count > 0) {
            playSession(sessions[0])
        }
        
    }
    
}

protocol SessionPlayerDelegate {
    func sessionPlayDataUpdated(_ data: Shoe)
}

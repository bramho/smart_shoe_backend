//
//  Session.swift
//  SmartShoeBackend
//
//  Created by Grond, H. on 20/12/2017.
//  Copyright © 2017 MTNW07-17. All rights reserved.
//

import Foundation

class Session: NSObject, NSCoding {
    
    var sessionDate: Date!
    var dataLeftShoe: [[Double]] = []
    var dataRightShoe: [[Double]] = []
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("repressSessions")
    
    init(_ date: Date!, _ leftShoeData: [[Double]]!, _ rightShoeData: [[Double]]!) {
        self.sessionDate = date
        self.dataLeftShoe = leftShoeData
        self.dataRightShoe = rightShoeData
    }
    
    func update(shoeType: Int, newData: [Double]) {
        if(shoeType == 1) {
            dataLeftShoe.append(newData)
        } else if (shoeType == 2 ) {
            dataRightShoe.append(newData)
        }
    }
    
    func setDate(_ date: Date!) {
        sessionDate = date
    }
    
    //NSCoding functions
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sessionDate, forKey: SessionPropertyKeys.sessionDate)
        aCoder.encode(dataLeftShoe, forKey: SessionPropertyKeys.dataLeftShoe)
        aCoder.encode(dataRightShoe, forKey: SessionPropertyKeys.dataRightShoe)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let date = aDecoder.decodeObject(forKey: SessionPropertyKeys.sessionDate) as? Date else {
            return nil
        }
        
        let leftShoeData = aDecoder.decodeObject(forKey: SessionPropertyKeys.dataLeftShoe) as? [[Double]]
        let rightShoeData = aDecoder.decodeObject(forKey: SessionPropertyKeys.dataRightShoe) as? [[Double]]
        
        self.init(date, leftShoeData, rightShoeData)
    }
    
}

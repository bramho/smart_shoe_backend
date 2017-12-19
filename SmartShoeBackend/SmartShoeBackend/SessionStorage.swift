import Foundation

class SessionStorage { 
    static let instance = SessionStorage()
    var sessions : [Session]?
    var currentSession : Session?

    init() {
        super.init()

        sessions = loadSessions()
    }

    func deleteSession(_ selectedSession: Session) { 
        for session in sessions { 
            if(session = selectedSession) { 
                session = sessions.filter() { $0 !== selectedSession}
            }
        }
    }
    
    private func saveSessions() { 
        for session in sessions { 
            if (session.dataLeftShoe.count != session.dataRightShoe){
                if(session != currentSession) {
                    print(session.sessionDate)
                    print(currentSession.sessionDate) 
                    sessions = sessions.filter() { $0 !== session }
                }
            }
        }

        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(sessions, toFile: Session.ArchiveURL.path)
        print(isSuccesfulSave)
    }

    private func loadSessions() -> [Session]? { 
        return NSKeyedArchiver.unarchiveObject(withFile: Session.ArchiveURL.path) as? [Session]
    }

    func recordSession(shoeType: Int, shoeData: [Double]) {
        if(currentSession = nil) { 
            currentSession = Session.init(date: Date.init())
            sessions.append(currentSession)
        }

        currentSession.update(shoeType: shoeType, newData: shoeData)
    }

    func stopRecordingSession() { 

        saveSessions()
        currentSession = nil
    }
}

class Session: NSObject, NSCoding { 

    var sessionDate: Date!
    var dataLeftShoe: [[Double]] = []
    var dataRightShoe: [[Double]] = []

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("repressSessions")

    init(_ date: Date!) {
        super.init();
        sessionDate = date
    }
    
    update(shoeType: Int, newData: [Double]) { 
        if(shoeType == 1) { 
            dataLeftShoe.append(newData)
        } else if (shoeType == 2 ) { 
            dataRightShoe.append(newData)
        }
    }

    //NSCoding functions

    encode(with aCoder: NSCoder) {
        aCoder.encode(sessionDate, forKey: SessionPropertyKeys.sessionDate) 
        aCoder.encode(dataLeftShoe, forKey: SessionPropertyKeys.dataLeftShoe)
        aCoder.encode(dataRightShoe, forKey: SessionPropertyKeys.dataRightShoe)
    }

    init?(coder aDecoder: NSCoder) { 

    }

}

class SessionPlayer { 

    static let instance = SessionPlayer()
    weak var delegate: SessionPlayerDelegate!

    var sessions: [Session]?

    init() { 
        super.init()

        sessions = SessionStorage.instance.loadSessions()
    }

    playSession(_ selectedSession: Session) {
        // for something

            for i in selectedSession.dataLeftShoe.count { 
                var leftShoe = Shoe(1, sensor1: Int(dataLeftShoe[i][0], sensor2: Int(dataLeftShoe[i][1]), sensor3: Int(dataLeftShoe[i][2]), sensor4: Int(dataLeftShoe[i][3])))

                delegate.sessionPlayDataUpdated(leftShoe)
            }

            for j in selectedSession.dataRightShoe.count { 
                var rightShoe = Shoe(1, sensor1: Int(dataRightShoe[i][0], sensor2: Int(dataRightShoe[i][1]), sensor3: Int(dataRightShoe[i][2]), sensor4: Int(dataRightShoe[i][3])))

                delegate.sessionPlayDataUpdated(rightShoe)
            }
    }

}

protocol SessionPlayerDelegate { 
    func sessionPlayDataUpdated(_ data: Shoe)
}

struct SessionPropertyKeys { 
    static let sessionDate = "sessionDate"
    static let dataLeftShoe = "dataLeftShoe"
    static let dataRightShoe ="dataRightShoe"
}
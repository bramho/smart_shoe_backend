import Foundation

class SessionStorage: NSCoder {
    static let instance = SessionStorage()
    var sessions : [Session] = []
    var currentSession : Session?

    override init() {
        super.init()
        sessions = loadSessions()
    }

    func deleteSession(_ selectedSession: Session) {
        for session in sessions {
            if(session == selectedSession) {
                sessions = sessions.filter() { $0 !== selectedSession}
            }
        }
    }
    
    func recordSession(shoeType: Int, shoeData: [Double]) {
        if(currentSession == nil) {
            if shoeType == 1 {
                currentSession = Session.init(Date.init(), [shoeData], [])
            } else if shoeType == 2 {
                currentSession = Session.init(Date.init(), [], [shoeData])
            }
            
            sessions.append(currentSession!)
        }
        print("updated..")
        print(shoeData)
        currentSession!.update(shoeType: shoeType, newData: shoeData)
        
        if(StateManager.instance.getCurrentState() == StateManager.States.completed){
            self.saveSessions()
        }
    }
    
    func stopRecordingSession() {
        saveSessions()
        //currentSession = nil
    }
    func loadSessions() -> [Session] {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Session.ArchiveURL.path) as? [Session] ?? []
    }
    
    private func saveSessions() {
        for session in sessions {
            if (session.dataLeftShoe.count != session.dataRightShoe.count){                if(session != currentSession) {
                    print(session.sessionDate)
                    print(currentSession!.sessionDate)
                    sessions = sessions.filter() { $0 !== session }
                }
            }
        }

        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(sessions, toFile: Session.ArchiveURL.path)
        SessionPlayer.instance.refreshSessions()
        print(isSuccesfulSave)
        currentSession = nil
    }
}

struct SessionPropertyKeys { 
    static let sessionDate = "sessionDate"
    static let dataLeftShoe = "dataLeftShoe"
    static let dataRightShoe = "dataRightShoe"
}


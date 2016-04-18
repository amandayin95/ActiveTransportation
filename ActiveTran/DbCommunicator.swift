
import Foundation
/**
 *  DbCommunicator
 *  DbCommunicator class saves the Refs that communicates with the database
 */
struct DbCommunicator {
    
    let studentsRef: Firebase!
    let rootRef:Firebase!
    let usersRef: Firebase!
    let routeRef: Firebase!
    let logRef: Firebase!
    var currentLogRef: Firebase!
    
    // Points to the current Firebase backend
    init(){
        self.rootRef = Firebase(url:"https://walkingschoolbus.firebaseio.com")
        self.studentsRef = Firebase(url: "https://walkingschoolbus.firebaseio.com/students")
        self.usersRef = Firebase(url:"https://walkingschoolbus.firebaseio.com/users")
        self.routeRef = Firebase(url:"https://walkingschoolbus.firebaseio.com/routes")
        self.logRef = Firebase(url:"https://walkingschoolbus.firebaseio.com/logs")
        self.currentLogRef = self.logRef
    }
    
    
}
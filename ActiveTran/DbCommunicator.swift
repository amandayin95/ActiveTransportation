
import Foundation

struct DbCommunicator {
    
    let ref: Firebase!
    let usersRef: Firebase!
    let routeRef: Firebase!
    let logRef: Firebase!
    
    // default initialization
    init(){
        self.ref = Firebase(url: "https://activetransportation.firebaseio.com/students")
        self.usersRef = Firebase(url:"https://activetransportation.firebaseio.com/users")
        self.routeRef = Firebase(url:"https://activetransportation.firebaseio.com/busroutes")
        self.logRef = Firebase(url:"https://activetransportation.firebaseio.com/logs")
    }
    
    
}
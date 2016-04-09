
import Foundation

struct DbCommunicator {
    
    let ref: Firebase!
    let rootRef:Firebase!
    let usersRef: Firebase!
    let routeRef: Firebase!
    let logRef: Firebase!
    let newUserRef:Firebase!
    
    // default initialization
    init(){
        self.rootRef = Firebase(url:"https://activetransportation.firebaseio.com")
        self.ref = Firebase(url: "https://activetransportation.firebaseio.com/students")
        self.usersRef = Firebase(url:"https://activetransportation.firebaseio.com/users")
        self.routeRef = Firebase(url:"https://activetransportation.firebaseio.com/routes")
        self.logRef = Firebase(url:"https://activetransportation.firebaseio.com/logs")
        self.newUserRef = Firebase(url:"https://activetransportation.firebaseio.com/newUser")
    }
    
    
}
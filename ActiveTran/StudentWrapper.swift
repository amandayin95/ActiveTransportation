
import Foundation

struct StudentWrapper {
    
    var student: Student!
//    var id: String!
    var arrived: Bool!
    // var index : Int!
    var ref: Firebase?
    
    // Initialize from arbitrary data
    init(student: Student, arrived: Bool) {
        self.student = student
     //   self.id = id
        self.arrived = arrived
        self.ref = Firebase(url: "https://activetransportation.firebaseio.com/students")
    }
    
    // Empty Initializer
    init() {
        self.student = nil
   //     self.id = nil
        self.arrived = nil
        self.ref = nil
    }
}
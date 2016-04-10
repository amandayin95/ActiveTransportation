
import Foundation

struct StudentWrapper {
    
    var student: Student!
    var arrived: Bool!
    var ref: Firebase?
    
    // Initialize from arbitrary data
    init(student: Student, arrived: Bool) {
        self.student = student
        self.arrived = arrived
        self.ref = Firebase(url: "https://activetransportation.firebaseio.com/students")
    }
    
    // Empty Initializer
    init() {
        self.student = nil
        self.arrived = nil
        self.ref = nil
    }
}
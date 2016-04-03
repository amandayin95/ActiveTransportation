
import Foundation

struct StudentWrapper {
    
    var student: Student!
    var id: String!
    var arrived: Bool!
    var ref: Firebase?
    
    // Initialize from arbitrary data
    init(student: Student, id: String, arrived: Bool) {
        self.student = student
        self.id = id
        self.arrived = arrived
        self.ref = nil
    }
}
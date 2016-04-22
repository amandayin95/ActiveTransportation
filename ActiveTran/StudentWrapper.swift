import Foundation
/**
 *  StudentWrapper
 *  StudentWrapper class is used in the program to combine Student and StudentArvInfo
 *  pulled down from Firebase.
 */
struct StudentWrapper {
    
    var student: Student!
    var arrived: Bool!
    
    // Initialize from arbitrary data
    init(student: Student, arrived: Bool) {
        self.student = student
        self.arrived = arrived
    }
    
    // Deafult Initializer
    init() {
        self.student = nil
        self.arrived = nil
    }
}

import Foundation

struct StudentWrapper {
    
    let student: Student!
    let studentArvInfo: StudentArvInfo!
    
    // Initialize from arbitrary data
    init(student: Student, studentArvInfo: StudentArvInfo) {
        self.student = student
        self.studentArvInfo = studentArvInfo
    }
}
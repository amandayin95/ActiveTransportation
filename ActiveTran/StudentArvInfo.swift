
import Foundation

struct StudentArvInfo {
    
    let key: String!
    let studentID : String!
    let staffID: String!
    var arrived: Bool!
    var ref: Firebase?
    
    // Initialize from arbitrary data
    init(arrived: Bool, key: String , studentID : String, staffID: String!) {
        self.key = key
        self.studentID = studentID
        self.arrived = arrived
        self.staffID = staffID
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        arrived = snapshot.value["arrived"] as! Bool
        studentID = snapshot.value["studentID"] as! String
        staffID = snapshot.value["staffID"] as! String
        ref = snapshot.ref
    }

    func toAnyObject() -> AnyObject {
        return [
            "key": key,
            "studentID": studentID,
            "arrived": arrived,
            "staffID": staffID,
        ]
    }
    
}
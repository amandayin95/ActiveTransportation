
import Foundation

struct BusRoute {
    let name: String
    let staffID: String
    let students: NSDictionary
    let meetingTime: String
    let meetingLocation: String
    let key: String
    
    // Initialize from Firebase Snapshot
    init(snapshot: FDataSnapshot) {
        name = snapshot.value["name"] as! String
        staffID = snapshot.value["staffID"] as! String
        students = snapshot.value["studnets"] as! NSDictionary
        meetingTime = snapshot.value["meetingTime"] as! String
        meetingLocation = snapshot.value["meetingLocation"] as! String
        key = snapshot.key
    }
    
    // Initialize from arbitrary data
    init(name: String, staffID: String, students: NSDictionary, meetingTime: String, meetingLocation: String) {
        self.name = name
        self.staffID = staffID
        self.students = students
        self.meetingTime = meetingTime
        self.meetingLocation = meetingLocation
        self.key = ""
    }
    
    func toAnyObject() -> AnyObject {
        return[
            "name": name,
            "staffId": staffID,
            "students": students,
            "meetingTime": meetingTime,
            "meetingLocation": meetingLocation,
           // "key":key
        ]
    }
    
}
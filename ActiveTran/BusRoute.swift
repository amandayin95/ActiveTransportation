
import Foundation

struct BusRoute {
    let routeID: String
    let meetingTime: String
    let meetingLocation: String
    
    // Initialize from Firebase Snapshot
    init(snapshot: FDataSnapshot) {
        routeID = snapshot.value["routeID"] as! String
        meetingTime = snapshot.value["meetingTime"] as! String
        meetingLocation = snapshot.value["meetingLocation"] as! String
    }
    
    // Initialize from arbitrary data
    init(routeID: String, meetingTime: String, meetingLocation: String) {
        self.routeID = routeID
        self.meetingTime = meetingTime
        self.meetingLocation = meetingLocation
    }
    
    func toAnyObject() -> AnyObject {
        return[
            "routeID": routeID,
            "meetingTime": meetingTime,
            "meetingLocation": meetingLocation,
        ]
    }
    
}
import Foundation
/**
 *  Student Arv Info Class
 *  Separating Student Arv Info from Student object to avoid repeatedly
 *  refreshing Student objects on Firebase.
 *  Locally wrapped together with Student to form StudentWrapper
 */
struct StudentArvInfo {
    
    let key: String!
    let staffID: String!
    var arrived: Bool!
    
    // Initialize from arbitrary data
    init(arrived: Bool, key: String, staffID: String!) {
        self.key = key
        self.arrived = arrived
        self.staffID = staffID
    }
    
    // Initialize from Firebase snapshot data
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        arrived = snapshot.value["arrived"] as! Bool
        staffID = snapshot.value["staffID"] as! String
    }
    
    // Convert to JSON object for pushing onto Firebase
    func toAnyObject() -> AnyObject {
        return [
            "key": key,
            "arrived": arrived,
            "staffID": staffID,
        ]
    }
    
}
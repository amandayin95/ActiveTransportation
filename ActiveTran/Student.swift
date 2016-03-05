
import Foundation

struct Student {
  
  let key: String!
  let name: String!
  let studentID : String!
  let parentID : String!
  let staffID: String!
  let routeID: String!
  let school: String!

  // let ref: Firebase?
  var arrived: Bool!
  
  // Initialize from arbitrary data
    init(name: String, studentID: String, school: String, key: String = "", parentID : String, staffID : String, routeID: String) {
    self.key = key
    self.name = name
    self.studentID = studentID
    self.school = school
  //  self.arrived = arrived
    self.parentID = parentID;
    self.staffID = staffID;
    self.routeID = routeID;
    // self.ref = nil
  }
  
  init(snapshot: FDataSnapshot) {
    key = snapshot.key
    name = snapshot.value["name"] as! String
    studentID = snapshot.value["studentID"] as! String
    school = snapshot.value["school"] as! String
//    arrived = snapshot.value["arrived"] as! Bool
    parentID = snapshot.value["parentID"] as! String
    staffID = snapshot.value["staffID"] as! String
    routeID = snapshot.value["routeID"] as! String
    // ref = snapshot.ref
  }
  
  func toAnyObject() -> AnyObject {
    return [
      "name": name,
      "studentID": studentID,
      "school": school,
  //    "arrived": arrived,
      "parentID": parentID,
      "staffID": staffID,
      "routeID": routeID,
    ]
  }
  
}

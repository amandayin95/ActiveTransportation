
import Foundation

struct Student {
  
  let key: String!
  let name: String!
  let studentID : String!
  let parentID : String!
 // let staffID: String!
  let routeID: String!
  let school: String!
  
  // Initialize from arbitrary data
    init(name: String, studentID: String, school: String, key: String = "", parentID : String, staffID : String, routeID: String) {
    self.key = key
    self.name = name
    self.studentID = studentID
    self.school = school
    self.parentID = parentID;
    self.routeID = routeID;
  }
  
  init(snapshot: FDataSnapshot) {
    key = snapshot.key
    name = snapshot.value["name"] as! String
    studentID = snapshot.key as! String
    school = snapshot.value["school"] as! String
    parentID = snapshot.value["parentID"] as! String
    routeID = snapshot.value["routeID"] as! String
  }
  
  func toAnyObject() -> AnyObject {
    return [
      "name": name,
      "studentID": studentID,
      "school": school,
      "parentID": parentID,
      "routeID": routeID,
    ]
  }
  
}


import Foundation

struct User {
  let uid: String
  let name: String
  let email: String
  let contactInfo: String
  var routeID: String
  //let isStaff: true;
 
  // Initialize from Firebase
    init(authData: FAuthData, name:String, contactInfo: String, routeID: String) {
    self.uid = authData.uid.lowercaseString
    self.name = name
    self.email = authData.providerData["email"] as! String
    self.contactInfo = contactInfo
    self.routeID = routeID
  }
    
    init(snapshot: FDataSnapshot) {
        uid = snapshot.value["uid"] as! String
        name = snapshot.value["name"] as! String
        email = snapshot.value["email"] as! String
        routeID = snapshot.value["routeID"] as! String
        contactInfo = snapshot.value["contactInfo"] as! String
    }
  
  // Initialize from arbitrary data
    init(uid: String, name: String, email: String, contactInfo: String, routeID: String) {
    self.uid = uid
    self.name = name
    self.email = email
    self.contactInfo = contactInfo
    self.routeID = routeID
  }
    
    func toAnyObject() -> AnyObject {
    return[
    "uid": uid,
    "name": name,
    "email": email,
    "contactInfo": contactInfo,
    "routeID": routeID,
    ]
    }

}
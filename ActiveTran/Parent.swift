//
//  Parent
//  ActiveTransportation
//
//  Created by Amanda Yin on 4/2/16.
//
//

import Foundation
class Parent : User{
    var childrenIDs:NSDictionary
    
    override
    init(snapshot:FDataSnapshot){
        self.childrenIDs = snapshot.value["childrenIDs"] as! NSDictionary
        super.init(
            uid:snapshot.value["uid"] as! String,
            name:snapshot.value["name"] as! String,
            email:snapshot.value["email"] as! String,
            contactInfo:snapshot.value["contactInfo"] as! String,
            isStaff:snapshot.value["isStaff"] as! Bool)
    }
    
    init(uid: String, name: String, email: String, contactInfo: String, isStaff: Bool, childrenIDs: NSDictionary) {
        self.childrenIDs = childrenIDs
        super.init(uid: uid, name: name, email: email, contactInfo: contactInfo, isStaff: isStaff)
    }
    
    override
    func toAnyObject() -> AnyObject {
        return[
            "uid": uid,
            "name": name,
            "email": email,
            "contactInfo": contactInfo,
            "isStaff": isStaff,
            "childrenIDs":childrenIDs
        ]
    }
}
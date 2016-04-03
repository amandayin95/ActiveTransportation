//
//  Staff.swift
//  ActiveTransportation
//
//  Created by Amanda Yin on 4/2/16.
//
//

import Foundation
class Staff : User{
    var routeID:String
    
    override
    init(snapshot:FDataSnapshot){
        self.routeID = snapshot.value["routeID"] as! String
        super.init(
            uid:snapshot.value["uid"] as! String,
            name:snapshot.value["name"] as! String,
            email:snapshot.value["email"] as! String,
            contactInfo:snapshot.value["contactInfo"] as! String,
            isStaff:snapshot.value["isStaff"] as! Bool)
    }
    
    init(uid: String, name: String, email: String, contactInfo: String, isStaff: Bool, routeID: String) {
        self.routeID = routeID
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
            "routeID":routeID
        ]
    }
}
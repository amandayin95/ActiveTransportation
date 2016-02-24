/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation

struct Student {
  
  let key: String!
  let name: String!
  let studentID : String!
  let parentID : String!
  let staffID: String!
  let routeID: String!
  let school: String!
  let ref: Firebase?
  var arrived: Bool!
  
  // Initialize from arbitrary data
    init(name: String, studentID: String, school: String, arrived: Bool, key: String = "", parentID : String, staffID : String, routeID: String) {
    self.key = key
    self.name = name
    self.studentID = studentID
    self.school = school
    self.arrived = arrived
    self.parentID = parentID;
    self.staffID = staffID;
    self.routeID = routeID;
    self.ref = nil
  }
  
  init(snapshot: FDataSnapshot) {
    key = snapshot.key
    name = snapshot.value["name"] as! String
    studentID = snapshot.value["studentID"] as! String
    school = snapshot.value["school"] as! String
    arrived = snapshot.value["arrived"] as! Bool
    parentID = snapshot.value["parentID"] as! String
    staffID = snapshot.value["staffID"] as! String
    routeID = snapshot.value["routeID"] as! String
    ref = snapshot.ref
  }
  
  func toAnyObject() -> AnyObject {
    return [
      "name": name,
      "studentID": studentID,
      "school": school,
      "arrived": arrived,
      "parentID": parentID,
      "staffID": staffID,
      "routeID": routeID,
    ]
  }
  
}
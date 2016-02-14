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

struct User {
  let uid: String
  let email: String
  //let isStaff: true;
 
  // Initialize from Firebase
  init(authData: FAuthData) {
    uid = authData.uid
    print("user.swift file authData uid")
    print(authData.uid)
    print("\n")
    email = authData.providerData["email"] as! String
    print("user.swift file authData email")
    print(email)
    print("\n")
  }
  
  // Initialize from arbitrary data
    init(uid: String, email: String, listOfStudent: [Student]) {
    self.uid = uid
    self.email = email
  }
    
    func toAnyObject() -> AnyObject {
    return[
    "uid": uid,
    "email": email,
    ]
    }

}
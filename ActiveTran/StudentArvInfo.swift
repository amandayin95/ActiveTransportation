//
//  StudentLocal.swift
//  ActiveTransportation
//
//  Created by shuopeng yin on 2/20/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

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

struct StudentArvInfo {
    
    let key: String!
    let studentID : String!
    let staffID: String!
    var arrived: Bool!
    var ref: Firebase?
    
    // Initialize from arbitrary data
    init(arrived: Bool, key: String , studentID : String, staffID: String!) {
        self.key = key
        self.studentID = studentID
        self.arrived = arrived
        self.staffID = staffID
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        arrived = snapshot.value["arrived"] as! Bool
        studentID = snapshot.value["studentID"] as! String
        staffID = snapshot.value["staffID"] as! String
        ref = snapshot.ref
    }

    func toAnyObject() -> AnyObject {
        return [
            "key": key,
            "studentID": studentID,
            "arrived": arrived,
            "staffID": staffID,
        ]
    }
    
}
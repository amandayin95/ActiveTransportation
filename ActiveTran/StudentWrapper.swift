//
//  StudentWrapper.swift
//  ActiveTransportation
//
//  Created by shuopeng yin on 2/20/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Foundation
struct StudentWrapper {
    
    let student: Student!
    let studentArvInfo: StudentArvInfo!
    
    // Initialize from arbitrary data
    init(student: Student, studentArvInfo: StudentArvInfo) {
        self.student = student
        self.studentArvInfo = studentArvInfo
    }
}
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

import UIKit

class StudentListTableViewController: UITableViewController {

  // MARK: Constants
  let ListToUsers = "ListToUsers"
    
  // MARK: Data passed in from segue
  var contactInfoToPass: String!
  var nameToPass: String!
  var busRouteToPass: String!
  var signUpMode = false
  var logExsits = false
  var currentDate : String!
  
  // MARK: Properties
  var studentsWrapper = [StudentWrapper]()
  var students = [Student]()
  var studentArvInfo = [StudentArvInfo]()
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
  let ref = Firebase(url: "https://activetransportation.firebaseio.com/students")
  let usersRef = Firebase(url: "https://activetransportation.firebaseio.com/users")
  let routeRef = Firebase(url: "https://activetransportation.firebaseio.com/busroutes")
  let logRef = Firebase(url: "https://activetransportation.firebaseio.com/logs")
    
  // MARK: Dispatch Group to wait for query
  
  
  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    currentDate = "2016-02-20"
    
    // Set up swipe to delete
    tableView.allowsMultipleSelectionDuringEditing = false
    
    // User Count
    userCountBarButtonItem = UIBarButtonItem(title: "1", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("userCountButtonDidTouch"))
    userCountBarButtonItem.tintColor = UIColor.whiteColor()
    navigationItem.leftBarButtonItem = userCountBarButtonItem
}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        
//        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//        let group = dispatch_group_create()
//        
//        
//        // Add a task to the group
//        dispatch_group_async(group, queue, {
            self.authenticateUser()
//        })
//        
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
//        
//        dispatch_group_enter(group)
//
//        
//        // Add a task to the group
//        dispatch_group_async(group, queue, {
//            self.loadStudentInfo()
//        })
//        
//        self.loadStudentArvInfo()
//        
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
//        
//        // Release the group when it is no longer needed.
//        dispatch_group_leave(group)
//
//        
//       reloadTable()
 }
   

    
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
  }
  
  // MARK: UITableView Delegate methods
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return studentsWrapper.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as UITableViewCell!
    let studentSelected = studentsWrapper[indexPath.row]
    
    cell.textLabel?.text = studentSelected.student.name
    cell.detailTextLabel?.text = studentSelected.student.parentID
    
    // Determine whether the cell is checked
    toggleCellCheckbox(cell, isCompleted: studentSelected.studentArvInfo.arrived)
    
    return cell
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    //TODO if staff true parent false
    
    return true
  }
  
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // 1
            let student = students[indexPath.row]
            // 2
            student.ref?.removeValue()
        }
    }
  
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 1
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        // 2
        var studentSelected = studentsWrapper[indexPath.row]
        // 3
        let toggledCompletion = !studentSelected.studentArvInfo.arrived
        // 4
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        // 5
        studentSelected.studentArvInfo.ref?.updateChildValues([
            "arrived": toggledCompletion
            ])
    }
    
  func toggleCellCheckbox(cell: UITableViewCell, isCompleted: Bool) {
    if !isCompleted {
      cell.accessoryType = UITableViewCellAccessoryType.None
      cell.textLabel?.textColor = UIColor.blackColor()
      cell.detailTextLabel?.textColor = UIColor.blackColor()
    } else {
      cell.accessoryType = UITableViewCellAccessoryType.Checkmark
      cell.textLabel?.textColor = UIColor.grayColor()
      cell.detailTextLabel?.textColor = UIColor.grayColor()
    }
  }
  
  // MARK: Add Item
  
  @IBAction func addButtonDidTouch(sender: AnyObject) {
    // Alert View for input
    var alert = UIAlertController(title: "Student",
      message: "Add a student",
      preferredStyle: .Alert)
    
    let saveAction = UIAlertAction(title: "Save",
        style: .Default) { (action: UIAlertAction!) -> Void in
            
            // 1
            let textField = alert.textFields![0] as UITextField
            
            // 2
            let student = Student(name: textField.text!, studentID: textField.text!, school: "", arrived: false,  parentID: self.user.name, staffID: self.user.uid, routeID: self.user.routeID )
            
            // 3 TODO, how should we name the students? student name + uid?
            let studentRef = self.ref.childByAppendingPath(textField.text!.lowercaseString)
            
            // 4
            studentRef.setValue(student.toAnyObject())
            
            // now other than that we also need the id of the student to the staff's list
            
            
    }
    let cancelAction = UIAlertAction(title: "Cancel",
      style: .Default) { (action: UIAlertAction!) -> Void in
    }
    
    alert.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    presentViewController(alert,
      animated: true,
      completion: nil)
  }
  
  func userCountButtonDidTouch() {
    performSegueWithIdentifier(ListToUsers, sender: nil)
  }
    
    func authenticateUser(){
        print("Does it authenticate at all 1? \n")
        self.ref.observeAuthEventWithBlock { authData in
            print("Does it authenticate at all? 2 \n")
            if authData != nil {
                
                print("Does it authenticate at all? 3 \n" + authData.uid!.lowercaseString)
                if (self.signUpMode == true){
                    self.user = User(authData: authData, name:self.nameToPass, contactInfo: self.contactInfoToPass, routeID: "r2" )
                    print("Does it authenticate at all? 4 \n")
                    //1
                    let currentUserRef = self.usersRef.childByAppendingPath(self.user.uid)
                    //2
                    currentUserRef.setValue(self.user.toAnyObject())
                    // 3
                    // currentUserRef.onDisconnectRemoveValue()
                    // 4
                    self.ref.unauth() // need this to switch between accounts
                    // unauth will not alter or remove the uid of the user
                }else{
                    let idCopy = authData.uid
                    //1
                    self.usersRef.queryOrderedByChild("uid").queryEqualToValue(idCopy).observeEventType(.Value, withBlock: { snapshot in
                        print("Does it authenticate at all? 5 \n")
                        if (snapshot.hasChildren()){
                        for item in snapshot.children {
                            self.user = User(snapshot: item as! FDataSnapshot)
                            print("Does it authenticate at all? 6 \n")
                        }
                        }
                        self.loadStudentInfo()
                    })
                    // 3
                    self.ref.unauth() // need this to switch between accounts
                    // unauth will not alter or remove the uid of the user
                    
                }
                
            }
        }
    }

    func loadStudentInfo(){
        print("loading student into 1 \n")
        self.ref.queryOrderedByChild("staffID").queryEqualToValue(self.user.uid).observeEventType(.Value, withBlock: { snapshot in
            var newStudents = [Student]()
            if (snapshot.hasChildren()){
            for item in snapshot.children {
                print("loading student into 2 \n")
                var newStudent = Student(snapshot: item as! FDataSnapshot)
                newStudents.append(newStudent)
            }
            }
            self.students = newStudents
            self.loadStudentArvInfo()
        })
    }
    
    func loadStudentArvInfo(){
        var currentLogRef = self.logRef.childByAppendingPath(self.currentDate)
        
        currentLogRef.queryOrderedByChild("staffID").queryEqualToValue(self.user.uid).observeEventType(.Value, withBlock: {
            snapshot in
            var sArvInfo = [StudentArvInfo]()
            if (!snapshot.hasChildren()){
                for item in self.students{
                    var newSArvInfo = StudentArvInfo(arrived: item.arrived, key: item.key, studentID: item.studentID, staffID: item.staffID )
                    var studentLogRef = currentLogRef.childByAppendingPath(newSArvInfo.studentID)
                    newSArvInfo.ref = studentLogRef
                    studentLogRef.setValue(newSArvInfo.toAnyObject())
                }
                self.logExsits = true
                self.studentArvInfo = sArvInfo
            }else{
                for item in snapshot.children{
                    var newSArvInfo = StudentArvInfo(snapshot: item as! FDataSnapshot)
                    sArvInfo.append(newSArvInfo)
                }
                self.logExsits = true
                self.studentArvInfo = sArvInfo
                
            }
            self.reloadTable()
        })

    }
    
    func reloadTable(){
        var sWrapper = [StudentWrapper]()
        if (self.students.count > 0 && self.studentArvInfo.count > 0){
            // use the information from the log
            for i in 1...self.studentArvInfo.count{
                for j in 1...self.students.count{
                    if (self.students[j-1].studentID == self.studentArvInfo[i-1].studentID){
                        var newSWrapper = StudentWrapper(student: self.students[j-1], studentArvInfo: self.studentArvInfo[i-1])
                        sWrapper.append(newSWrapper)
                    }
                }
            }
        }
        self.studentsWrapper = sWrapper
        self.tableView.reloadData()

    }
    
}

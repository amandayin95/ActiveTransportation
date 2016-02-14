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
  
  // MARK: Properties 
  var students = [Student]()
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
  let ref = Firebase(url: "https://activetransportation.firebaseio.com/students")
  let usersRef = Firebase(url: "https://activetransportation.firebaseio.com/users")
  // let listRef = Firebase(url: "https://activetransportation.firebaseio.com/list") not used now
  
  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // Set up swipe to delete
    tableView.allowsMultipleSelectionDuringEditing = false
    
    // User Count
    userCountBarButtonItem = UIBarButtonItem(title: "1", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("userCountButtonDidTouch"))
    userCountBarButtonItem.tintColor = UIColor.whiteColor()
    navigationItem.leftBarButtonItem = userCountBarButtonItem
    
    user = User(uid: "FakeId", name: "Fake User", email: "hungry@person.food", contactInfo: "123455667")
    print(user.email)
  }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ref.observeAuthEventWithBlock { authData in
            if authData != nil {
                self.user = User(authData: authData)
                // 1
                let currentUserRef = self.usersRef.childByAppendingPath(self.user.uid)
                // 2
                currentUserRef.setValue(self.user.toAnyObject())
                // 3
                //currentUserRef.onDisconnectRemoveValue()
                self.ref.unauth() // need this to switch between accounts 
                                  // unauth will not alter or remove the uid of the user
                
            }
        }
        
        //queryOrderedByChild("arrived"). stategically giving up this feature for now  TODO
        
        // if staff, we do this
            ref.queryOrderedByChild("staffID").queryEqualToValue(user.uid).observeEventType(.Value, withBlock: { snapshot in
                var newStudents = [Student]()
                for item in snapshot.children {
                    let newStudent = Student(snapshot: item as! FDataSnapshot)
                    newStudents.append(newStudent)
                }
                self.students = newStudents
                self.tableView.reloadData()
            })
        
        // otherwise we do
        //   ref.queryOrderedByChild("parentID").queryEqualToValue(user.uid) .......
        //         to display the list for parent
        
    }
    
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
  }
  
  // MARK: UITableView Delegate methods
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return students.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as UITableViewCell!
    let studentSelected = students[indexPath.row]
    
    cell.textLabel?.text = studentSelected.name
    cell.detailTextLabel?.text = studentSelected.parentID
    
    // Determine whether the cell is checked
    toggleCellCheckbox(cell, isCompleted: studentSelected.arrived)
    
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
        var studentSelected = students[indexPath.row]
        // 3
        let toggledCompletion = !studentSelected.arrived
        // 4
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        // 5
        studentSelected.ref?.updateChildValues([
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
            let student = Student(name: textField.text!, school: "", arrived: false,  parentID: self.user.uid, staffID: self.user.uid )
            
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
  
}

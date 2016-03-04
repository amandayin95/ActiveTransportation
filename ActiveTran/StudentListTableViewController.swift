
import UIKit

class StudentListTableViewController: UITableViewController {

  // MARK: Constants
  let ListToUsers = "ListToUsers"
  let MORNING_PERIOD = "morning"
  let AFTERNOON_PERIOD = "afternoon"
    
  // MARK: Data passed in from segue
  var contactInfoToPass: String!
  var nameToPass: String!
  var busRouteToPass: String!
  var signUpMode = false
  var logExsits = false
  var isMorning = true
  var currentDate : String!
  
  // MARK: Properties
  var studentsWrapper = [StudentWrapper]()
  var students = [Student]()
  var studentArvInfo = [StudentArvInfo]()
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!

  // Mark: DbCommunicator
  var dbComm = DbCommunicator()

  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let date = NSDate()
    let calendar:NSCalendar = NSCalendar.currentCalendar()
    let components = calendar.components(.CalendarUnitHour,fromDate:date)
//    let components = [NSCalendar] calendar.components([.Hour], fromDate: date)
    let hour = components.hour
    if (hour > 0 && hour < 12){
        isMorning = true
    }else{
        isMorning = false
    }
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    self.currentDate =  dateFormatter.stringFromDate(date)
    
    // Set up swipe to delete  
    // TODO what does this have to do with delete?
    tableView.allowsMultipleSelectionDuringEditing = false
    
    // User Count
    userCountBarButtonItem = UIBarButtonItem(title: "1", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("userCountButtonDidTouch"))
    userCountBarButtonItem.tintColor = UIColor.whiteColor()
    navigationItem.leftBarButtonItem = userCountBarButtonItem
}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

            self.authenticateUser()
 }
   

    
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
  }
  
  // MARK: UITableView Delegate methods
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return studentsWrapper.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell") as! UITableViewCell
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
    
     func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction?] {
        let more = UITableViewRowAction(style: .Normal, title: "More") { (action, indexPath) in
            print("called more tab! \n")
        }
        
        more.backgroundColor = UIColor.grayColor()
        
        return [more]
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
            let textField = alert.textFields![0] as! UITextField
            
            // 2
            let student = Student(name: textField.text!, studentID: textField.text!, school: "", arrived: false,  parentID: self.user.name, staffID: self.user.uid, routeID: self.user.routeID )
            
            // 3 TODO, how should we name the students? student name + uid?
            let studentRef = self.dbComm.ref.childByAppendingPath(textField.text!.lowercaseString)
            
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
        self.dbComm.ref.observeAuthEventWithBlock { authData in
            if authData != nil {
                print(authData.uid.lowercaseString + " if authdata is not null \n");
                if (self.signUpMode == true){
                    self.user = User(authData: authData, name:self.nameToPass, contactInfo: self.contactInfoToPass, routeID: "r3" )
                    //1
                    let currentUserRef = self.dbComm.usersRef.childByAppendingPath(self.user.uid)
                    //2
                    currentUserRef.setValue(self.user.toAnyObject())
                    // 3
                    // currentUserRef.onDisconnectRemoveValue()
                    self.dbComm.ref.unauth() // need this to switch between accounts
                    // unauth will not alter or remove the uid of the user
                    // 4
                    self.reloadTable();
                }else{
                    let idCopy = authData.uid.lowercaseString
                    print (idCopy + " id copy \n")
                    //1
                    self.dbComm.usersRef.queryOrderedByChild("uid").queryEqualToValue(idCopy).observeEventType(.Value, withBlock: { snapshot in
                        if (snapshot.hasChildren()){
                            print("getting anything? \n")
                            for item in snapshot.children {
                                self.user = User(snapshot: item as! FDataSnapshot)
                            }
                        }
                        print(self.user.uid + " id before loading student info \n")
                        self.loadStudentInfo()
                    })
                    // 3
                    self.dbComm.ref.unauth() // need this to switch between accounts
                    // unauth will not alter or remove the uid of the user
                    
                }
                
            }
        }
    }

    func loadStudentInfo(){
        print(self.user.uid.lowercaseString)
        self.dbComm.ref.queryOrderedByChild("staffID").queryEqualToValue(self.user.uid).observeEventType(.Value, withBlock: { snapshot in
            var newStudents = [Student]()
            if (snapshot.hasChildren()){
            for item in snapshot.children {
                var newStudent = Student(snapshot: item as! FDataSnapshot)
                newStudents.append(newStudent)
            }
            }
            self.students = newStudents
            self.loadStudentArvInfo()
        })
    }
    
    func loadStudentArvInfo(){
        var currentLogRef = Firebase()
        
        if (isMorning == true){
           currentLogRef  = self.dbComm.logRef.childByAppendingPath(self.currentDate).childByAppendingPath(MORNING_PERIOD)
        }else{
            currentLogRef = self.dbComm.logRef.childByAppendingPath(self.currentDate).childByAppendingPath(AFTERNOON_PERIOD)
        }
        
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

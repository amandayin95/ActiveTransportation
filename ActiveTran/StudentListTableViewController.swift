
import UIKit
import MessageUI

class StudentListTableViewController: UITableViewController, MFMailComposeViewControllerDelegate{

  // MARK: Constants
  let ListToUsers = "ListToUsers"
  let ListToContactInfo = "ListToContactInfo"
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
  
  // MARK: Selected student
  var studentSelected: Student!
    
  // MARK: Properties
  var studentsWrapper = [StudentWrapper]()
  var students = [Student]()
  var studentArvInfo = [StudentArvInfo]()
  // var user: User!
  var parent:Parent!
  var staff:Staff!
  var meetingInfoBarButtonItem: UIBarButtonItem!
  var queryString: String!
  var isStaff: Bool!
  // Mark: DbCommunicator
  var dbComm = DbCommunicator()

  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = NSDate()
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour], fromDate: date)
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
        
        // meeting info display
        meetingInfoBarButtonItem = UIBarButtonItem(title: "Meeting Info", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("meetingInfoButtonDidTouch"))
        
        //TODO change font size
        meetingInfoBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = meetingInfoBarButtonItem
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
    let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell")! as UITableViewCell
    let studentSelected = studentsWrapper[indexPath.row]
    
    cell.textLabel?.text = studentSelected.student.name
    cell.detailTextLabel?.text = "Student ID Number: " + studentSelected.student.studentID
    
    // Determine whether the cell is checked
    toggleCellCheckbox(cell, isCompleted: studentSelected.studentArvInfo.arrived)
    
    return cell
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
    

  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
            let more = UITableViewRowAction(style: .Normal, title: "More") { (action, indexPath) in
            self.studentSelected = self.studentsWrapper[indexPath.row].student
            self.performSegueWithIdentifier(self.ListToContactInfo, sender: nil)
        }
        
        more.backgroundColor = UIColor.grayColor()
        
        return [more]
    }
    
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      // Find the cell that user tapped using cellForRowAtIndexPath
      let cell = tableView.cellForRowAtIndexPath(indexPath)!
      // Get the corresponding GreoceryItem by using the index path's row
      var studentSelected = studentsWrapper[indexPath.row]
    
      // Staff Only: Negate completed on the student to toggle the status
      if (self.isStaff == true){
          let toggledCompletion = !studentSelected.studentArvInfo.arrived
          // Call toggleCellCheckbox() update the visual properties of the cell
          toggleCellCheckbox(cell, isCompleted: toggledCompletion)
          // Passing a dictioary to update Firebase
          studentSelected.studentArvInfo.ref?.updateChildValues(["arrived": toggledCompletion])
      }
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
  // Button to email page
  @IBAction func emailButtonDidTouch(sender: AnyObject) {
    
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail(){
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert(){
        let sendMailErrorAlert = UIAlertView(title:"Could Not Send Email", message:"Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
            sendMailErrorAlert.show()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["someone@somewhere.com"])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
  
    func meetingInfoButtonDidTouch() {
        performSegueWithIdentifier(self.ListToUsers, sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "ListToUsers") {
            let nav = segue.destinationViewController as! MeetingInfoTableViewController
            if (self.isStaff == true){
                if (self.staff != nil){
                    nav.staff = self.staff
                    nav.students = self.students
                }
            }else {
                if (self.parent != nil){
                    nav.parent = self.parent
                    nav.students = self.students
                }
            }
        }else if (segue.identifier == "ListToContactInfo") {
            let nav = segue.destinationViewController as! ContactInfoViewController
            if (self.isStaff == true){
                if (self.staff != nil) {
                    nav.studentSelected = self.studentSelected
                    nav.staff = self.staff
                }
            }else {
                if (self.parent != nil){
                    nav.studentSelected = self.studentSelected
                    nav.parent = self.parent
                }
     
            }
        }
    }

    func authenticateUser(){
        self.dbComm.ref.observeAuthEventWithBlock { authData in
            if authData != nil {
                if (self.signUpMode == true){
//                    self.user = User(authData: authData, name:self.nameToPass, contactInfo: self.contactInfoToPass, isStaff: false )
//                    
//                    if (self.user.isStaff == true){
//                        self.queryString = "staffID"
//                    }else{
//                        self.queryString = "parentID"
//                    }
//                    
//                    //1
//                    let currentUserRef = self.dbComm.usersRef.childByAppendingPath(self.user.uid)
//                    //2
//                    currentUserRef.setValue(self.user.toAnyObject())
//                    // 3
//                    self.dbComm.ref.unauth() // need this to switch between accounts
//                    // unauth will not alter or remove the uid of the user
//                    // 4
//                    self.reloadTable();
                }else{
                    let idCopy = authData.uid.lowercaseString
                    //1
                    self.dbComm.usersRef.childByAppendingPath(idCopy).observeEventType(.Value, withBlock: { snapshot in
                        if (snapshot.hasChildren()){
                            for item in snapshot.children{
                                let itemcast = item as! FDataSnapshot
                                if (itemcast.value["isStaff"] as! Bool == true){
                                    self.staff = Staff(snapshot: itemcast)
                                    self.isStaff = true
                                } else {
                                    self.parent = Parent(snapshot: itemcast)
                                    self.isStaff = false
                                }
                            }
                            // let item = snapshot.children.nextObject() as! FDataSnapshot
    
                        }
                        
//                        if (self.user.isStaff == true){
//                            self.queryString = "staffID"
//                        }else{
//                            self.queryString = "parentID"
//                        }
                        
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
        if(self.isStaff == true){
            self.dbComm.routeRef.childByAppendingPath(self.staff.routeID).observeEventType(.Value, withBlock: {
                snapshot in
                var newStudents = [Student]()
                if (snapshot.hasChildren()){
                    let item = BusRoute(snapshot: snapshot.children.nextObject() as! FDataSnapshot)
                    for s in item.students{
                        self.dbComm.ref.childByAppendingPath(s.key as! String).observeEventType(.Value, withBlock: {
                            snapshot in
                            if (snapshot.hasChildren()){
                                var newStudent = Student(snapshot: item as! FDataSnapshot)
                                newStudents.append(newStudent)
                            }
                        })
                    }
                }
                self.students = newStudents
                self.loadStudentArvInfo()
            })
        }else{
            self.dbComm.usersRef.childByAppendingPath(self.parent.uid).childByAppendingPath("childrenIDs").observeEventType(.Value, withBlock: {
                snapshot in
                var newStudents = [Student]()
                if (snapshot.hasChildren()){
                    let item = NSDictionary(dictionary: snapshot.children.nextObject() as! NSDictionary)
                    for s in item{
                        self.dbComm.ref.childByAppendingPath(s.key as! String).observeEventType(.Value, withBlock: {
                            snapshot in
                            if (snapshot.hasChildren()){
                                var newStudent = Student(snapshot: item as! FDataSnapshot)
                                newStudents.append(newStudent)
                            }
                        })
                    }
                }
                self.students = newStudents
                self.loadStudentArvInfo()
            })
        }
    }
    
    func loadStudentArvInfo(){
        var currentLogRef = Firebase()
        
        if (isMorning == true){
           currentLogRef  = self.dbComm.logRef.childByAppendingPath(self.currentDate).childByAppendingPath(MORNING_PERIOD)
        }else{
            currentLogRef = self.dbComm.logRef.childByAppendingPath(self.currentDate).childByAppendingPath(AFTERNOON_PERIOD)
        }
        
        if (self.isStaff == true){
            currentLogRef.queryOrderedByChild(self.queryString).queryEqualToValue(self.staff.uid).observeEventType(.Value, withBlock: {
                snapshot in
                var sArvInfo = [StudentArvInfo]()
                if (!snapshot.hasChildren()){
                    for item in self.students{
                        var newSArvInfo = StudentArvInfo(arrived: false, key: item.key, studentID: item.studentID, staffID: item.staffID )
                        let studentLogRef = currentLogRef.childByAppendingPath(newSArvInfo.studentID)
                        newSArvInfo.ref = studentLogRef
                        studentLogRef.setValue(newSArvInfo.toAnyObject())
                    }
                    self.logExsits = true
                    self.studentArvInfo = sArvInfo
                }else{
                    for item in snapshot.children{
                        let newSArvInfo = StudentArvInfo(snapshot: item as! FDataSnapshot)
                        sArvInfo.append(newSArvInfo)
                    }
                    self.logExsits = true
                    self.studentArvInfo = sArvInfo
                    
                }
                self.reloadTable()
            })
        }else{
            // if the user is a parent other than a staff
            for everyStudent in self.students{
                currentLogRef.queryOrderedByChild("studentID").queryEqualToValue(everyStudent.studentID).observeEventType(.Value, withBlock: {
                    snapshot in
                    if (!snapshot.hasChildren()){
                        self.logExsits = false
                    }else{
                        for item in snapshot.children{
                            let newSArvInfo = StudentArvInfo(snapshot: item as! FDataSnapshot)
                            self.studentArvInfo.append(newSArvInfo)
                        }
                        self.logExsits = true
                    }
                    self.reloadTable()
                })
            }
        }
    }
    
    func reloadTable(){
        var sWrapper = [StudentWrapper]()
        if (self.students.count > 0 && self.studentArvInfo.count > 0){
            if (self.isStaff == true){
                // use the information from the log
                for i in 1...self.studentArvInfo.count{
                    for j in 1...self.students.count{
                        if (self.students[j-1].studentID == self.studentArvInfo[i-1].studentID){
                            let newSWrapper = StudentWrapper(student: self.students[j-1], studentArvInfo: self.studentArvInfo[i-1])
                            sWrapper.append(newSWrapper)
                        }
                    }
                }
            }else{
                // handle the case where staff have not yet logged in so some student Arv info is missing
                for j in 1...self.students.count{
                    var foundMatch = false
                    for i in 1...self.studentArvInfo.count{
                        if (self.students[j-1].studentID == self.studentArvInfo[i-1].studentID){
                            foundMatch = true
                            let newSWrapper = StudentWrapper(student: self.students[j-1], studentArvInfo: self.studentArvInfo[i-1])
                            sWrapper.append(newSWrapper)
                            continue
                        }
                    }
                    if (foundMatch == false){
                        // if we did not find matching student arv info we create local ones for parent to view 
                        var fakeStudentArvInfo = StudentArvInfo(arrived: false, key:"", studentID: self.students[j-1].studentID, staffID: self.students[j-1].staffID)
                        let newSWrapper = StudentWrapper(student: self.students[j-1], studentArvInfo: fakeStudentArvInfo)
                        sWrapper.append(newSWrapper)
                    }
                }
            }
        
        }
        self.studentsWrapper = sWrapper
        self.tableView.reloadData()
    }
}


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
    var studentSelected: StudentWrapper!
    
    // MARK: Properties
    var studentsWrapper = [String:StudentWrapper]()
    var students = [Student]()
    var keysForTable = [String]()
    var parent:Parent!
    var staff:Staff!
    var meetingInfoBarButtonItem: UIBarButtonItem!
    var isStaff = false
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
        
        // Manually pushing new user class. Only for testing purposes.
        
        //                let newUserRef = self.dbComm.rootRef.childByAppendingPath("newUser")
        //                let testChildrenIDs:NSDictionary = ["vinh111111":"VinhFirst","vinh2222222":"VinhSecond"]
        //                let testParent = ["childrenID":testChildrenIDs, "name":"Vinh Hoang", "email":"vhoang@hmc.edu",
        //                                  "contact":"1112223333","isStaff":false]
        //                let userIDRef = newUserRef.childByAutoId()
        //                userIDRef.setValue(testParent)
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
        let studentSelected = studentsWrapper[keysForTable[indexPath.row]]
    
        cell.textLabel?.text = studentSelected?.student.name
        cell.detailTextLabel?.text = "Student ID Number: " + (studentSelected?.student.studentID)!
    
        // Determine whether the cell is checked
        toggleCellCheckbox(cell, isCompleted: (studentSelected?.arrived)!)
    
        return cell
    }
  
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .Normal, title: "More") { (action, indexPath) in
            self.studentSelected = self.studentsWrapper[self.keysForTable[indexPath.row]]
            self.performSegueWithIdentifier(self.ListToContactInfo, sender: nil)
        }
        
        more.backgroundColor = UIColor.grayColor()
        return [more]
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Find the cell that user tapped using cellForRowAtIndexPath
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        // Get the corresponding GreoceryItem by using the index path's row
        let studentSelected = self.studentsWrapper[self.keysForTable[indexPath.row]]

        // Staff Only: Negate completed on the student to toggle the status
        // Only staff has editing access
        if (self.isStaff == true){
            let toggledCompletion = !studentSelected!.arrived
            // Call toggleCellCheckbox() update the visual properties of the cell
            toggleCellCheckbox(cell, isCompleted: toggledCompletion)
            // Passing a dictioary to update Firebase
            studentSelected?.ref!.updateChildValues([studentSelected!.student.studentID: toggledCompletion])
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
        mailComposerVC.setSubject("Active Transportation Bus Route")
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
            nav.isStaff = self.isStaff
            if (self.isStaff == true){
                if (self.staff != nil){
                    nav.staff = self.staff
                    nav.students = self.students
                    print (self.staff)
                    print (self.students)
                }
            } else {
                if (self.parent != nil){
                    nav.parent = self.parent
                    nav.students = self.students
                }
            }
        } else if (segue.identifier == "ListToContactInfo") {
            let nav = segue.destinationViewController as! ContactInfoViewController
            if (self.isStaff == true){
                if (self.staff != nil) {
                    nav.isStaff = true
                    nav.studentWprSelected = self.studentSelected
                    nav.staff = self.staff
                }
            }else {
                if (self.parent != nil){
                    nav.isStaff = true
                    nav.studentWprSelected = self.studentSelected
                    nav.parent = self.parent
                }
     
            }
        }
    }

    func authenticateUser(){
        self.dbComm.ref.observeAuthEventWithBlock { authData in
            if authData != nil {
                if (self.signUpMode == true){
                    // TODO Register staff
                    self.staff = Staff(authData:authData, name:self.nameToPass, contactInfo:self.contactInfoToPass,
                        isStaff:true)
                    let currentUserRef = self.dbComm.newUserRef.childByAppendingPath(self.staff.uid)
                    currentUserRef.setValue(self.staff.toAnyObject())
                    self.dbComm.ref.unauth()
                    self.reloadTable()
                } else{
                    let idCopy = authData.uid.lowercaseString
                    //1
                    self.dbComm.newUserRef.childByAppendingPath(idCopy).observeEventType(.Value, withBlock: { snapshot in
                        if (snapshot.hasChildren()){
                            print(snapshot.value)
                                if (snapshot.value["isStaff"] as! Bool){
                                    self.isStaff = true
                                    self.staff = Staff(uid:snapshot.value["uid"] as! String,
                                        name:snapshot.value["name"] as! String,
                                        email:snapshot.value["email"] as! String,
                                        contactInfo:snapshot.value["contactInfo"] as! String,
                                        isStaff:snapshot.value["isStaff"] as! Bool,
                                        routeID: snapshot.value["routeID"] as! String)
                                }else{
                                    self.parent = Parent(uid:snapshot.value["uid"] as! String,
                                        name:snapshot.value["name"] as! String,
                                        email:snapshot.value["email"] as! String,
                                        contactInfo:snapshot.value["contactInfo"] as! String,
                                        isStaff:snapshot.value["isStaff"] as! Bool,
                                        childrenIDs: snapshot.value["childrenIDs"] as! NSDictionary);
                                }
                        }
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
                    print(snapshot.value)
                    let item = BusRoute(snapshot: snapshot as FDataSnapshot)
                    for s in item.students{
                        print(s.key)
                        self.keysForTable.append(s.key as! String)
                        // go find actual student object
                        // TODO we use s.value in below query because that is how we currently store our students in DB
                        self.dbComm.ref.childByAppendingPath(s.value as! String).observeEventType(.Value, withBlock: {
                            snapshot2 in
                            if (snapshot2.hasChildren()){
                                let newStudent = Student(snapshot: snapshot2 as FDataSnapshot)
                                let newStudentWpr = StudentWrapper(student: newStudent, arrived: false)
                                newStudents.append(newStudent)
                                self.studentsWrapper[newStudent.studentID] = newStudentWpr
                            }
                        })
                        // go find log
                        self.loadStudentArvInfo(s.key as! String);
                    }
                }
                self.students = newStudents
            })
        } else{
            self.dbComm.newUserRef.childByAppendingPath(self.parent.uid).childByAppendingPath("childrenIDs").observeEventType(.Value,withBlock:{
                snapshot in
                var newStudents = [Student]()
                if (snapshot.hasChildren()){
                    print(snapshot.value)
                    let childrenIDs = snapshot.children.nextObject() as! NSDictionary
                    // each child is saved as a ID:name pair in childrenIDs
                    for child in childrenIDs {
                        // save the children's key (studentID) in the keysForTable array
                        // for later display purposes
                        self.keysForTable.append(child.key as! String)
                        // go fetch the actual Student object
                        self.dbComm.ref.childByAppendingPath(child.key as! String).observeEventType(.Value,withBlock:{
                            snapshot2 in
                            if (snapshot2.hasChildren()){
                                let newStudent = Student(snapshot:snapshot2.value as! FDataSnapshot)
                                let newStudentWpr = StudentWrapper(student:newStudent,arrived:false)
                                newStudents.append(newStudent)
                                self.studentsWrapper[newStudent.studentID] = newStudentWpr
                            }
                        })
                        self.loadStudentArvInfo(child.key as! String)
                    }
                }
                self.students = newStudents
            })
        }
    }
    
    
    func loadStudentArvInfo(studentID: String){
        var currentLogRef = Firebase()
        
        if (isMorning == true){
           currentLogRef  = self.dbComm.logRef.childByAppendingPath(self.currentDate).childByAppendingPath(MORNING_PERIOD)
        }else{
            currentLogRef = self.dbComm.logRef.childByAppendingPath(self.currentDate).childByAppendingPath(AFTERNOON_PERIOD)
        }
        
        if (self.isStaff == true){
            // For staff, create new log records for the day
            currentLogRef.childByAppendingPath(studentID).observeEventType(.Value, withBlock: {
               snapshot in
                self.studentsWrapper[studentID]!.ref = currentLogRef.childByAppendingPath(studentID)
                if (!snapshot.hasChildren()){
                    self.studentsWrapper[studentID]!.ref!.setValue(false)
                    self.studentsWrapper[studentID]!.arrived = false
                }else{
                    self.studentsWrapper[studentID]!.arrived = snapshot.value[studentID] as! Bool
                }
                self.logExsits = true
                self.reloadTable()
            })
        }
//        else{
//            // For parents, siply display today's log records
//            currentLogRef.childByAppendingPath(studentID).observeEventType(.Value,withBlock: {
//                snapshot in
//                self.studentsWrapper[studentID]!.ref = currentLogRef.childByAppendingPath(studentID)
//                if (!snapshot.hasChildren()){
//                    self.logExsits = false
//                } else {
//                    for item in snapshot.children{
//                        self.studentsWrapper[studentID]!.arrived = false
//                    }
//                }
//            })
////            // if the user is a parent
////            for everyStudent in self.students{
////                currentLogRef.queryOrderedByChild("studentID").queryEqualToValue(everyStudent.studentID).observeEventType(.Value, withBlock: {
////                    snapshot in
////                    if (!snapshot.hasChildren()){
////                        self.logExsits = false
////                    }else{
////                        for item in snapshot.children{
////                            let newSArvInfo = StudentArvInfo(snapshot: item as! FDataSnapshot)
////                            self.studentArvInfo.append(newSArvInfo)
////                        }
////                        self.logExsits = true
////                    }
////                    self.reloadTable()
////                })
////            }
//        }
    }
    
    func reloadTable(){
//        var sWrapper = [StudentWrapper]()
//        if (self.students.count > 0 && self.studentArvInfo.count > 0){
//            if (self.isStaff == true){
//                // use the information from the log
//                for i in 1...self.studentArvInfo.count{
//                    for j in 1...self.students.count{
//                        if (self.students[j-1].studentID == self.studentArvInfo[i-1].studentID){
//                            let newSWrapper = StudentWrapper(student: self.students[j-1], studentArvInfo: self.studentArvInfo[i-1])
//                            sWrapper.append(newSWrapper)
//                        }
//                    }
//                }
//            }else{
//                // handle the case where staff have not yet logged in so some student Arv info is missing
//                for j in 1...self.students.count{
//                    var foundMatch = false
//                    for i in 1...self.studentArvInfo.count{
//                        if (self.students[j-1].studentID == self.studentArvInfo[i-1].studentID){
//                            foundMatch = true
//                            let newSWrapper = StudentWrapper(student: self.students[j-1], studentArvInfo: self.studentArvInfo[i-1])
//                            sWrapper.append(newSWrapper)
//                            continue
//                        }
//                    }
//                    if (foundMatch == false){
//                        // if we did not find matching student arv info we create local ones for parent to view 
//                        var fakeStudentArvInfo = StudentArvInfo(arrived: false, key:"", studentID: self.students[j-1].studentID, staffID: self.students[j-1].staffID)
//                        let newSWrapper = StudentWrapper(student: self.students[j-1], studentArvInfo: fakeStudentArvInfo)
//                        sWrapper.append(newSWrapper)
//                    }
//                }
//            }
//        
//        }
//        self.studentsWrapper = sWrapper
        self.tableView.reloadData()
    }
}

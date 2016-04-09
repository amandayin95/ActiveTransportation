import UIKit
import MessageUI

/*
 * ContactInfoViewController: Controller for detailed info on parents' contact information.
 * Connected by push segue from student list.
 * A student is passed in by segue based on what row in student list is selected.
 * Connects to Firebase to query parents' contact info.
 */

class ContactInfoViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    // MARK: Property passed in through segue
    var studentWprSelected: StudentWrapper!
    var studentSelected:Student!
    var parent:Parent!
    var staff:Staff!
    var isStaff:Bool!
    
    var queryString:String!
    // MARK: DbCommunicator
    var dbComm = DbCommunicator()
    
    // MARK: Parent list fetched from db
    var users = [User!]()
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studentSelected = self.studentWprSelected.student
        if (self.isStaff == true){
            self.queryString = self.studentSelected.parentID
        } else {
            self.queryString = self.studentSelected.staffID
        }

        
        dbComm.usersRef.queryOrderedByChild("uid").queryEqualToValue(self.queryString).observeEventType(.Value, withBlock:{ snapshot in
                // a list to store the parents for the given student
                if (snapshot.hasChildren()){
                    for item in snapshot.children {
                        let user = User(snapshot: item as! FDataSnapshot)
                        self.users.append(user)
                    }
                }
                })
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        
    }
    
    
    // MARK: UITableView Delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactInfoCell")! as UITableViewCell
        
        var contactType : String!
        if (self.isStaff == true){
            contactType = "Parent contact info "
        } else {
            contactType = "Staff contact info "
        }
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = contactType + users[indexPath.row].contactInfo
        
        return cell
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Find the cell that user tapped using cellForRowAtIndexPath
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        // Get the corresponding GreoceryItem by using the index path's row
        var userSelected = users[indexPath.row]
        
        
        var alertTitle = "Contact \(userSelected.name.capitalizedString)"
        var alertMessage = "How do you want to contact \(userSelected.contactInfo)?"
        
        // show an alert and ask whether to call the parent/staff or not
        let alert = UIAlertController(title: alertTitle,
            message: alertMessage ,
            preferredStyle: .Alert)
        
        let callAction = UIAlertAction(title: "Make a Call",
            style: .Default) { (action: UIAlertAction) -> Void in
                self.operation(userSelected.contactInfo, operation: "Call")
        }
        
        let messageAction = UIAlertAction(title: "Send Text Message",
            style: .Default) { (action: UIAlertAction) -> Void in
                self.operation(userSelected.contactInfo, operation: "Text")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addAction(callAction)
        alert.addAction(messageAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    private func operation(phoneNumber:String, operation:String) {
        // check if the phone number string is valid
        var valid = true
        for c in phoneNumber.characters{
            if (!(c >= "0" && c <= "9")) {
                valid = false
                break
            }
        }
        
        if (valid){
            if (operation == "Call"){
                let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)")!
                let application:UIApplication = UIApplication.sharedApplication()
                if (application.canOpenURL(phoneCallURL)) {
                    application.openURL(phoneCallURL);
                }
            }else if (operation == "Text"){
                let alert = UIAlertController(title: "Sending Text Message to \(phoneNumber)",
                    message: "Please enter the text message content below." ,
                    preferredStyle: .Alert)
                
                let sendAction = UIAlertAction(title: "Send",
                    style: .Default) { (action: UIAlertAction) -> Void in
                        // Get the text field from the alert controller
                        let textField = alert.textFields![0] as! UITextField
                        
                        if MFMessageComposeViewController.canSendText(){
                            let msg:MFMessageComposeViewController=MFMessageComposeViewController()
                            msg.recipients=[phoneNumber]
                            msg.body=textField.text
                            msg.messageComposeDelegate = self
                            self.presentViewController(msg,animated:true,completion:nil)
                            
                        } else {
                            print ("cannot send text")
                        }
                }
                        
                
                let cancelAction = UIAlertAction(title: "Cancel",
                    style: .Default) { (action: UIAlertAction) -> Void in
                }

                
                alert.addTextFieldWithConfigurationHandler {
                    (textField: UITextField!) -> Void in
                }

                
                alert.addAction(sendAction)
                alert.addAction(cancelAction)
                
                presentViewController(alert,
                    animated: true,
                    completion: nil)

            }
        }else{
            let alert = UIAlertController(title: "Error",
                message: "The contact information is not valid, please check with system administrator." ,
                preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK",
                style: .Default) { (action: UIAlertAction) -> Void in
            }
            
            alert.addAction(okAction)
            
            presentViewController(alert,
                animated: true,
                completion: nil)

        }
    }
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult){
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue:
            controller.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            controller.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            controller.dismissViewControllerAnimated(false, completion: nil)
            
        default:
            break
        }
}
}

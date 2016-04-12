
import UIKit
import QuartzCore

class LoginViewController: UIViewController {

    // MARK: Constants
    let LoginToList = "LoginToList"

    // MARK: Data passed to StudentListTableView
    var contactInfoToPass: String!
    var nameToPass: String!
    var routeIDToPass: String!
    var isStaffToPass:Bool!

    // MARK: flag for segue identifier
    var signUpMode = false

    // Mark: Communicator with Firebase
    var dbComm = DbCommunicator()


    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!

    // MARK: Properties

    // MARK: UIViewController Lifecycle
    override func viewDidAppear(animated: Bool) {
       signUpMode = false
        // Create an authentication observer
        dbComm.studentsRef.observeAuthEventWithBlock { (authData) -> Void in
            // Block passed the authData parameter
            if authData != nil {
                // On successful authentication, perform the segue. Pass nil as the sender.
                print("auth data before segue? :  " + authData.uid!.lowercaseString + "\n")
                self.performSegueWithIdentifier(self.LoginToList, sender: nil)
            }
        }
        
        super.viewDidAppear(animated)
    }

    // MARK: Actions
    @IBAction func loginDidTouch(sender: AnyObject) {
        dbComm.rootRef.authUser(textFieldLoginEmail.text, password: textFieldLoginPassword.text,
            withCompletionBlock: { (error, auth) in
                
        })
    }

    @IBAction func signUpDidTouch(sender: AnyObject) {
        signUpMode = true
        let alert = UIAlertController(title: "Sign Up",
                                      message: "Sign Up for Active Transporation",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default)
        { (action: UIAlertAction) -> Void in
            let emailField = alert.textFields![0]
            if (self.textFieldLoginEmail.text?.isEmpty != true){
                emailField.text = self.textFieldLoginEmail.text
            }
            let passwordField = alert.textFields![1]
            let nameField = alert.textFields![2]
            let contactInfoField = alert.textFields![3]
            let isStaffField = alert.textFields![4]
            
            self.nameToPass = nameField.text
            self.contactInfoToPass = contactInfoField.text
            self.isStaffToPass = (isStaffField.text?.lowercaseString.containsString("yes"))
            
            // Manually create students.
//            let student1Ref = self.dbComm.studentsRef.childByAutoId()
//            let testStudent1 = ["name":"Amanda_Student1","school":"Pomona"]
//            student1Ref.setValue(testStudent1)
            
            print (emailField.text)
            print (passwordField.text)
            
            self.dbComm.studentsRef.createUser(emailField.text, password: passwordField.text) { (error: NSError!) in
                if error == nil {
                    self.dbComm.rootRef.authUser(emailField.text, password: passwordField.text,
                                                 withCompletionBlock: { (error, auth) -> Void in
                                                    self.performSegueWithIdentifier(self.LoginToList, sender: nil)
                    })
                }
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textEmail) -> Void in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textName) -> Void in
            textName.placeholder = "Enter your name"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textInfo) -> Void in
            textInfo.placeholder = "Enter your contact information"
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textInfo) -> Void in
            textInfo.placeholder = "Enter Yes if Staff, No if Parent"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "LoginToList") {
            let nav = segue.destinationViewController as! UINavigationController
            let svc = nav.topViewController as! StudentListTableViewController
            if (self.signUpMode == true){
                svc.nameToPass = self.nameToPass
                svc.contactInfoToPass = self.contactInfoToPass
                svc.busRouteToPass = self.routeIDToPass
                svc.isStaff = self.isStaffToPass
                svc.signUpMode = self.signUpMode
            }
        }
    }

}


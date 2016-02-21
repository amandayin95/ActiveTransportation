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
import QuartzCore

class LoginViewController: UIViewController {

  // MARK: Constants
  let LoginToList = "LoginToList"
    
  // MARK: Data passed to StudentListTableView
    var contactInfoToPass: String!
    var nameToPass: String!
    var routeIDToPass: String!
    
  // MARK: flag for segue identifier
    var signUpMode = false
    
  // MARK: Ref to database
  let ref = Firebase(url: "https://activetransportation.firebaseio.com")
  let usersRef = Firebase(url: "https://activetransportation.firebaseio.com/users")
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  // MARK: Properties
  
  // MARK: UIViewController Lifecycle
    override func viewDidAppear(animated: Bool) {
       signUpMode = false
        // 1
        ref.observeAuthEventWithBlock { (authData) -> Void in
            // 2
            print("auth data before segue? 1\n")
            if authData != nil {
                // 3
                print("auth data before segue? 2 :  " + authData.uid!.lowercaseString + "\n")
                self.performSegueWithIdentifier(self.LoginToList, sender: nil)
            }
        }
        
        super.viewDidAppear(animated)
    }
    
  // MARK: Actions
    @IBAction func loginDidTouch(sender: AnyObject) {
        ref.authUser(textFieldLoginEmail.text, password: textFieldLoginPassword.text,
            withCompletionBlock: { (error, auth) in
                
        })
    }

  @IBAction func signUpDidTouch(sender: AnyObject) {
    signUpMode = true
    
    var alert = UIAlertController(title: "Sign Up",
      message: "Sign Up for Active Transporation",
      preferredStyle: .Alert)
   
    let saveAction = UIAlertAction(title: "Save",
      style: .Default) { (action: UIAlertAction!) -> Void in
      
      let emailField = alert.textFields![0] as UITextField!
        if (self.textFieldLoginEmail.text?.isEmpty != true){
            emailField.text = self.textFieldLoginEmail.text
        }
      let passwordField = alert.textFields![1] as UITextField!
      let nameField = alert.textFields![2] as UITextField!
      let contactInfoField = alert.textFields![3] as UITextField!
      self.nameToPass = nameField.text
      self.contactInfoToPass = contactInfoField.text
        
        // 1
        self.ref.createUser(emailField.text, password: passwordField.text) { (error: NSError!) in
            // 2
            if error == nil {
                // 3
                self.ref.authUser(emailField.text, password: passwordField.text,
                    withCompletionBlock: { (error, auth) -> Void in
                        
                        
                })
            }
        }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
      style: .Default) { (action: UIAlertAction!) -> Void in
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
            svc.signUpMode = self.signUpMode
            }
        }
    }

}


import UIKit

/*
 * ContactInfoViewController: Controller for detailed info on parents' contact information.
 * Connected by push segue from student list.
 * A student is passed in by segue based on what row in student list is selected.
 * Connects to Firebase to query parents' contact info.
 */

class ContactInfoViewController: UITableViewController {
    
    // MARK: Property passed in through segue
    var studentSelected:Student!
    var user:User!
    var queryString:String!
    // MARK: DbCommunicator
    var dbComm = DbCommunicator()
    
    // MARK: Parent list fetched from db
    var users = [User!]()
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.user.isStaff == true){
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
        if (self.user.isStaff == true){
            contactType = "Parent contact info "
        } else {
            contactType = "Staff contact info "
        }
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = contactType + users[indexPath.row].contactInfo
        
        return cell
        
    }
    
    
}

//
//  ContactInfoViewController.swift
//  ActiveTransportation
//
//  Created by Xiaoyang Qian on 3/5/16.
//
//


import UIKit

class ContactInfoViewController: UITableViewController {
    
    // MARK: Property passed in through segue
    var studentSelected:Student!
    
    // MARK: DbCommunicator
    var dbComm = DbCommunicator()
    
    // MARK: Parent list fetched from db
    var parents = [User!]()
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbComm.usersRef.queryOrderedByChild("uid").queryEqualToValue(self.studentSelected.parentID).observeEventType(.Value, withBlock:{ snapshot in
                // a list to store the parents for the given student
                if (snapshot.hasChildren()){
                    for item in snapshot.children {
                        let parent = User(snapshot: item as! FDataSnapshot)
                        self.parents.append(parent)
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
        return parents.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactInfoCell")! as UITableViewCell
        
        cell.textLabel?.text = parents[indexPath.row].name
        cell.detailTextLabel?.text = parents[indexPath.row].contactInfo
        
        return cell
        
    }
    
    
}

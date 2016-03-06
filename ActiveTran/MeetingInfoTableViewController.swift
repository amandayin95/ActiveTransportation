
import UIKit

class MeetingInfoTableViewController: UITableViewController {
  
    var busRoutes = [BusRoute]()
    var user: User!
    
    // only used when the user is parent
    var childrenForParentView = [Student]()
    
    // Mark: DbCommunicator
    var dbComm = DbCommunicator()
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if (self.user.isStaff == true){
            dbComm.routeRef.queryOrderedByChild("routeID").queryEqualToValue(self.user.routeID).observeEventType(.Value, withBlock: {   snapshot in
                var busRoutesFromDB = [BusRoute]()
                if (snapshot.hasChildren()){
                    for item in snapshot.children {
                        let routeFromDB = BusRoute(snapshot: item as! FDataSnapshot)
                        busRoutesFromDB.append(routeFromDB)
                    }
                }
                self.busRoutes = busRoutesFromDB
            })
        }else if (self.user.isStaff == false){
            for child in childrenForParentView {
                dbComm.routeRef.queryOrderedByChild("routeID").queryEqualToValue(child.routeID).observeEventType(.Value, withBlock: {   snapshot in
                    
                    if (snapshot.hasChildren()){
                        for item in snapshot.children {
                            let routeFromDB = BusRoute(snapshot: item as! FDataSnapshot)
                            self.busRoutes.append(routeFromDB)
                        }
                    }
                })
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }


    // MARK: UITableView Delegate methods
  
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busRoutes.count
    }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MeetingInfoCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MeetingInfoCell")! as! MeetingInfoCell
        
        cell.infoOwnerLabel?.text = "Showing details for AcTran staff member: " + user.name
        cell.meetingLocationLabel?.text = busRoutes[indexPath.row].meetingLocation
        cell.meetingTimeLabel?.text = busRoutes[indexPath.row].meetingTime
    
        return cell
    }

    
}

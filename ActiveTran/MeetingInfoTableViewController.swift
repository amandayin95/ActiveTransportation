
import UIKit

class MeetingInfoTableViewController: UITableViewController {
  
  var busRoutes = [BusRoute]()
  var user: User!
    
  // Mark: DbCommunicator
  var dbComm = DbCommunicator()
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    if (self.user.isStaff == true){
        dbComm.routeRef.queryOrderedByChild("routeID").queryEqualToValue(self.user.routeID).observeEventType(.Value, withBlock: { snapshot in
            var busRoutesFromDB = [BusRoute]()
            if (snapshot.hasChildren()){
                for item in snapshot.children {
                    let routeFromDB = BusRoute(snapshot: item as! FDataSnapshot)
                    busRoutesFromDB.append(routeFromDB)
                }
            }
            self.busRoutes = busRoutesFromDB
        })

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
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MeetingInfoCell")! as UITableViewCell
    
    cell.textLabel?.text = busRoutes[indexPath.row].meetingLocation
    cell.detailTextLabel?.text = busRoutes[indexPath.row].meetingTime
    
    return cell

  }

  
}

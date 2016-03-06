
import UIKit

class MeetingInfoTableViewController: UITableViewController {
    
      
    var busRoutes = [BusRoute]()
    var students = [Student]()
    var user: User!
    
    var meetingInfoWrapperList = [MeetingInfoWrapper]()
    
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
                self.reloadTable()
            })
        }else if (self.user.isStaff == false){
            for item in students {
                dbComm.routeRef.queryOrderedByChild("routeID").queryEqualToValue(item.routeID).observeEventType(.Value, withBlock: {   snapshot in
                    
                    if (snapshot.hasChildren()){
                        for item in snapshot.children {
                            let routeFromDB = BusRoute(snapshot: item as! FDataSnapshot)
                            self.busRoutes.append(routeFromDB)
                        }
                    }
                    self.reloadTable()
                })
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }


    // MARK: UITableView Delegate methods
  
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busRoutes.count
    }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MeetingInfoCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MeetingInfoCell")! as! MeetingInfoCell
        
        if (user.isStaff == true){
            cell.infoOwnerLabel?.text = "Showing details for AcTran staff member: " + user.name
            cell.meetingLocationLabel?.text = busRoutes[indexPath.row].meetingLocation
            cell.meetingTimeLabel?.text = busRoutes[indexPath.row].meetingTime
        }else{
            cell.infoOwnerLabel?.text = "Showing details for student: " + meetingInfoWrapperList[indexPath.row].student.name
            cell.meetingLocationLabel?.text = meetingInfoWrapperList[indexPath.row].busRoute.meetingLocation
            cell.meetingTimeLabel?.text = meetingInfoWrapperList[indexPath.row].busRoute.meetingTime
        }
        return cell
    }

    func reloadTable(){
        
        if (user.isStaff == false){
            var mWrapper = [MeetingInfoWrapper]()
            if (self.students.count > 0 && self.busRoutes.count > 0){
                for i in 1...self.busRoutes.count{
                    for j in 1...self.students.count{
                        if (self.students[j-1].routeID == self.busRoutes[i-1].routeID){
                            let newInfoWrapper = MeetingInfoWrapper(student: self.students[j-1], busRoute: self.busRoutes[i-1])
                            mWrapper.append(newInfoWrapper)
                        }
                        continue
                    }
                }
            }
            self.meetingInfoWrapperList = mWrapper
        }
        self.tableView.reloadData()
    }
}

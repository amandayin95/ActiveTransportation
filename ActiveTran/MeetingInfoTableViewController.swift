
import UIKit
/*
 *  MeetingInfoViewController: Controller for meeting information view
 *  Connected by segue from SutdentListTableViewController.
 *  A staff and a user are passed in by segue.
 *  Connects to Firebase to query busRoute meeting information.
 */
class MeetingInfoTableViewController: UITableViewController {
    
    // MARK: Properties
    var busRoutes = [BusRoute]()
    var students = [Student]()
    var staff:Staff!
    var parent:Parent!
    var isStaff:Bool!
    
    var meetingInfoWrapperList = [MeetingInfoWrapper]()
    
    // MARK: DbCommunicator
    var dbComm = DbCommunicator()
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isStaff == true){
            dbComm.routeRef.queryOrderedByKey().queryEqualToValue(self.staff.routeID).observeEventType(.Value, withBlock: {   snapshot in
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
        } else {
            for student in self.students {
                dbComm.routeRef.queryOrderedByKey().queryEqualToValue(student.routeID).observeEventType(.Value, withBlock: {
                    snapshot in
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
    
    // MARK: ViewDidAppear
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }


    // MARK: UITableView Delegate methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busRoutes.count
    }
    
    // MARK: Display information depending on user type
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MeetingInfoCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MeetingInfoCell")! as! MeetingInfoCell
        
        if (self.isStaff == true){
            cell.infoOwnerLabel?.text = "Showing details for AcTran staff member: " + staff.name
            cell.meetingLocationLabel?.text = busRoutes[indexPath.row].meetingLocation
            cell.meetingTimeLabel?.text = busRoutes[indexPath.row].meetingTime
        }else{
            cell.infoOwnerLabel?.text = "Showing details for student: " + meetingInfoWrapperList[indexPath.row].student.name
            cell.meetingLocationLabel?.text = meetingInfoWrapperList[indexPath.row].busRoute.meetingLocation
            cell.meetingTimeLabel?.text = meetingInfoWrapperList[indexPath.row].busRoute.meetingTime
        }
        return cell
    }
    
    // MARK: Reload table pairs up students with their meeting information for display
    func reloadTable(){
        // For parents, find out the meeting information for all children
        if (self.isStaff == false){
            var mWrapper = [MeetingInfoWrapper]()
            if (self.students.count > 0 && self.busRoutes.count > 0){
                // Loop throuh to pair up students with their busroute
                for i in 1...self.busRoutes.count{
                    for j in 1...self.students.count{
                        if (self.students[j-1].routeID == self.busRoutes[i-1].key){
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

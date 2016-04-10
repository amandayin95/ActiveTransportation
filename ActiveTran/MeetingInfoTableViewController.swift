
import UIKit

class MeetingInfoTableViewController: UITableViewController {
    
      
    var busRoutes = [BusRoute]()
    var students = [Student]()
    var staff:Staff!
    var parent:Parent!
    var isStaff:Bool!
    
    var meetingInfoWrapperList = [MeetingInfoWrapper]()
    
    // Mark: DbCommunicator
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
                print(student)
                dbComm.routeRef.queryOrderedByKey().queryEqualToValue(student.routeID).observeEventType(.Value, withBlock: {   snapshot in
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

    func reloadTable(){
        
        if (self.isStaff == false){
            var mWrapper = [MeetingInfoWrapper]()
            if (self.students.count > 0 && self.busRoutes.count > 0){
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

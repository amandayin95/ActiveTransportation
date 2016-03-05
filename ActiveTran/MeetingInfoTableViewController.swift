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

class MeetingInfoTableViewController: UITableViewController {
  
  var busRoutes = [BusRoute]()
  var user: User!
    
   // Mark: DbCommunicator
   var dbComm = DbCommunicator()
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
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

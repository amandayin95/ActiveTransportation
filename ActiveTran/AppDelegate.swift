import UIKit

let FirebaseUrl = "https://walkingschoolbus.firebaseio.com"
let TappableRed = UIColor(red: 255.0/255.0, green: 167.0/255.0, blue: 127.0/255.0, alpha: 1.0)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  override init() {
    super.init()
    Firebase.defaultConfig().persistenceEnabled = true
  }
    

}


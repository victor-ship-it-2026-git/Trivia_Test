import SwiftUI
import GoogleMobileAds
import FirebaseCore

//Firebase Code Part
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
//Firebase Code Part



@main
struct Trivia_TestApp: App {
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize AdMob
        MobileAds.shared.start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



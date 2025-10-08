import SwiftUI
import GoogleMobileAds

@main
struct Trivia_TestApp: App {
    init() {
        MobileAds.shared.start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

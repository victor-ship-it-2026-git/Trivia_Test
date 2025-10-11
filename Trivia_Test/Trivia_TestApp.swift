import SwiftUI
import GoogleMobileAds
import Firebase
import FirebaseMessaging
import UserNotifications
import AppTrackingTransparency  // ← ADD THIS
import AdSupport  // ← ADD THIS



@main
struct Trivia_TestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var hasRequestedATT = false  // ← ADD THIS
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Request ATT permission after a short delay
                    if !hasRequestedATT {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            requestTrackingPermission()
                            hasRequestedATT = true
                        }
                    }
                }
        }
    }
    private func requestTrackingPermission() {
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        print("✅ Tracking authorized - User accepted")
                        // User accepted tracking - initialize AdMob
                        initializeAdMob()
                        
                    case .denied:
                        print("❌ Tracking denied - User declined")
                        // User declined - still initialize AdMob but with limited ads
                        initializeAdMob()
                        
                    case .notDetermined:
                        print("⚠️ Tracking not determined")
                        
                    case .restricted:
                        print("⚠️ Tracking restricted")
                        initializeAdMob()
                        
                    @unknown default:
                        print("⚠️ Unknown tracking status")
                        initializeAdMob()
                    }
                    
                    // Print IDFA for debugging
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    print("📱 IDFA: \(idfa)")
                }
            }
        } else {
            // iOS 14.4 or earlier - no ATT required
            initializeAdMob()
        }
    }
    
    
class AppDelegate: NSObject, UIApplicationDelegate {
    private var appOpenedTime: Date?
    
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Existing Firebase config
        FirebaseApp.configure()
        
        // ADD THIS: Track app opened
        AnalyticsManager.shared.logAppOpened()
        appOpenedTime = Date()
        
        // ... rest of your code
        return true
    }
    
    // ADD THIS: Track when app goes to background
    func applicationDidEnterBackground(_ application: UIApplication) {
        if let startTime = appOpenedTime {
            let sessionDuration = Date().timeIntervalSince(startTime)
            AnalyticsManager.shared.logAppBackgrounded(sessionDuration: sessionDuration)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        appOpenedTime = Date()
        AnalyticsManager.shared.logAppOpened()
    }
}

    // ← ADD THIS FUNCTION
   
    
    // ← ADD THIS FUNCTION
    private func initializeAdMob() {
        MobileAds.shared.start { status in
            print("✅ AdMob initialized with status: \(status)")
        }
    }
}



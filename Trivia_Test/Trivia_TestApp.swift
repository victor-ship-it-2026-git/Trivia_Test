import SwiftUI
import GoogleMobileAds
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseCrashlytics
import AppTrackingTransparency
import AdSupport



@main
struct Trivia_TestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var hasRequestedATT = false
    

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // To Request ATT permission after a short delay
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
        configureCrashlytics()
        
        // Track app opened
        AnalyticsManager.shared.logAppOpened()
        appOpenedTime = Date()
        
        print("📱 Bundle ID from Info.plist: \(Bundle.main.bundleIdentifier ?? "nil")")

        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let bundleId = dict["BUNDLE_ID"] as? String {
            print("📱 Bundle ID from GoogleService-Info.plist: \(bundleId)")
            
            if bundleId != Bundle.main.bundleIdentifier {
                print("⚠️ WARNING: Bundle IDs don't match!")
            } else {
                print("✅ Bundle IDs match!")
            }
        }

        return true
    }
    private func configureCrashlytics() {
                // Enable Crashlytics collection
                Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
                
                // Set user identifier which helps track crashes per user
                let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
                Crashlytics.crashlytics().setUserID(deviceId)
                
                // Log that Crashlytics is configured
                print("🔥 Firebase Crashlytics configured successfully")
                
                // Optional: Test crash (REMOVE THIS IN PRODUCTION!)
                // Uncomment the line below to test if Crashlytics is working
                // fatalError("Test Crashlytics - This is a test crash!")
            }
    
    // Track when app goes to background
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


   
    
    private func initializeAdMob() {
        MobileAds.shared.start { status in
            print("✅ AdMob initialized with status: \(status)")
        }
    }
    
}





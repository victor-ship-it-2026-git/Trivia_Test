import SwiftUI
import GoogleMobileAds
import Firebase
import FirebaseMessaging
import UserNotifications
import AppTrackingTransparency  // ← ADD THIS
import AdSupport  // ← ADD THIS

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Setup notifications
        Task { @MainActor in
            NotificationManager.shared.setup()
        }
        
        // ⚠️ DON'T START ADMOB HERE - Wait for ATT permission
        
        return true
    }
    
    // ... rest of your code
}

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
    
    // ← ADD THIS FUNCTION
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
    
    // ← ADD THIS FUNCTION
    private func initializeAdMob() {
        MobileAds.shared.start { status in
            print("✅ AdMob initialized with status: \(status)")
        }
    }
}

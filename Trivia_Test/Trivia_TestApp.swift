import SwiftUI
import GoogleMobileAds
import Firebase
import FirebaseAnalytics
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
                    if !hasRequestedATT {
                        // Wait for UI to be fully ready
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            requestTrackingPermission()
                            hasRequestedATT = true
                        }
                    }
                }
        }
    }
    
    private func requestTrackingPermission() {
        if #available(iOS 14.5, *) {
            let currentStatus = ATTrackingManager.trackingAuthorizationStatus
            
            if currentStatus == .notDetermined {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("🔔 Requesting ATT permission...")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        print("✅ ATT Response: \(status.rawValue) (\(status.statusDescription))")
                        
                        // Wait for system to update IDFA
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.checkIDFAStatus()
                            self.initializeAdMob()
                        }
                        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    }
                }
            } else {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📊 ATT already determined: \(currentStatus.statusDescription)")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                checkIDFAStatus()
                initializeAdMob()
            }
        } else {
            print("📊 iOS 14.4 or earlier - No ATT required")
            checkIDFAStatus()
            initializeAdMob()
        }
    }
    
    private func checkIDFAStatus() {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("📱 IDFA CHECK:")
        print("   IDFA: \(idfa)")
        
        if #available(iOS 14.5, *) {
            let attStatus = ATTrackingManager.trackingAuthorizationStatus
            print("   ATT Status: \(attStatus.rawValue) (\(attStatus.statusDescription))")
        }
        
        if idfa == "00000000-0000-0000-0000-000000000000" {
            print("❌ IDFA IS ZEROED")
            if #available(iOS 14.5, *) {
                let attStatus = ATTrackingManager.trackingAuthorizationStatus
                switch attStatus {
                case .denied:
                    print("   → User denied tracking")
                case .authorized:
                    print("   → ATT authorized but IDFA still zeroed!")
                    print("   → Check: GoogleAppMeasurementIdentitySupport linked?")
                    print("   → Check: Settings → Privacy → Apple Advertising → Personalized Ads ON?")
                case .restricted:
                    print("   → Tracking restricted by device policy")
                default:
                    print("   → ATT not determined yet")
                }
            }
        } else {
            print("✅ IDFA AVAILABLE: \(idfa)")
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
    
    private func initializeAdMob() {
        print("🎯 Initializing AdMob SDK...")
        
        MobileAds.shared.start { status in
            print("✅ AdMob SDK Initialized")
            
            Task { @MainActor in
                // CRITICAL: Only NOW initialize AdMobManager
                // This ensures ATT permission was already handled
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("🎯 Initializing AdMobManager...")
                    AdMobManager.shared.initializeAfterATT()
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    private var appOpenedTime: Date?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        print("🚀 ========================================")
        print("🚀 App Starting - iOS \(UIDevice.current.systemVersion)")
        print("🚀 ========================================")
        
        // Configure Firebase
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        
        print("✅ Firebase Configured")
        print("⏳ Waiting for ATT permission...")
        
        configureCrashlytics()
        AnalyticsManager.shared.logAppOpened()
        appOpenedTime = Date()
        
        return true
    }
    
    private func configureCrashlytics() {
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        Crashlytics.crashlytics().setUserID(deviceId)
    }
    
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

@available(iOS 14.5, *)
extension ATTrackingManager.AuthorizationStatus {
    var statusDescription: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized ✅"
        @unknown default: return "Unknown"
        }
    }
}

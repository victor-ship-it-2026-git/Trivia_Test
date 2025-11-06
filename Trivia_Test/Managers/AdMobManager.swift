import GoogleMobileAds
import SwiftUI
internal import Combine
import AppTrackingTransparency
import AdSupport

@MainActor
class AdMobManager: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = AdMobManager()
    
    @Published var isAdReady = false
    @Published var isShowingAd = false
    @Published var trackingStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    
    private var rewardedAd: RewardedAd?
    var onAdDismissed: (() -> Void)?
    var onAdRewarded: (() -> Void)?
    
    // Replace with your Real AdMob Ad Unit ID
    private let adUnitID = "ca-app-pub-2560859326208528/7265988790" // Real ID
    // private let adUnitID = "ca-app-pub-3940256099942544/1712485313"  // Test ID
    
    private var isInitialized = false
    
    override init() {
        super.init()
        // DON'T check tracking or load ads here!
        // Wait for explicit initialization after ATT is granted
        print("📦 AdMobManager created (waiting for ATT permission)")
    }
    
    // MARK: - Initialize After ATT
    func initializeAfterATT() {
        guard !isInitialized else {
            print("⚠️ AdMobManager already initialized")
            return
        }
        
        isInitialized = true
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🎯 AdMobManager: Initializing AFTER ATT")
        
        configureTestDevices()
        checkTrackingStatus()
        loadRewardedAd()
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
    
    // MARK: - Configure Test Devices
    private func configureTestDevices() {
        let requestConfiguration = MobileAds.shared.requestConfiguration
        
        #if targetEnvironment(simulator)
        requestConfiguration.testDeviceIdentifiers = ["SIMULATOR"]
        print("📱 Test Mode: SIMULATOR enabled")
        #else
        requestConfiguration.testDeviceIdentifiers = [
            // "YOUR_DEVICE_TEST_ID_HERE" // Add your device test ID if needed
        ]
        print("📱 Test Mode: Real device")
        #endif
    }
    
    func checkTrackingStatus() {
        if #available(iOS 14.5, *) {
            trackingStatus = ATTrackingManager.trackingAuthorizationStatus
            print("📊 AdMob - ATT Status: \(trackingStatus.rawValue)")
            
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            print("📱 AdMob - IDFA: \(idfa)")
            
            if idfa == "00000000-0000-0000-0000-000000000000" {
                print("⚠️ AdMob - IDFA is zeroed (will use non-personalized ads)")
            } else {
                print("✅ AdMob - IDFA is available (will use personalized ads)")
            }
        }
    }
    
    func loadRewardedAd() {
        let request = Request()
        
        // Set request parameters based on tracking status
        if #available(iOS 14.5, *), trackingStatus == .denied {
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
            print("📢 Requesting non-personalized ads")
        }
        
        print("📥 Loading rewarded ad...")
        print("📥 Ad Unit ID: \(adUnitID)")
        
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    let nsError = error as NSError
                    print("❌ Failed to load rewarded ad")
                    print("❌ Error code: \(nsError.code)")
                    print("❌ Error: \(error.localizedDescription)")
                    
                    self.handleAdLoadError(nsError)
                    
                    CrashlyticsManager.shared.logError(error, additionalInfo: [
                        "ad_unit_id": self.adUnitID,
                        "tracking_status": self.trackingStatus.rawValue,
                        "error_code": nsError.code,
                        "error_domain": nsError.domain
                    ])
                    self.isAdReady = false
                    return
                }
                
                self.rewardedAd = ad
                self.rewardedAd?.fullScreenContentDelegate = self
                self.isAdReady = true
                print("✅ Rewarded ad loaded successfully - Ready: \(self.isAdReady)")
            }
        }
    }
    
    // MARK: - Error Handling
    private func handleAdLoadError(_ error: NSError) {
        switch error.code {
        case 0:
            print("⚠️ Invalid ad request - Check ad unit ID")
        case 1:
            print("⚠️ No ad to show - Ad inventory empty (common in testing)")
            print("💡 This is normal! Ads will work better in production")
        case 2:
            print("⚠️ Network error - Check internet connection")
        case 3:
            print("⚠️ Server error - Ad server issues")
        case 8:
            print("⚠️ Invalid argument - Check ad unit ID format")
        default:
            print("⚠️ Unknown error code: \(error.code)")
        }
    }
    
    func showAd(from viewController: UIViewController) {
        guard let ad = rewardedAd else {
            print("❌ Ad not ready - Loading new ad...")
            isAdReady = false
            loadRewardedAd()
            return
        }
        
        print("🎬 Presenting ad...")
        isShowingAd = true
        ad.present(from: viewController) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                print("✅ User earned reward")
                self.onAdRewarded?()
            }
        }
    }
    
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            print("📱 Ad dismissed")
            self.isShowingAd = false
            self.onAdDismissed?()
            self.loadRewardedAd()
        }
    }
    
    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            print("❌ Ad failed to present: \(error.localizedDescription)")
            CrashlyticsManager.shared.logError(error, additionalInfo: [
                "event": "ad_failed_to_present"
            ])
            
            self.isShowingAd = false
            self.isAdReady = false
            self.loadRewardedAd()
        }
    }
}

@available(iOS 14.5, *)
extension ATTrackingManager.AuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }
}

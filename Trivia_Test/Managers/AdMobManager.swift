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
    
    override init() {
        super.init()
        configureTestDevices()
        checkTrackingStatus()
        loadRewardedAd()
    }
    
    // MARK: - Configure Test Devices
    private func configureTestDevices() {
        let requestConfiguration = MobileAds.shared.requestConfiguration
        
        // For Simulator testing
        #if targetEnvironment(simulator)
        requestConfiguration.testDeviceIdentifiers = ["SIMULATOR"]
        print("📱 Test Mode: SIMULATOR enabled")
        #else
        // For Real Device testing - Add your device's test ID here
        // To find your test device ID, run the app once and check console for:
        // "To get test ads on this device, set: GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = @[ @\"YOUR_DEVICE_ID\" ];"
        requestConfiguration.testDeviceIdentifiers = [
            "AB56990C-0263-4083-8600-7CC9F100A369"
        ]
        print("📱 Test Mode: Real device - Add your test device ID if needed")
        #endif
        
        // Enable debug logging (remove in production)
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers?.forEach { deviceID in
            print("📱 Test Device ID: \(deviceID)")
        }
    }
    
    func checkTrackingStatus() {
        if #available(iOS 14.5, *) {
            trackingStatus = ATTrackingManager.trackingAuthorizationStatus
            print("📊 Current ATT Status: \(trackingStatus.description)")
            
            // Print IDFA for debugging
            let idfa = ASIdentifierManager.shared().advertisingIdentifier
            let idfaString = idfa.uuidString
            print("📱 IDFA: \(idfaString)")
            
            if idfaString == "00000000-0000-0000-0000-000000000000" {
                print("⚠️ IDFA is zeroed out - user denied tracking or limit ad tracking is enabled")
            } else {
                print("✅ IDFA is available for ad targeting")
            }
        }
    }
    
    func loadRewardedAd() {
        let request = Request()
        
        // Set request parameters based on tracking status
        if #available(iOS 14.5, *), trackingStatus == .denied {
            // User denied tracking - request non-personalized ads
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
            print("📢 Requesting non-personalized ads")
        }
        
        print("📥 Starting to load rewarded ad...")
        print("📥 Ad Unit ID: \(adUnitID)")
        
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    let nsError = error as NSError
                    print("❌ Failed to load rewarded ad")
                    print("❌ Error code: \(nsError.code)")
                    print("❌ Error domain: \(nsError.domain)")
                    print("❌ Error description: \(error.localizedDescription)")
                    
                    // Log specific error codes
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
        // GADErrorCode enum values
        switch error.code {
        case 0: // kGADErrorInvalidRequest
            print("⚠️ Invalid ad request - Check ad unit ID and request parameters")
        case 1: // kGADErrorNoFill
            print("⚠️ No ad to show - Ad inventory is empty. This is common in testing.")
            print("💡 Try using test ads or wait a few minutes")
        case 2: // kGADErrorNetworkError
            print("⚠️ Network error - Check internet connection")
        case 3: // kGADErrorServerError
            print("⚠️ Server error - Ad server is having issues")
        case 8: // kGADErrorInvalidArgument
            print("⚠️ Invalid argument - Check ad unit ID format")
        case 9: // kGADErrorReceivedInvalidResponse
            print("⚠️ Invalid response from ad server")
        case 10: // kGADErrorMediationDataError
            print("⚠️ Mediation data error")
        case 11: // kGADErrorMediationAdapterError
            print("⚠️ Mediation adapter error")
        case 15: // kGADErrorTimeout
            print("⚠️ Ad request timed out")
        default:
            print("⚠️ Unknown error code: \(error.code)")
        }
        
        // Check if this is a test device issue
        if error.code == 0 {
            print("💡 If testing on a real device, add your test device ID:")
            print("💡 1. Check console for 'To get test ads on this device' message")
            print("💡 2. Add the ID to testDeviceIdentifiers array in configureTestDevices()")
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

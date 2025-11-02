
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
    
    // Replace this with Real Admob Ad Unit ID
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"  // This is Admob Test ID
    
    override init() {
        super.init()
        checkTrackingStatus()
        loadRewardedAd()
    }
    
    func checkTrackingStatus() {
        if #available(iOS 14.5, *) {
            trackingStatus = ATTrackingManager.trackingAuthorizationStatus
            print("📊 Current ATT Status: \(trackingStatus.description)")
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
        
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    print("Failed to load rewarded ad: \(error.localizedDescription)")
                    CrashlyticsManager.shared.logError(error, additionalInfo: [
                                   "ad_unit_id": self.adUnitID,
                                   "tracking_status": self.trackingStatus.rawValue
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

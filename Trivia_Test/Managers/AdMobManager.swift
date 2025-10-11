//
//  AdMobManager.swift
//

import GoogleMobileAds
import SwiftUI
internal import Combine
import AppTrackingTransparency  // ← ADD THIS
import AdSupport  // ← ADD THIS

@MainActor
class AdMobManager: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = AdMobManager()
    
    @Published var isAdReady = false
    @Published var isShowingAd = false
    @Published var trackingStatus: ATTrackingManager.AuthorizationStatus = .notDetermined  // ← ADD THIS
    
    private var rewardedAd: RewardedAd?
    var onAdDismissed: (() -> Void)?
    var onAdRewarded: (() -> Void)?
    
    // Replace with your REAL Ad Unit ID before submission
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"  // TEST ID
    
    override init() {
        super.init()
        checkTrackingStatus()  // ← ADD THIS
        loadRewardedAd()
    }
    
    // ← ADD THIS FUNCTION
    func checkTrackingStatus() {
        if #available(iOS 14.5, *) {
            trackingStatus = ATTrackingManager.trackingAuthorizationStatus
            print("📊 Current ATT Status: \(trackingStatus.description)")
        }
    }
    
    func loadRewardedAd() {
        let request = Request()
        
        // ← ADD THIS: Set request parameters based on tracking status
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
    
    // MARK: - GADFullScreenContentDelegate
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

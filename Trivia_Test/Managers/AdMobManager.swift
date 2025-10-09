//
//  AdMobManager.swift
//

import GoogleMobileAds
import SwiftUI
internal import Combine

@MainActor
class AdMobManager: NSObject, ObservableObject, FullScreenContentDelegate {
    static let shared = AdMobManager()
    
    @Published var isAdReady = false
    @Published var isShowingAd = false
    private var rewardedAd: RewardedAd?
    var onAdDismissed: (() -> Void)?
    var onAdRewarded: (() -> Void)?
    
    // Test Ad Unit ID - Replace with your real ID in production
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    override init() {
        super.init()
        loadRewardedAd()
    }
    
    func loadRewardedAd() {
        let request = Request()
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

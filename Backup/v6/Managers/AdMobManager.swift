//
//  AdMobManager.swift
//

import GoogleMobileAds
import SwiftUI
internal import Combine

class AdMobManager: NSObject, ObservableObject, FullScreenContentDelegate {


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
            if let error = error {
                print("Failed to load rewarded ad: \(error.localizedDescription)")
                self?.isAdReady = false
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            self?.isAdReady = true
            print("Rewarded ad loaded successfully")
        }
    }
    
    func showAd(from viewController: UIViewController) {
        guard let ad = rewardedAd else {
            print("Ad not ready")
            isAdReady = false
            loadRewardedAd()
            return
        }
        
        isShowingAd = true
        ad.present(from: viewController) { [weak self] in
            print("User earned reward")
            self?.onAdRewarded?()
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad dismissed")
        isShowingAd = false
        onAdDismissed?()
        loadRewardedAd()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        isShowingAd = false
        isAdReady = false
        loadRewardedAd()
    }
}

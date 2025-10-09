//
//  RatingManager.swift
//  Trivia_Test
//
//  Created by Win on [Date]
//

import Foundation
import StoreKit
internal import Combine

class RatingManager: ObservableObject {
    static let shared = RatingManager()
    private let defaults = UserDefaults.standard
    private let hasRatedKey = "has_rated_app"
    private let easyModeCompletedKey = "easy_mode_completed_count"
    
    @Published var shouldShowRating = false
    
    private init() {}
    
    func checkAndShowRating(difficulty: Difficulty) {
        // Only show for Rookie mode
        guard difficulty == .rookie else { return }
        
        // Check if user has already rated
        guard !defaults.bool(forKey: hasRatedKey) else { return }
        
        // Increment completion count
        let completionCount = defaults.integer(forKey: easyModeCompletedKey) + 1
        defaults.set(completionCount, forKey: easyModeCompletedKey)
        
        // Show rating after first Rookie mode completion
        if completionCount == 1 {
            shouldShowRating = true
        }
    }
    
    func userRatedApp() {
        defaults.set(true, forKey: hasRatedKey)
        shouldShowRating = false
    }
    
    func requestAppStoreReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
        userRatedApp()
    }
    
    func resetRating() {
        // For testing purposes only - remove in production
        defaults.set(false, forKey: hasRatedKey)
        defaults.set(0, forKey: easyModeCompletedKey)
    }
}

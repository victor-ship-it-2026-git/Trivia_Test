//
//  AnalyticsManager.swift
//  Trivia_Test
//
//  Created by Win on 11/10/2568 BE.
//


//
//  AnalyticsManager.swift
//  Trivia_Test
//
//  Created by Win
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {
        print("📊 Analytics Manager initialized")
    }
    
    // MARK: - Screen Views
    
    func logScreenView(screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenName
        ])
        print("📱 Screen View: \(screenName)")
    }
    
    // MARK: - Category Selection
    
    func logCategorySelected(category: QuizCategory) {
        Analytics.logEvent("category_selected", parameters: [
            "category_name": category.rawValue,
            "category_emoji": category.emoji
        ])
        print("🎯 Category Selected: \(category.rawValue)")
    }
    
    func logCategoryClicked(category: QuizCategory) {
        Analytics.logEvent("category_clicked", parameters: [
            "category_name": category.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ])
        print("👆 Category Clicked: \(category.rawValue)")
    }
    
    // MARK: - Difficulty Selection
    
    func logDifficultySelected(difficulty: Difficulty, category: QuizCategory) {
        Analytics.logEvent("difficulty_selected", parameters: [
            "difficulty_level": difficulty.rawValue,
            "category": category.rawValue,
            "difficulty_emoji": difficulty.emoji
        ])
        print("⚡️ Difficulty Selected: \(difficulty.rawValue) for \(category.rawValue)")
    }
    
    // MARK: - Quiz Completion
    
    func logQuizStarted(category: QuizCategory, difficulty: Difficulty, totalQuestions: Int) {
        Analytics.logEvent("quiz_started", parameters: [
            "category": category.rawValue,
            "difficulty": difficulty.rawValue,
            "total_questions": totalQuestions,
            "timestamp": Date().timeIntervalSince1970
        ])
        print("🎮 Quiz Started: \(category.rawValue) - \(difficulty.rawValue)")
    }
    
    func logQuizCompleted(
        category: QuizCategory,
        difficulty: Difficulty,
        score: Int,
        totalQuestions: Int,
        percentage: Int,
        timeSpent: TimeInterval
    ) {
        Analytics.logEvent("quiz_completed", parameters: [
            "category": category.rawValue,
            "difficulty": difficulty.rawValue,
            "score": score,
            "total_questions": totalQuestions,
            "percentage": percentage,
            "time_spent_seconds": Int(timeSpent),
            "success": percentage >= 70 // 70% or higher is success
        ])
        print("✅ Quiz Completed: \(category.rawValue) - \(difficulty.rawValue) - Score: \(score)/\(totalQuestions)")
    }
    
    func logQuizAbandoned(
        category: QuizCategory,
        difficulty: Difficulty,
        questionNumber: Int,
        totalQuestions: Int
    ) {
        Analytics.logEvent("quiz_abandoned", parameters: [
            "category": category.rawValue,
            "difficulty": difficulty.rawValue,
            "question_reached": questionNumber,
            "total_questions": totalQuestions,
            "completion_percentage": Int((Double(questionNumber) / Double(totalQuestions)) * 100)
        ])
        print("❌ Quiz Abandoned: \(category.rawValue) at question \(questionNumber)")
    }
    
    // MARK: - Question Interactions
    
    func logQuestionAnswered(
        isCorrect: Bool,
        questionNumber: Int,
        category: QuizCategory,
        difficulty: Difficulty,
        timeSpent: TimeInterval
    ) {
        Analytics.logEvent("question_answered", parameters: [
            "is_correct": isCorrect,
            "question_number": questionNumber,
            "category": category.rawValue,
            "difficulty": difficulty.rawValue,
            "time_spent_seconds": Int(timeSpent)
        ])
        print("💡 Question Answered: \(isCorrect ? "✅" : "❌")")
    }
    
    // MARK: - Lifeline Usage
    
    func logLifelineUsed(
        lifelineType: LifelineType,
        questionNumber: Int,
        category: QuizCategory,
        difficulty: Difficulty
    ) {
        Analytics.logEvent("lifeline_used", parameters: [
            "lifeline_type": lifelineType.rawValue,
            "question_number": questionNumber,
            "category": category.rawValue,
            "difficulty": difficulty.rawValue
        ])
        print("💡 Lifeline Used: \(lifelineType.rawValue)")
    }
    
    func logLifelinePurchased(lifelineType: LifelineType, quantity: Int, cost: Int) {
        Analytics.logEvent("lifeline_purchased", parameters: [
            "lifeline_type": lifelineType.rawValue,
            "quantity": quantity,
            "cost_coins": cost
        ])
        print("🛒 Lifeline Purchased: \(quantity)x \(lifelineType.rawValue) for \(cost) coins")
    }
    
    // MARK: - Results Screen
    
    func logResultsScreenViewed(
        category: QuizCategory,
        difficulty: Difficulty,
        score: Int,
        totalQuestions: Int,
        percentage: Int
    ) {
        Analytics.logEvent("results_screen_viewed", parameters: [
            "category": category.rawValue,
            "difficulty": difficulty.rawValue,
            "score": score,
            "total_questions": totalQuestions,
            "percentage": percentage
        ])
        print("📊 Results Screen Viewed: \(percentage)%")
    }
    
    func logScoreSavedToLeaderboard(
        playerName: String,
        category: QuizCategory,
        difficulty: Difficulty,
        score: Int,
        totalQuestions: Int,
        percentage: Int
    ) {
        Analytics.logEvent("score_saved_to_leaderboard", parameters: [
            "player_name_length": playerName.count, // Don't log actual name for privacy
            "is_anonymous": playerName.isEmpty || playerName == "Anonymous",
            "category": category.rawValue,
            "difficulty": difficulty.rawValue,
            "score": score,
            "total_questions": totalQuestions,
            "percentage": percentage
        ])
        print("🏆 Score Saved to Leaderboard: \(percentage)%")
    }
    
    // MARK: - Sharing
    
    func logShareInitiated(
        shareType: String, // "results" or "leaderboard"
        category: QuizCategory? = nil,
        difficulty: Difficulty? = nil,
        score: Int? = nil
    ) {
        var parameters: [String: Any] = [
            "share_type": shareType
        ]
        
        if let category = category {
            parameters["category"] = category.rawValue
        }
        if let difficulty = difficulty {
            parameters["difficulty"] = difficulty.rawValue
        }
        if let score = score {
            parameters["score"] = score
        }
        
        Analytics.logEvent("share_initiated", parameters: parameters)
        print("📤 Share Initiated: \(shareType)")
    }
    
    func logShareCompleted(
        shareType: String,
        method: String? = nil // "instagram", "twitter", "messages", etc.
    ) {
        var parameters: [String: Any] = [
            "share_type": shareType
        ]
        
        if let method = method {
            parameters["share_method"] = method
        }
        
        Analytics.logEvent(AnalyticsEventShare, parameters: parameters)
        print("✅ Share Completed: \(shareType)")
    }
    
    func logShareCancelled(shareType: String) {
        Analytics.logEvent("share_cancelled", parameters: [
            "share_type": shareType
        ])
        print("❌ Share Cancelled: \(shareType)")
    }
    
    // MARK: - Rating
    
    func logRatingPopupShown(difficulty: Difficulty) {
        Analytics.logEvent("rating_popup_shown", parameters: [
            "difficulty_completed": difficulty.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ])
        print("⭐️ Rating Popup Shown")
    }
    
    func logRatingGiven(stars: Int, showedAppStoreReview: Bool) {
        Analytics.logEvent("rating_given", parameters: [
            "stars": stars,
            "showed_app_store_review": showedAppStoreReview
        ])
        print("⭐️ Rating Given: \(stars) stars")
    }
    
    func logRatingDismissed() {
        Analytics.logEvent("rating_dismissed", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
        print("❌ Rating Dismissed")
    }
    
    // MARK: - Leaderboard
    
    func logLeaderboardViewed(filter: String = "all") {
        Analytics.logEvent("leaderboard_viewed", parameters: [
            "filter": filter
        ])
        print("🏆 Leaderboard Viewed: \(filter)")
    }
    
    func logLeaderboardEntryShared(rank: Int) {
        Analytics.logEvent("leaderboard_entry_shared", parameters: [
            "rank": rank
        ])
        print("📤 Leaderboard Entry Shared: Rank #\(rank)")
    }
    
    // MARK: - Shop
    
    func logShopViewed() {
        Analytics.logEvent("shop_viewed", parameters: [:])
        print("🛒 Shop Viewed")
    }
    
    func logAdWatchedForReward(rewardType: LifelineType) {
        Analytics.logEvent("ad_watched_for_reward", parameters: [
            "reward_type": rewardType.rawValue
        ])
        print("📺 Ad Watched for Reward: \(rewardType.rawValue)")
    }
    
    func logAdFailedToLoad(adType: String, error: String) {
        Analytics.logEvent("ad_failed_to_load", parameters: [
            "ad_type": adType,
            "error": error
        ])
        print("❌ Ad Failed to Load: \(error)")
    }
    
    // MARK: - Daily Challenge
    
    func logDailyChallengeViewed(challengeType: String) {
        Analytics.logEvent("daily_challenge_viewed", parameters: [
            "challenge_type": challengeType
        ])
        print("📅 Daily Challenge Viewed: \(challengeType)")
    }
    
    func logDailyChallengeCompleted(
        challengeType: String,
        rewardCoins: Int,
        rewardLifelines: [String: Int]
    ) {
        var parameters: [String: Any] = [
            "challenge_type": challengeType,
            "reward_coins": rewardCoins
        ]
        
        for (lifeline, quantity) in rewardLifelines {
            parameters["reward_\(lifeline)"] = quantity
        }
        
        Analytics.logEvent("daily_challenge_completed", parameters: parameters)
        print("✅ Daily Challenge Completed: \(challengeType)")
    }
    
    // MARK: - Difficulty Unlocked
    
    func logDifficultyUnlocked(
        difficulty: Difficulty,
        category: QuizCategory,
        previousScore: Int
    ) {
        Analytics.logEvent("difficulty_unlocked", parameters: [
            "difficulty": difficulty.rawValue,
            "category": category.rawValue,
            "unlock_score_percentage": previousScore
        ])
        print("🔓 Difficulty Unlocked: \(difficulty.rawValue) for \(category.rawValue)")
    }
    
    // MARK: - Notifications
    
    func logNotificationPermissionRequested() {
        Analytics.logEvent("notification_permission_requested", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
        print("🔔 Notification Permission Requested")
    }
    
    func logNotificationPermissionResponse(granted: Bool) {
        Analytics.logEvent("notification_permission_response", parameters: [
            "granted": granted
        ])
        print("🔔 Notification Permission: \(granted ? "Granted" : "Denied")")
    }
    
    // MARK: - Question Reporting
    
    func logQuestionReported(
        reason: String,
        category: QuizCategory,
        difficulty: Difficulty
    ) {
        Analytics.logEvent("question_reported", parameters: [
            "report_reason": reason,
            "category": category.rawValue,
            "difficulty": difficulty.rawValue
        ])
        print("⚠️ Question Reported: \(reason)")
    }
    
    // MARK: - User Engagement
    
    func logAppOpened() {
        Analytics.logEvent("app_opened", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
        print("🚀 App Opened")
    }
    
    func logAppBackgrounded(sessionDuration: TimeInterval) {
        Analytics.logEvent("app_backgrounded", parameters: [
            "session_duration_seconds": Int(sessionDuration)
        ])
        print("💤 App Backgrounded - Session: \(Int(sessionDuration))s")
    }
    
    // MARK: - Onboarding
    
    func logOnboardingCompleted() {
        Analytics.logEvent("onboarding_completed", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
        print("✅ Onboarding Completed")
    }
    
    func logOnboardingSkipped(atPage: Int) {
        Analytics.logEvent("onboarding_skipped", parameters: [
            "page_number": atPage
        ])
        print("⏭ Onboarding Skipped at page \(atPage)")
    }
    
    // MARK: - Custom Events
    
    func logCustomEvent(eventName: String, parameters: [String: Any] = [:]) {
        Analytics.logEvent(eventName, parameters: parameters)
        print("📊 Custom Event: \(eventName)")
    }
    
    // MARK: - User Properties
    
    func setUserProperty(value: String?, forName: String) {
        Analytics.setUserProperty(value, forName: forName)
        print("👤 User Property Set: \(forName) = \(value ?? "nil")")
    }
    
    func setFavoriteCategory(_ category: QuizCategory) {
        setUserProperty(value: category.rawValue, forName: "favorite_category")
    }
    
    func setHighestDifficultyCompleted(_ difficulty: Difficulty) {
        setUserProperty(value: difficulty.rawValue, forName: "highest_difficulty")
    }
    
    func setTotalQuizzesCompleted(_ count: Int) {
        setUserProperty(value: String(count), forName: "total_quizzes_completed")
    }
}

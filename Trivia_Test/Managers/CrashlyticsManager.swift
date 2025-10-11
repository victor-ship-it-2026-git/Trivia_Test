//
//  CrashlyticsManager.swift
//  Trivia_Test
//
//  Created by Win on 11/10/2568 BE.
//


//
//  CrashlyticsManager.swift
//  Trivia_Test
//
//  Created by Win
//

import Foundation
import FirebaseCrashlytics

class CrashlyticsManager {
    static let shared = CrashlyticsManager()
    
    private init() {}
    
    // MARK: - Log Non-Fatal Errors
    
    /// Log a non-fatal error to Crashlytics
    func logError(_ error: Error, additionalInfo: [String: Any]? = nil) {
        let nsError = error as NSError
        Crashlytics.crashlytics().record(error: nsError)
        
        if let info = additionalInfo {
            for (key, value) in info {
                Crashlytics.crashlytics().setCustomValue(value, forKey: key)
            }
        }
        
        print("🔥 Logged error to Crashlytics: \(error.localizedDescription)")
    }
    
    // MARK: - Log Custom Messages
    
    /// Log a custom message to Crashlytics (appears in crash breadcrumbs)
    func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
        print("🔥 Crashlytics log: \(message)")
    }
    
    // MARK: - Set User Information
    
    func setUserID(_ userID: String) {
        Crashlytics.crashlytics().setUserID(userID)
    }
    
    func setUserEmail(_ email: String) {
        Crashlytics.crashlytics().setCustomValue(email, forKey: "email")
    }
    
    func setUserName(_ name: String) {
        Crashlytics.crashlytics().setCustomValue(name, forKey: "username")
    }
    
    // MARK: - Set Custom Keys
    
    func setCustomValue(_ value: Any, forKey key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    // MARK: - Game-Specific Tracking
    
    func logQuizStarted(category: String, difficulty: String) {
        setCustomValue(category, forKey: "current_category")
        setCustomValue(difficulty, forKey: "current_difficulty")
        log("Quiz started: \(category) - \(difficulty)")
    }
    
    func logQuizCompleted(score: Int, totalQuestions: Int) {
        log("Quiz completed: \(score)/\(totalQuestions)")
    }
    
    func logLifelineUsed(_ lifeline: String) {
        log("Lifeline used: \(lifeline)")
    }
    
    func logAdEvent(_ event: String) {
        log("Ad event: \(event)")
    }
}

//
//  NotificationManager.swift
//  Trivia_Test
//
//  Created by Win
//

import Foundation
import Firebase
import FirebaseMessaging
import FirebaseAuth  // ← ADD THIS
import FirebaseDatabase  // ← ADD THIS
import UserNotifications
internal import Combine

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var fcmToken: String?
    @Published var notificationPermissionGranted = false
    
    private let defaults = UserDefaults.standard
    private let fcmTokenKey = "fcm_token"
    
    override init() {
        super.init()
        loadStoredToken()
    }
    
    // MARK: - Setup
    
    func setup() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        checkNotificationPermission()
    }
    
    // MARK: - Request Permission
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            Task { @MainActor in
                self?.notificationPermissionGranted = granted
                
                if granted {
                    print("✅ Notification permission granted")
                    UIApplication.shared.registerForRemoteNotifications()
                } else if let error = error {
                    print("❌ Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            Task { @MainActor in
                self?.notificationPermissionGranted = settings.authorizationStatus == .authorized
                
                if settings.authorizationStatus == .authorized {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // MARK: - Token Management
    
    private func loadStoredToken() {
        fcmToken = defaults.string(forKey: fcmTokenKey)
    }
    
    private func saveToken(_ token: String) {
        fcmToken = token
        defaults.set(token, forKey: fcmTokenKey)
        print("✅ FCM Token saved: \(token)")
    }
    
    // MARK: - Subscribe to Topics
    
    func subscribeToTopic(_ topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("❌ Error subscribing to topic \(topic): \(error.localizedDescription)")
            } else {
                print("✅ Subscribed to topic: \(topic)")
            }
        }
    }
    
    func unsubscribeFromTopic(_ topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("❌ Error unsubscribing from topic \(topic): \(error.localizedDescription)")
            } else {
                print("✅ Unsubscribed from topic: \(topic)")
            }
        }
    }
    
    // MARK: - Default Topics
    
    func subscribeToDefaultTopics() {
        subscribeToTopic("all_users")
        subscribeToTopic("daily_challenge")
        subscribeToTopic("new_questions")
    }
    
    // MARK: - Send Token to Server (Optional)
    
    func sendTokenToServer(_ token: String) {
        // Option 1: Anonymous save (without Auth)
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        let database = Database.database().reference()
        database.child("user_tokens").child(deviceId).setValue([
            "fcm_token": token,
            "platform": "ios",
            "timestamp": Date().timeIntervalSince1970
        ]) { error, _ in
            if let error = error {
                print("❌ Error saving token to server: \(error.localizedDescription)")
            } else {
                print("✅ Token saved to server")
            }
        }
        
        // Option 2: If you implement Firebase Auth later, use this:
        /*
        if let userId = Auth.auth().currentUser?.uid {
            let database = Database.database().reference()
            database.child("user_tokens").child(userId).setValue([
                "fcm_token": token,
                "platform": "ios",
                "timestamp": Date().timeIntervalSince1970
            ]) { error, _ in
                if let error = error {
                    print("❌ Error saving token to server: \(error.localizedDescription)")
                } else {
                    print("✅ Token saved to server")
                }
            }
        }
        */
    }
    
    // MARK: - Local Notifications (for testing)
    
    func scheduleLocalNotification(title: String, body: String, delay: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling local notification: \(error.localizedDescription)")
            } else {
                print("✅ Local notification scheduled")
            }
        }
    }
    
    // MARK: - Badge Management
    
    func clearBadge() {
        Task { @MainActor in
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("📬 Notification received (foreground): \(userInfo)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("👆 Notification tapped: \(userInfo)")
        
        Task { @MainActor in
            // Handle notification action based on type
            if let notificationType = userInfo["type"] as? String {
                handleNotificationAction(type: notificationType, userInfo: userInfo)
            }
        }
        
        completionHandler()
    }
    
    private func handleNotificationAction(type: String, userInfo: [AnyHashable: Any]) {
        switch type {
        case "daily_challenge":
            // Navigate to daily challenge
            NotificationCenter.default.post(name: .showDailyChallenge, object: nil)
            
        case "new_questions":
            // Navigate to specific category
            if let category = userInfo["category"] as? String {
                NotificationCenter.default.post(
                    name: .showCategory,
                    object: nil,
                    userInfo: ["category": category]
                )
            }
            
        case "leaderboard":
            // Navigate to leaderboard
            NotificationCenter.default.post(name: .showLeaderboard, object: nil)
            
        default:
            print("Unknown notification type: \(type)")
        }
    }
}

// MARK: - MessagingDelegate

extension NotificationManager: MessagingDelegate {
    
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        Task { @MainActor in
            print("✅ FCM Token: \(fcmToken)")
            self.saveToken(fcmToken)
            self.sendTokenToServer(fcmToken)
            self.subscribeToDefaultTopics()
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let showDailyChallenge = Notification.Name("showDailyChallenge")
    static let showCategory = Notification.Name("showCategory")
    static let showLeaderboard = Notification.Name("showLeaderboard")
}

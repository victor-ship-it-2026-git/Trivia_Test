import Foundation
import Firebase
import FirebaseMessaging
import FirebaseAuth
import FirebaseDatabase
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
    
    // Setup
    
    func setup() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        checkNotificationPermission()
    }
    
    //  Request Permission
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.notificationPermissionGranted = granted
                AnalyticsManager.shared.logNotificationPermissionResponse(granted: granted)

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
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
                
                if settings.authorizationStatus == .authorized {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // Token Management
    
    private func loadStoredToken() {
        fcmToken = defaults.string(forKey: fcmTokenKey)
    }
    
    private func saveToken(_ token: String) {
        fcmToken = token
        defaults.set(token, forKey: fcmTokenKey)
        print("✅ FCM Token saved: \(token)")
    }
    
    // Subscribe to Topics
    
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
    
    // Default Topics
    
    func subscribeToDefaultTopics() {
        subscribeToTopic("all_users")
        subscribeToTopic("daily_challenge")
        subscribeToTopic("new_questions")
    }
    
    // Send Token to Server (Optional)
    
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
        
        // Option 2: For firebase auth later.
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
    
    // Local Notifications (for testing)
    
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
    
    // Badge Management
    
    func clearBadge() {
        Task { @MainActor in
            UNUserNotificationCenter.current().setBadgeCount(0) { error in
                if let error = error {
                    print("❌ Error clearing badge: \(error.localizedDescription)")
                }
            }
        }
    }
}

// UNUserNotificationCenterDelegate

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
        
        // Convert to Sendable dictionary
        let userInfoDict = userInfo.reduce(into: [String: Any]()) { result, element in
            if let key = element.key as? String {
                result[key] = element.value
            }
        }
        
        Task { @MainActor in
            // Handle notification action based on type
            if let notificationType = userInfoDict["type"] as? String {
                self.handleNotificationAction(type: notificationType, userInfo: userInfoDict)
            }
        }
        
        completionHandler()
    }
    
    private func handleNotificationAction(type: String, userInfo: [String: Any]) {
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

// MessagingDelegate

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

// Notification Names

extension Notification.Name {
    static let showDailyChallenge = Notification.Name("showDailyChallenge")
    static let showCategory = Notification.Name("showCategory")
    static let showLeaderboard = Notification.Name("showLeaderboard")
}

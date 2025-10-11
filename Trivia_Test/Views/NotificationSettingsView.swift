//
//  NotificationSettingsView.swift
//  Trivia_Test
//
//  Created by Win
//

import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var dailyChallengeEnabled = true
    @State private var newQuestionsEnabled = true
    @State private var leaderboardEnabled = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dynamicBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Text("🔔")
                                .font(.system(size: 60))
                            
                            Text("Notifications")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.dynamicText)
                            
                            Text(notificationManager.notificationPermissionGranted ?
                                "Stay updated with the latest challenges!" :
                                "Enable notifications to never miss out!")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Permission Section
                        if !notificationManager.notificationPermissionGranted {
                            VStack(spacing: 15) {
                                Text("Enable Push Notifications")
                                    .font(.headline)
                                    .foregroundColor(.dynamicText)
                                
                                Button(action: {
                                    notificationManager.requestNotificationPermission()
                                }) {
                                    HStack {
                                        Image(systemName: "bell.badge.fill")
                                        Text("Enable Notifications")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(28)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.1))
                            )
                            .padding(.horizontal)
                        }
                        
                        // Notification Preferences
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Notification Preferences")
                                .font(.headline)
                                .foregroundColor(.dynamicText)
                                .padding(.horizontal)
                            
                            NotificationToggle(
                                icon: "calendar.badge.clock",
                                title: "Daily Challenge",
                                description: "Get notified about new daily challenges",
                                isEnabled: $dailyChallengeEnabled,
                                topic: "daily_challenge"
                            )
                            
                            NotificationToggle(
                                icon: "questionmark.circle.fill",
                                title: "New Questions",
                                description: "Be the first to try new quiz questions",
                                isEnabled: $newQuestionsEnabled,
                                topic: "new_questions"
                            )
                            
                            NotificationToggle(
                                icon: "trophy.fill",
                                title: "Leaderboard Updates",
                                description: "Stay updated on your ranking",
                                isEnabled: $leaderboardEnabled,
                                topic: "leaderboard"
                            )
                        }
                        
                        // Test Notification (Debug)
                        #if DEBUG
                        Button(action: {
                            notificationManager.scheduleLocalNotification(
                                title: "Test Notification",
                                body: "This is a test notification from Trivia App!"
                            )
                        }) {
                            Text("Send Test Notification")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .padding()
                        }
                        #endif
                        
                        // FCM Token (Debug)
                        #if DEBUG
                        if let token = notificationManager.fcmToken {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("FCM Token:")
                                    .font(.caption)
                                    .foregroundColor(.dynamicSecondaryText)
                                
                                Text(token)
                                    .font(.caption2)
                                    .foregroundColor(.dynamicSecondaryText)
                                    .lineLimit(3)
                                    .textSelection(.enabled)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.dynamicCardBackground)
                            )
                            .padding(.horizontal)
                        }
                        #endif
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

// MARK: - Notification Toggle

struct NotificationToggle: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    let topic: String
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.dynamicText)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.dynamicSecondaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .disabled(!notificationManager.notificationPermissionGranted)
                .onChange(of: isEnabled) { oldValue, newValue in
                    if newValue {
                        notificationManager.subscribeToTopic(topic)
                    } else {
                        notificationManager.unsubscribeFromTopic(topic)
                    }
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 3)
        )
        .padding(.horizontal)
        .opacity(notificationManager.notificationPermissionGranted ? 1.0 : 0.5)
    }
}

// MARK: - Preview

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
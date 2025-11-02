
import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var dailyChallengeEnabled = true
    @State private var newQuestionsEnabled = true
    @State private var leaderboardEnabled = true
    @State private var showTokenCopied = false
    
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
                        
                        // Test Notification Button
                      /*  Button(action: {
                            notificationManager.scheduleLocalNotification(
                                title: "🎉 Test Notification",
                                body: "This is a test notification from Trivia App! It will appear in 5 seconds.",
                                delay: 5
                            )
                        } ) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send Test Notification (5s)")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(24)
                            .shadow(color: Color.orange.opacity(0.3), radius: 5)
                        }
                        .padding(.horizontal)*/
                        
                        // FCM Token Section - PROMINENTLY DISPLAYED
                        /*  if let token = notificationManager.fcmToken {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "key.fill")
                                        .foregroundColor(.blue)
                                    Text("Your FCM Token")
                                        .font(.headline)
                                        .foregroundColor(.dynamicText)
                                    
                                    Spacer()
                                    
                                    if showTokenCopied {
                                        HStack(spacing: 5) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("Copied!")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                
                                Text("Use this token to send test notifications from Firebase Console")
                                    .font(.caption)
                                    .foregroundColor(.dynamicSecondaryText)
                                
                                // Token Display Box
                                VStack(alignment: .leading, spacing: 10) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        Text(token)
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(.dynamicText)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.1))
                                            )
                                    }
                                    
                                    // Copy Button
                                    Button(action: {
                                        UIPasteboard.general.string = token
                                        HapticManager.shared.success()
                                        withAnimation {
                                            showTokenCopied = true
                                        }
                                        
                                        // Hide "Copied!" after 2 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showTokenCopied = false
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "doc.on.doc.fill")
                                            Text("Copy Token")
                                                .fontWeight(.semibold)
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(Color.blue)
                                        .cornerRadius(22)
                                    }
                                }
                                
                                // Instructions
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("How to test:")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.dynamicText)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        InstructionRow(number: "1", text: "Copy the token above")
                                        InstructionRow(number: "2", text: "Go to Firebase Console → Cloud Messaging")
                                        InstructionRow(number: "3", text: "Click 'Send test message'")
                                        InstructionRow(number: "4", text: "Paste your token and send!")
                                    }
                                    .font(.caption2)
                                    .foregroundColor(.dynamicSecondaryText)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(colorScheme == .dark ? 0.15 : 0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                    )
                            )
                            .padding(.horizontal)
                        } else {
                            // Token Loading State
                            VStack(spacing: 10) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Loading FCM Token...")
                                    .font(.caption)
                                    .foregroundColor(.dynamicSecondaryText)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.dynamicCardBackground)
                            )
                            .padding(.horizontal)
                        }
                       */
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            
        }
        .preferredColorScheme(.light)
    }
}

// Instruction Row

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.blue.opacity(0.2)))
            
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// Notification Toggle

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

// Preview

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}

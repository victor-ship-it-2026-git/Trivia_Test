import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @State private var showNotificationPage = false
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        ZStack {
            if showNotificationPage {
                OnboardingNotificationView(onComplete: {
                    onComplete()
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                standardOnboardingFlow
            }
        }
    }
    
    private var standardOnboardingFlow: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        emoji: "🎮",
                        title: "Welcome to Trivia Master!",
                        description: "The game is very simple. Test your knowledge across multiple categories and difficulty levels.",
                        pageNumber: 0
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        emoji: "✅",
                        title: "How to Win",
                        description: "If you correctly answer the question, you get a point and proceed to the next question. Easy!",
                        pageNumber: 1
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        emoji: "⏰",
                        title: "Beat the Clock",
                        description: "You have 30 seconds per question. Choose wisely and quickly!",
                        pageNumber: 2
                    )
                    .tag(2)
                    
                    OnboardingPage(
                        emoji: "📺",
                        title: "The Challenge",
                        description: "If you can't answer within the time limit, or if you choose the wrong answer, you will fail the challenge and need to watch boring ads as punishment 😈",
                        pageNumber: 3
                    )
                    .tag(3)
                    
                    OnboardingPage(
                        emoji: "🏆",
                        title: "Ready to Play?",
                        description: "Choose wisely, answer quickly, and climb the leaderboard. Good luck!",
                        pageNumber: 4
                    )
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.5))
                            .frame(width: 10, height: 10)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(width: 120, height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < 4 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            // Go to notification permission page
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showNotificationPage = true
                            }
                        }
                    }) {
                        Text(currentPage == 4 ? "Next" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Onboarding Notification View
struct OnboardingNotificationView: View {
    let onComplete: () -> Void
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var animateContent = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Bell Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                    
                    Text("🔔")
                        .font(.system(size: 70))
                        .scaleEffect(animateContent ? 1.0 : 0.5)
                }
                .opacity(animateContent ? 1 : 0)
                
                // Title & Description
                VStack(spacing: 15) {
                    Text("Stay Updated!")
                        .font(.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    Text("Get notified about daily challenges, new questions, and leaderboard updates!")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 40)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                }
                
                // Benefits
                VStack(alignment: .leading, spacing: 15) {
                    NotificationBenefit(icon: "calendar.badge.clock", text: "Daily Challenge Reminders")
                    NotificationBenefit(icon: "star.fill", text: "New Questions Alerts")
                    NotificationBenefit(icon: "trophy.fill", text: "Leaderboard Updates")
                }
                .padding(.horizontal, 40)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 15) {
                    // Enable Notifications Button
                    Button(action: {
                        // ADD THIS
                        AnalyticsManager.shared.logNotificationPermissionRequested()
                        
                        notificationManager.requestNotificationPermission()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // ADD THIS
                            AnalyticsManager.shared.logOnboardingCompleted()
                            onComplete()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge.fill")
                            Text("Enable Notifications")
                                .fontWeight(.bold)
                        }
                        .font(.headline)
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
                        .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    
                    // Skip Button
                    Button(action: {
                        // ADD THIS
                        AnalyticsManager.shared.logOnboardingCompleted()
                        onComplete()
                    }) {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 12)
                    }
                    .opacity(animateContent ? 1 : 0)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Notification Benefit Row
struct NotificationBenefit: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

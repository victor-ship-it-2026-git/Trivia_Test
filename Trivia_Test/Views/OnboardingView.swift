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
            Color(red: 0.97, green: 0.97, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < 4 {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showNotificationPage = true
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.orange)
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                }
                
                // Page indicator at top (for pages 1-4)
                if currentPage > 0 {
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.yellow : Color.yellow.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                TabView(selection: $currentPage) {
                    // Page 0 - Welcome
                    VStack(spacing: 24) {
                        illustrationView(for: 0)
                            .frame(height: 400)
                        
                        Text("Welcome to Trivia Master!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Text("The game is very simple. Test your knowledge across multiple categories and difficulty levels.")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .tag(0)
                    
                    // Page 1 - How to Win
                    VStack(spacing: 24) {
                        Spacer().frame(height: 100)
                        
                        Text("✅")
                            .font(.system(size: 100))
                        
                        Text("How to Win")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Text("If you correctly answer the question, you get a point and proceed to the next question. Easy!")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .tag(1)
                    
                    // Page 2 - Beat the Clock
                    VStack(spacing: 24) {
                        illustrationView(for: 2)
                            .frame(height: 400)
                        
                        Text("Beat the Clock")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Text("You have 30 seconds per question. Choose wisely and quickly!")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .tag(2)
                    
                    // Page 3 - The Challenge
                    VStack(spacing: 24) {
                        illustrationView(for: 3)
                            .frame(height: 400)
                        
                        Text("The Challenge")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Text("If you can't answer within the time limit, or if you choose the wrong answer, you will fail the challenge and need to watch boring ads as punishment 😈")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .tag(3)
                    
                    // Page 4 - Ready to Play
                    VStack(spacing: 24) {
                        Spacer().frame(height: 100)
                        
                        Text("🏆")
                            .font(.system(size: 100))
                        
                        Text("Ready to Play?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Text("Choose wisely, answer quickly, and climb the leaderboard. Good luck!")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // Page indicator at bottom (for page 0)
                if currentPage == 0 {
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.yellow : Color.yellow.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.purple)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.purple.opacity(0.15))
                                .cornerRadius(28)
                        }
                    }
                    
                    Button(action: {
                        if currentPage < 4 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showNotificationPage = true
                            }
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.yellow)
                            .cornerRadius(28)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    @ViewBuilder
    func illustrationView(for page: Int) -> some View {
        switch page {
        case 0:
            // Abstract circles for welcome page
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.98, green: 0.95, blue: 0.93))
                    .frame(width: 280, height: 380)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                Circle()
                    .fill(Color(red: 0.7, green: 0.82, blue: 0.8))
                    .frame(width: 130, height: 130)
                    .offset(x: -70, y: -110)
                
                Circle()
                    .fill(Color(red: 0.95, green: 0.8, blue: 0.7))
                    .frame(width: 90, height: 90)
                    .offset(x: 15, y: -135)
                
                Circle()
                    .fill(Color(red: 0.7, green: 0.82, blue: 0.8))
                    .frame(width: 110, height: 110)
                    .offset(x: 85, y: -75)
                
                Circle()
                    .fill(Color(red: 0.95, green: 0.8, blue: 0.7).opacity(0.7))
                    .frame(width: 120, height: 120)
                    .offset(x: -90, y: 10)
                
                Circle()
                    .fill(Color(red: 0.7, green: 0.82, blue: 0.8))
                    .frame(width: 140, height: 140)
                    .offset(x: 15, y: 50)
                
                Circle()
                    .fill(Color.orange)
                    .frame(width: 180, height: 180)
                    .offset(x: 0, y: 145)
                
                Circle()
                    .fill(Color(red: 0.5, green: 0.7, blue: 0.7))
                    .frame(width: 90, height: 90)
                    .offset(x: -95, y: 165)
            }
            
        case 2:
            // Power-ups card for Beat the Clock
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 0.95, green: 0.95, blue: 0.93))
                    .frame(width: 300, height: 450)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 16) {
                    Text("• • • • •")
                        .font(.system(size: 10))
                        .foregroundColor(Color.gray)
                        .padding(.top, 60)
                    
                    Spacer().frame(height: 20)
                    
                    Text("POWER-UPS")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.black)
                    
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.95, green: 0.8, blue: 0.7))
                            .frame(width: 160, height: 160)
                        
                        VStack(spacing: 4) {
                            Text("NATIVE EQ WORK")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.black)
                            Text("+ 30%")
                                .font(.system(size: 11))
                                .foregroundColor(Color.gray)
                            Text("Get more information")
                                .font(.system(size: 8))
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer().frame(height: 30)
                    
                    Text("• • • • • • •")
                        .font(.system(size: 10))
                        .foregroundColor(Color.gray)
                        .padding(.bottom, 60)
                }
            }
            
        case 3:
            // Cat illustration for The Challenge
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(red: 0.77, green: 0.85, blue: 0.80))
                    .frame(width: 320, height: 450)
                
                VStack {
                    ZStack {
                        // Body
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color(red: 0.95, green: 0.7, blue: 0.5))
                            .frame(width: 140, height: 200)
                        
                        // Head
                        Circle()
                            .fill(Color(red: 0.95, green: 0.7, blue: 0.5))
                            .frame(width: 110, height: 110)
                            .offset(y: -100)
                        
                        // Ears
                        Triangle()
                            .fill(Color(red: 0.95, green: 0.7, blue: 0.5))
                            .frame(width: 35, height: 40)
                            .offset(x: -30, y: -135)
                        
                        Triangle()
                            .fill(Color(red: 0.95, green: 0.7, blue: 0.5))
                            .frame(width: 35, height: 40)
                            .offset(x: 30, y: -135)
                        
                        // Face
                        HStack(spacing: 25) {
                            Text("^")
                                .font(.system(size: 20, weight: .bold))
                                .rotationEffect(.degrees(180))
                            Text("^")
                                .font(.system(size: 20, weight: .bold))
                                .rotationEffect(.degrees(180))
                        }
                        .offset(y: -105)
                        
                        Text("ω")
                            .font(.system(size: 16))
                            .offset(y: -90)
                        
                        // Cheeks
                        Circle()
                            .fill(Color(red: 0.98, green: 0.6, blue: 0.5).opacity(0.5))
                            .frame(width: 25, height: 20)
                            .offset(x: -35, y: -85)
                        
                        Circle()
                            .fill(Color(red: 0.98, green: 0.6, blue: 0.5).opacity(0.5))
                            .frame(width: 25, height: 20)
                            .offset(x: 35, y: -85)
                        
                        // Arm
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(red: 0.95, green: 0.7, blue: 0.5))
                            .frame(width: 35, height: 80)
                            .rotationEffect(.degrees(-25))
                            .offset(x: -70, y: -30)
                        
                        // Paw marks
                        HStack(spacing: 8) {
                            Text("ノ")
                                .font(.system(size: 12))
                            Text("ノ")
                                .font(.system(size: 12))
                        }
                        .offset(y: 85)
                    }
                }
            }
            
        default:
            Color.clear
        }
    }
}

// Helper shape for triangle ears
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}




// Onboarding Notification View
struct OnboardingNotificationView: View {
    let onComplete: () -> Void
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var animateContent = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Bell Icon
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
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
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    Text("Get notified about daily challenges, new questions, and leaderboard updates!")
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.gray)
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
                        AnalyticsManager.shared.logNotificationPermissionRequested()
                        
                        notificationManager.requestNotificationPermission()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            AnalyticsManager.shared.logOnboardingCompleted()
                            onComplete()
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge.fill")
                            Text("Enable Notifications")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.yellow)
                        .cornerRadius(28)
                        .shadow(color: Color.yellow.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    
                    // Skip Button
                    Button(action: {
                        AnalyticsManager.shared.logOnboardingCompleted()
                        onComplete()
                    }) {
                        Text("Maybe Later")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
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



// Notification Benefit Row
struct NotificationBenefit: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            
            Spacer()
        }
    }
}

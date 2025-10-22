
import SwiftUI

struct DailyChallengeView: View {
    @StateObject private var challengeManager = DailyChallengeManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ?
                        [Color.blue.opacity(0.2), Color.purple.opacity(0.2)] :
                        [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 10) {
                            Text("📅")
                                .font(.system(size: 60))
                            
                            Text("Daily Challenge")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.dynamicText)
                            
                            Text("Complete challenges to earn rewards!")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Current Challenge
                        if let challenge = challengeManager.currentChallenge {
                            DailyChallengeCard(challenge: challenge)
                                .padding(.horizontal)
                            
                            // Challenge Description
                            VStack(alignment: .leading, spacing: 15) {
                                Text("How to Complete:")
                                    .font(.headline)
                                    .foregroundColor(.dynamicText)
                                
                                Text(getChallengeInstructions(challenge.challengeType))
                                    .font(.body)
                                    .foregroundColor(.dynamicSecondaryText)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.dynamicCardBackground)
                                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 5)
                            )
                            .padding(.horizontal)
                            
                            // Stats
                            HStack(spacing: 20) {
                                StatCard(
                                    icon: "flame.fill",
                                    title: "Current",
                                    value: "\(challenge.currentProgress)",
                                    color: .orange
                                )
                                
                                StatCard(
                                    icon: "target",
                                    title: "Target",
                                    value: "\(challenge.targetValue)",
                                    color: .blue
                                )
                                
                                StatCard(
                                    icon: "percent",
                                    title: "Progress",
                                    value: "\(Int(challenge.progressPercentage * 100))%",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                        } else {
                            Text("No challenge available")
                                .font(.headline)
                                .foregroundColor(.dynamicSecondaryText)
                                .padding()
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
    
    private func getChallengeInstructions(_ type: ChallengeType) -> String {
        switch type {
        case .answerCorrectly:
            return "Answer the target number of questions correctly in any quiz. Wrong answers don't reset progress."
        case .perfectStreak:
            return "Build and maintain a streak of correct answers without any mistakes. One wrong answer resets the streak!"
        case .completeQuizzes:
            return "Complete full quiz sessions from start to finish. Each completed quiz counts toward your goal."
        case .speedRun:
            return "Answer questions within 10 seconds each. Quick thinking earns you progress!"
        // Remove categoryMaster case if it doesn't exist in your ChallengeType enum
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.dynamicSecondaryText)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.dynamicText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 3)
        )
    }
}

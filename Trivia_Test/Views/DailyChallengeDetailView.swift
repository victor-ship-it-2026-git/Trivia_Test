//
//  DailyChallengeDetailView.swift
//  Trivia_Test
//
//  Created by Win on 5/10/2568 BE.
//



import SwiftUI

struct DailyChallengeDetailView: View {
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
                            
                            Text("Complete for amazing rewards!")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Current Challenge
                        if let challenge = challengeManager.currentChallenge {
                            VStack(spacing: 20) {
                                // Challenge Card
                                VStack(alignment: .leading, spacing: 15) {
                                    HStack {
                                        Image(systemName: challenge.challengeType.icon)
                                            .font(.title)
                                            .foregroundColor(.orange)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(challenge.challengeType.rawValue)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.dynamicText)
                                            
                                            Text(challenge.challengeType.description)
                                                .font(.subheadline)
                                                .foregroundColor(.dynamicSecondaryText)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    // Progress
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Progress")
                                                .font(.headline)
                                                .foregroundColor(.dynamicText)
                                            
                                            Spacer()
                                            
                                            Text("\(challenge.currentProgress)/\(challenge.targetValue)")
                                                .font(.headline)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(height: 12)
                                                
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [.blue, .cyan]),
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .frame(width: geometry.size.width * challenge.progressPercentage, height: 12)
                                                    .animation(.easeInOut, value: challenge.progressPercentage)
                                            }
                                        }
                                        .frame(height: 12)
                                        
                                        Text("\(Int(challenge.progressPercentage * 100))% Complete")
                                            .font(.caption)
                                            .foregroundColor(.dynamicSecondaryText)
                                    }
                                    
                                    // Completion Status
                                    if challenge.isCompleted {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("Challenge Completed!")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.green)
                                        }
                                        .font(.headline)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.dynamicCardBackground)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8)
                                )
                                .padding(.horizontal)
                                
                                // Rewards Section
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("🎁 Rewards")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.dynamicText)
                                    
                                    VStack(spacing: 12) {
                                        // Lifeline Rewards
                                        ForEach(Array(challenge.reward.lifelines.keys), id: \.self) { type in
                                            if let quantity = challenge.reward.lifelines[type] {
                                                RewardRow(
                                                    icon: type.icon,
                                                    title: type.rawValue,
                                                    quantity: quantity,
                                                    color: getLifelineColor(type)
                                                )
                                            }
                                        }
                                        
                                        // Coins Reward
                                        if challenge.reward.coins > 0 {
                                            RewardRow(
                                                icon: "dollarsign.circle.fill",
                                                title: "Coins",
                                                quantity: challenge.reward.coins,
                                                color: .yellow
                                            )
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.dynamicCardBackground)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8)
                                )
                                .padding(.horizontal)
                                
                                // Instructions
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("💡 How to Complete")
                                        .font(.headline)
                                        .foregroundColor(.dynamicText)
                                    
                                    Text(getChallengeInstructions(challenge.challengeType))
                                        .font(.body)
                                        .foregroundColor(.dynamicSecondaryText)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.1))
                                )
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private func getLifelineColor(_ type: LifelineType) -> Color {
        switch type {
        case .fiftyFifty: return .blue
        case .skip: return .orange
        case .extraTime: return .green
        }
    }
    
    private func getChallengeInstructions(_ type: ChallengeType) -> String {
        switch type {
        case .answerCorrectly:
            return "Answer the target number of questions correctly in any quiz. Wrong answers don't reset progress, so keep playing!"
        case .perfectStreak:
            return "Build and maintain a streak of correct answers without any mistakes. One wrong answer resets the streak, so be careful!"
        case .completeQuizzes:
            return "Complete full quiz sessions from start to finish. Each completed quiz counts toward your goal."
        case .speedRun:
            return "Answer questions within 10 seconds each. Quick thinking earns you progress toward the challenge!"
        }
    }
}

struct RewardRow: View {
    let icon: String
    let title: String
    let quantity: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(.dynamicText)
            
            Spacer()
            
            Text("×\(quantity)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

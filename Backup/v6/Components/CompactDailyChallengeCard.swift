//
//  CompactDailyChallengeCard.swift
//  Trivia_Test
//
//  Created by Win on 5/10/2568 BE.
//



import SwiftUI

struct CompactDailyChallengeCard: View {
    let challenge: DailyChallenge
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: challenge.challengeType.icon)
                        .font(.title3)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("📅 Daily Challenge")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(challenge.challengeType.rawValue)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Done!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                } else {
                    Text("Tap to view")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .yellow]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * challenge.progressPercentage, height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(challenge.currentProgress)/\(challenge.targetValue)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                // Reward Preview
                HStack(spacing: 8) {
                    ForEach(Array(challenge.reward.lifelines.keys.prefix(2)), id: \.self) { type in
                        if let qty = challenge.reward.lifelines[type] {
                            HStack(spacing: 3) {
                                Image(systemName: type.icon)
                                    .font(.caption2)
                                Text("×\(qty)")
                                    .font(.caption2)
                            }
                            .foregroundColor(.yellow)
                        }
                    }
                    
                    HStack(spacing: 3) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption2)
                        Text("+\(challenge.reward.coins)")
                            .font(.caption2)
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: challenge.isCompleted ?
                            [Color.green.opacity(0.6), Color.green.opacity(0.4)] :
                            [Color.orange.opacity(0.6), Color.purple.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 10)
        )
    }
}

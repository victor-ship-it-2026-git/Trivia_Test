import SwiftUI

struct DailyChallengeCard: View {
    let challenge: DailyChallenge
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: challenge.challengeType.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Challenge")
                        .font(.caption)
                        .foregroundColor(.dynamicSecondaryText)
                    
                    Text(challenge.challengeType.rawValue)
                        .font(.headline)
                        .foregroundColor(.dynamicText)
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            
            // Progress
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(challenge.currentProgress)/\(challenge.targetValue)")
                        .font(.caption)
                        .foregroundColor(.dynamicSecondaryText)
                    
                    Spacer()
                    
                    Text("\(Int(challenge.progressPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * challenge.progressPercentage, height: 8)
                            .animation(.easeInOut, value: challenge.progressPercentage)
                    }
                }
                .frame(height: 8)
            }
            
            // Rewards
            if !challenge.isCompleted {
                HStack(spacing: 8) {
                    Text("Reward:")
                        .font(.caption2)
                        .foregroundColor(.dynamicSecondaryText)
                    
                    ForEach(Array(challenge.reward.lifelines.keys), id: \.self) { type in
                        if let quantity = challenge.reward.lifelines[type] {
                            HStack(spacing: 2) {
                                Image(systemName: type.icon)
                                    .font(.caption2)
                                Text("×\(quantity)")
                                    .font(.caption2)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                   
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(challenge.isCompleted ?
                    Color.green.opacity(colorScheme == .dark ? 0.2 : 0.1) :
                    Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 5)
        )
    }
}

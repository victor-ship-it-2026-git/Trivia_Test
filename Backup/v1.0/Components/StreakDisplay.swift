import SwiftUI

struct StreakDisplay: View {
    let streak: Streak
    let showAnimation: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            // Flame icon
            if streak.currentStreak > 0 {
                Text(streak.emoji)
                    .font(.title3)
                    .scaleEffect(showAnimation ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3).repeatCount(3), value: showAnimation)
            }
            
            // Streak counter
            VStack(alignment: .leading, spacing: 2) {
                Text("Streak")
                    .font(.caption2)
                    .foregroundColor(.dynamicSecondaryText)
                Text("\(streak.currentStreak)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(streak.currentStreak >= 3 ? .orange : .dynamicText)
            }
            
            // Multiplier badge
            if streak.multiplier > 1 {
                Text("×\(streak.multiplier)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .scaleEffect(showAnimation ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: showAnimation)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 2)
        )
    }
}

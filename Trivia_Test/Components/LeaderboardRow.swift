
import SwiftUI

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let rank: Int
    @Environment(\.colorScheme) var colorScheme
    
    var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Text(rankEmoji)
                .font(.title)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.headline)
                    .foregroundColor(.dynamicText)
                
                HStack(spacing: 10) {
                    Text(entry.category)
                        .font(.caption)
                        .foregroundColor(.dynamicText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.2))
                        .cornerRadius(8)
                    
                    Text(entry.difficulty)
                        .font(.caption)
                        .foregroundColor(.dynamicText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor(entry.difficulty).opacity(colorScheme == .dark ? 0.25 : 0.2))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.percentage)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("\(entry.score)/\(entry.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.dynamicSecondaryText)
            }
        }
        .padding()
        .background(Color.dynamicCardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 2)
    }
    
    func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        default: return .gray
        }
    }
}

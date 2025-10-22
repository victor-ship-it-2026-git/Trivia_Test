import SwiftUI

struct PowerUpInfoView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dynamicBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(PowerUpType.allCases, id: \.self) { type in
                            PowerUpInfoCard(powerUp: type)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Power-Up Guide")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct PowerUpInfoCard: View {
    let powerUp: PowerUpType
    @Environment(\.colorScheme) var colorScheme
    
    var iconColor: Color {
        switch powerUp {
        case .doublePoints: return .yellow
        case .freezeTime: return .cyan
        case .autoCorrect: return .green
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: powerUp.icon)
                .font(.title)
                .foregroundColor(iconColor)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(powerUp.rawValue)
                    .font(.headline)
                    .foregroundColor(.dynamicText)
                
                Text(powerUp.description)
                    .font(.caption)
                    .foregroundColor(.dynamicSecondaryText)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 3)
        )
    }
}

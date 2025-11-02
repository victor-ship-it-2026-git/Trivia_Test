import SwiftUI

struct PowerUpButton: View {
    let powerUp: PowerUpType
    let quantity: Int
    let isActive: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var iconColor: Color {
        switch powerUp {
        case .doublePoints: return .yellow
        case .freezeTime: return .cyan
        case .autoCorrect: return .green
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isActive ?
                            iconColor.opacity(0.5) :
                            iconColor.opacity(colorScheme == .dark ? 0.3 : 0.2))
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: powerUp.icon)
                        .font(.system(size: 18))
                        .foregroundColor(isActive ? .white : iconColor)
                    
                    // Active indicator
                    if isActive {
                        Circle()
                            .stroke(iconColor, lineWidth: 2)
                            .frame(width: 50, height: 50)
                    }
                    
                    // Quantity badge
                    if quantity > 0 && !isActive {
                        Text("\(quantity)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(iconColor))
                            .offset(x: 16, y: -16)
                    }
                }
            }
        }
        .disabled(quantity == 0 && !isActive)
        .opacity(quantity == 0 && !isActive ? 0.4 : 1.0)
    }
}

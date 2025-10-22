import SwiftUI

struct CategoryCard: View {
    let category: QuizCategory
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
            Button(action: {
                HapticManager.shared.selection()
                action()
            }) {
                VStack(spacing: 15) {
                    Text(category.emoji)
                        .font(.system(size: 50))
                    
                    Text(category.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.dynamicText)
                        .minimumScaleFactor(0.8)
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ?
                            Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15) :
                            Color.dynamicCardBackground)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 5, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.spring(response: 0.3), value: isSelected)
            }
        }
    }


import SwiftUI

struct OptionButtonAnimated: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(colorScheme == .dark ? 0.25 : 0.2)
        } else if isWrong {
            return Color.red.opacity(colorScheme == .dark ? 0.25 : 0.2)
        } else if isSelected {
            return Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15)
        } else {
            return Color.dynamicCardBackground
        }
    }
    
    var borderColor: Color {
        if isCorrect {
            return Color.green
        } else if isWrong {
            return Color.red
        } else if isSelected {
            return Color.blue
        } else {
            return Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2)
        }
    }
    
    var body: some View {
        Button(action: {
            guard !isDisabled else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                withAnimation {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 15) {
                Text(text)
                    .font(.body)
                    .foregroundColor(.dynamicText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(isPressed ? 0 : (colorScheme == .dark ? 0.2 : 0.05)), radius: isPressed ? 0 : 3, x: 0, y: isPressed ? 0 : 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isSelected || isCorrect || isWrong ? 2 : 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isCorrect)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isWrong)
        }
        .disabled(isDisabled)
        .opacity(isDisabled && !isCorrect && !isWrong ? 0.6 : 1.0)
    }
}

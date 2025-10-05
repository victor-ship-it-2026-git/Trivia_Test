//
//  LifelineButton.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//


import SwiftUI

struct LifelineButton: View {
    let lifeline: LifelineType
    let quantity: Int
    let isDisabled: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var iconColor: Color {
        switch lifeline {
        case .fiftyFifty: return .blue
        case .skip: return .orange
        case .extraTime: return .green
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(colorScheme == .dark ? 0.3 : 0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: lifeline.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isDisabled ? .gray : iconColor)
                    
                    // Quantity badge
                    if quantity > 0 {
                        Text("\(quantity)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(iconColor))
                            .offset(x: 18, y: -18)
                    }
                }
                
                Text(lifeline.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(isDisabled ? .gray : .dynamicText)
            }
        }
        .disabled(isDisabled || quantity == 0)
        .opacity(quantity == 0 ? 0.4 : 1.0)
    }
}

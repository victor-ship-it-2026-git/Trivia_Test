//
//  LifelinesInventoryCard.swift
//  Trivia_Test
//
//  Created by Win on 5/10/2568 BE.
//



import SwiftUI

struct LifelinesInventoryCard: View {
    @StateObject private var lifelineManager = LifelineManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("💡 Your Lifelines")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                ForEach(LifelineType.allCases, id: \.self) { type in
                    LifelineInventoryItem(
                        type: type,
                        quantity: lifelineManager.getQuantity(for: type)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
        )
    }
}

struct LifelineInventoryItem: View {
    let type: LifelineType
    let quantity: Int
    
    var iconColor: Color {
        switch type {
        case .fiftyFifty: return .blue
        case .skip: return .orange
        case .extraTime: return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.3))
                    .frame(width: 55, height: 55)
                
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                
                // Quantity badge
                Text("\(quantity)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(iconColor))
                    .offset(x: 20, y: -20)
            }
            
            Text(type.rawValue)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

//
//  ShopItemCard.swift
//  Trivia_Test
//
//  Created by Win on 5/10/2568 BE.
//

import SwiftUI

struct ShopItemCard: View {
    let item: ShopItem
    let onPurchase: () -> Void
    @StateObject private var coinsManager = CoinsManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var canAfford: Bool {
            coinsManager.hasEnoughCoins(item.price)
        }
        
        var iconColor: Color {
            switch item.lifelineType {
            case .fiftyFifty: return .blue
            case .skip: return .orange
            case .extraTime: return .green
            }
        }
        
        var body: some View {
            HStack {
                // Quantity
                HStack(spacing: 6) {
                    Image(systemName: item.lifelineType.icon)
                        .font(.title3)
                        .foregroundColor(iconColor)
                    
                    Text("×\(item.quantity)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.dynamicText)
                }
                .frame(width: 80)
                
                Spacer()
                
                // Price & Buy Button
                Button(action: {
                    if canAfford {
                        HapticManager.shared.success()
                    } else {
                        HapticManager.shared.error()
                    }
                    onPurchase()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(canAfford ? .yellow : .gray)
                        
                        Text("\(item.price)")
                            .fontWeight(.semibold)
                            .foregroundColor(canAfford ? .white : .gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(canAfford ? iconColor : Color.gray)
                    )
                }
                .disabled(!canAfford)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.dynamicBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(iconColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

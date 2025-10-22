import SwiftUI

struct ShopItemCard: View {
    let item: ShopItem
    let onPurchase: () -> Void
    @ObservedObject var coinsManager = CoinsManager.shared  // Changed to @ObservedObject
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
            
  
            Button(action: {
                print("🛒 Buy button tapped - Can afford: \(canAfford), Price: \(item.price), Coins: \(coinsManager.coins)")
                if canAfford {
                    HapticManager.shared.success()
                    onPurchase()
                } else {
                    HapticManager.shared.error()
            
                    onPurchase()
                }
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
                        .fill(canAfford ? iconColor : Color.gray.opacity(0.5))
                )
            }

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dynamicCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(iconColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}


import SwiftUI

struct ShopView: View {
    @StateObject private var shopManager = ShopManager.shared
    @StateObject private var coinsManager = CoinsManager.shared
    @StateObject private var lifelineManager = LifelineManager.shared
    @ObservedObject private var adManager = AdMobManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var purchaseSuccess = false
    @State private var showInsufficientCoins = false
    @State private var adRewardMessage = ""
    @State private var showAdRewardAlert = false
    @State private var pendingAdReward: ShopAdReward?
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        headerSection
                        
                        adRewardsSection
                        
                        dividerSection
                        
                        coinsShopSection
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .alert("Purchase Successful!", isPresented: $purchaseSuccess) {
                Button("OK", role: .cancel) { }
            }
            .alert("Not Enough Coins!", isPresented: $showInsufficientCoins) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Complete quizzes and daily challenges to earn more coins!")
            }
            .alert("Reward Claimed! 🎉", isPresented: $showAdRewardAlert) {
                Button("Awesome!", role: .cancel) { }
            } message: {
                Text(adRewardMessage)
            }
        }
    }
    
    // View Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: colorScheme == .dark ?
                [Color.blue.opacity(0.2), Color.purple.opacity(0.2)] :
                [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("🛒")
                .font(.system(size: 60))
            
            Text("Lifeline Shop")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.dynamicText)
            
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                Text("\(coinsManager.coins) Coins")
                    .fontWeight(.semibold)
            }
            .font(.title3)
            .foregroundColor(.dynamicText)
        }
        .padding(.top, 20)
    }
    
    private var adRewardsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "tv.fill")
                    .foregroundColor(.orange)
                Text("Watch Ad for Free Rewards")
                    .font(.headline)
                    .foregroundColor(.dynamicText)
            }
            
            Text("Watch a short video ad to get free lifelines!")
                .font(.subheadline)
                .foregroundColor(.dynamicSecondaryText)
            
            ForEach(shopManager.adRewards) { reward in
                AdRewardCard(
                    reward: reward,
                    isAdReady: adManager.isAdReady,
                    onWatchAd: { watchAdForReward(reward) }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.opacity(colorScheme == .dark ? 0.15 : 0.1))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8)
        )
        .padding(.horizontal)
    }
    
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            Text("OR")
                .font(.caption)
                .foregroundColor(.dynamicSecondaryText)
                .padding(.horizontal, 10)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal)
    }
    
    private var coinsShopSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "cart.fill")
                    .foregroundColor(.blue)
                Text("Buy with Coins")
                    .font(.headline)
                    .foregroundColor(.dynamicText)
            }
            .padding(.horizontal)
            
            ForEach(LifelineType.allCases, id: \.self) { lifelineType in
                lifelineSection(for: lifelineType)
            }
        }
    }
    
    private func lifelineSection(for lifelineType: LifelineType) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: lifelineType.icon)
                    .foregroundColor(getColor(for: lifelineType))
                Text(lifelineType.rawValue)
                    .font(.headline)
                    .foregroundColor(.dynamicText)
                
                Spacer()
                
                Text("Owned: \(lifelineManager.getQuantity(for: lifelineType))")
                    .font(.caption)
                    .foregroundColor(.dynamicSecondaryText)
            }
            
            ForEach(shopManager.shopItems.filter { $0.lifelineType == lifelineType }) { item in
                ShopItemCard(
                    item: item,
                    onPurchase: { purchaseItem(item) }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 5)
        )
        .padding(.horizontal)
    }
    
    // Helper Methods
    
    private func purchaseItem(_ item: ShopItem) {
        if shopManager.purchaseItem(item) {
            purchaseSuccess = true
        } else {
            showInsufficientCoins = true
        }
    }
    
    private func watchAdForReward(_ reward: ShopAdReward) {
        Task { @MainActor in
            guard adManager.isAdReady else {
                print("❌ Ad not ready yet. Current state: \(adManager.isAdReady)")
                return
            }
            
            print("🎯 Starting ad for reward: \(reward.lifelineType.rawValue)")
            pendingAdReward = reward
            
            adManager.onAdRewarded = {
                Task { @MainActor in
                    if let reward = self.pendingAdReward {
                        // Grant the reward
                        LifelineManager.shared.addLifeline(type: reward.lifelineType, quantity: reward.quantity)
                        
                        // Show success message
                        self.adRewardMessage = "You received \(reward.quantity)x \(reward.lifelineType.rawValue)!"
                        self.showAdRewardAlert = true
                        
                        self.pendingAdReward = nil
                        print("✅ Reward granted: \(reward.quantity)x \(reward.lifelineType.rawValue)")
                    }
                }
            }
            
            adManager.onAdDismissed = {
                Task { @MainActor in
                    if self.pendingAdReward != nil {
                        print("⚠️ Ad dismissed without reward")
                        self.pendingAdReward = nil
                    }
                }
            }
            
            // Dismiss the shop sheet first, then show ad
            dismiss()
            
            // Wait for dismiss animation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task { @MainActor in
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let rootViewController = windowScene.windows.first?.rootViewController else {
                        print("❌ Could not get root view controller")
                        return
                    }
                    
                    print("🎬 Showing ad from Shop...")
                    self.adManager.showAd(from: rootViewController)
                }
            }
        }
    }
    
    private func getColor(for type: LifelineType) -> Color {
        switch type {
        case .fiftyFifty: return .blue
        case .skip: return .orange
        case .extraTime: return .green
        }
    }
}

//  Ad Reward Card
struct AdRewardCard: View {
    let reward: ShopAdReward
    let isAdReady: Bool
    let onWatchAd: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var iconColor: Color {
        switch reward.lifelineType {
        case .fiftyFifty: return .blue
        case .skip: return .orange
        case .extraTime: return .green
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Reward Icon and Quantity
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: reward.lifelineType.icon)
                        .font(.title3)
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(reward.lifelineType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.dynamicText)
                    
                    Text("×\(reward.quantity)")
                        .font(.caption)
                        .foregroundColor(.dynamicSecondaryText)
                }
            }
            
            Spacer()
            
            // Watch Ad Button
            Button(action: onWatchAd) {
                HStack(spacing: 6) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.caption)
                    Text(isAdReady ? "Watch Ad" : "Loading...")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isAdReady ?
                            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                        )
                )
                .shadow(color: isAdReady ? Color.orange.opacity(0.4) : Color.clear, radius: 5)
            }
            .disabled(!isAdReady)
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

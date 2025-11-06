import SwiftUI
internal import Combine

struct ShopScreenView: View {
    let goBack: () -> Void
    @StateObject private var shopManager = ShopManager.shared
    @StateObject private var coinsManager = CoinsManager.shared
    @StateObject private var lifelineManager = LifelineManager.shared
    @ObservedObject private var adManager = AdMobManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var purchaseSuccess = false
    @State private var showInsufficientCoins = false
    @State private var adRewardMessage = ""
    @State private var showAdRewardAlert = false
    @State private var pendingAdReward: ShopAdReward?
    @State private var appearAnimation = false
    @State private var isNavigating = false
    
    var body: some View {
        ZStack {
            Color.dynamicBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        guard !isNavigating else { return }
                        handleBackNavigation()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    .disabled(isNavigating)
                    
                    Spacer()
                    
                    Text("Shop")
                        .font(.headline)
                        .foregroundColor(.dynamicText)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.headline)
                    .opacity(0)
                }
                .padding()
                .opacity(appearAnimation && !isNavigating ? 1 : 0)
                .offset(y: appearAnimation && !isNavigating ? 0 : -20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appearAnimation)
                .animation(.easeOut(duration: 0.2), value: isNavigating)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Header
                        headerSection
                        
                        // Watch Ad for Free Rewards
                        adRewardsSection
                        
                        // Divider
                        dividerSection
                        
                        // Buy with Coins
                        coinsShopSection
                        
                        Spacer(minLength: 50)
                    }
                }
                .disabled(isNavigating)
            }
            
            // Fade overlay during navigation
            if isNavigating {
                Color.dynamicBackground
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Shop")
            AnalyticsManager.shared.logShopViewed()
            
            isNavigating = false
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
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
    
    // View Components
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("🛒")
                .font(.system(size: 60))
                .scaleEffect(appearAnimation ? 1.0 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appearAnimation)
            
            Text("Lifeline Shop")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.dynamicText)
                .opacity(appearAnimation && !isNavigating ? 1 : 0)
                .offset(y: appearAnimation && !isNavigating ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appearAnimation)
                .animation(.easeOut(duration: 0.2), value: isNavigating)
            
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                Text("\(coinsManager.coins) Coins")
                    .fontWeight(.semibold)
            }
            .font(.title3)
            .foregroundColor(.dynamicText)
            .opacity(appearAnimation && !isNavigating ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appearAnimation)
            .animation(.easeOut(duration: 0.2), value: isNavigating)
        }
        .padding(.top, 20)
        .padding(.horizontal)
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
            
            ForEach(Array(shopManager.adRewards.enumerated()), id: \.element.id) { index, reward in
                AdRewardCard(
                    reward: reward,
                    isAdReady: adManager.isAdReady,
                    onWatchAd: { watchAdForReward(reward) }
                )
                .opacity(appearAnimation && !isNavigating ? 1 : 0)
                .offset(x: appearAnimation && !isNavigating ? 0 : -20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4 + Double(index) * 0.1), value: appearAnimation)
                .animation(.easeOut(duration: 0.2), value: isNavigating)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.opacity(colorScheme == .dark ? 0.15 : 0.1))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8)
        )
        .padding(.horizontal)
        .opacity(appearAnimation && !isNavigating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appearAnimation)
        .animation(.easeOut(duration: 0.2), value: isNavigating)
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
        .opacity(appearAnimation && !isNavigating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appearAnimation)
        .animation(.easeOut(duration: 0.2), value: isNavigating)
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
            
            ForEach(Array(LifelineType.allCases.enumerated()), id: \.element) { index, lifelineType in
                lifelineSection(for: lifelineType)
                    .opacity(appearAnimation && !isNavigating ? 1 : 0)
                    .offset(y: appearAnimation && !isNavigating ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8 + Double(index) * 0.1), value: appearAnimation)
                    .animation(.easeOut(duration: 0.2), value: isNavigating)
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
    
    private func handleBackNavigation() {
        HapticManager.shared.selection()
        
        withAnimation(.easeOut(duration: 0.2)) {
            isNavigating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            goBack()
        }
    }
    
    private func purchaseItem(_ item: ShopItem) {
        print("💰 Attempting purchase: \(item.lifelineType.rawValue) x\(item.quantity) for \(item.price) coins")
                print("💰 Current coins: \(coinsManager.coins)")
                
                if shopManager.purchaseItem(item) {
                    print("✅ Purchase successful!")
                    AnalyticsManager.shared.logLifelinePurchased(
                        lifelineType: item.lifelineType,
                        quantity: item.quantity,
                        cost: item.price
                    )
                    HapticManager.shared.success()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        purchaseSuccess = true
                    }
                    // Force refresh the UI
                    coinsManager.objectWillChange.send()
                    lifelineManager.objectWillChange.send()
                } else {
                    print("❌ Purchase failed - insufficient coins")
                    HapticManager.shared.error()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showInsufficientCoins = true
                    }
                }
            }
            
            private func watchAdForReward(_ reward: ShopAdReward) {
                Task { @MainActor in
                    guard adManager.isAdReady else {
                        print("❌ Ad not ready yet. Current state: \(adManager.isAdReady)")
                        return
                    }
                    
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let rootViewController = windowScene.windows.first?.rootViewController else {
                        print("❌ Could not get root view controller")
                        return
                    }
                    
                    print("🎯 Starting ad for reward: \(reward.lifelineType.rawValue)")
                    pendingAdReward = reward
                    
                    adManager.onAdRewarded = {
                        Task { @MainActor in
                            if let reward = self.pendingAdReward {
                                // Grant the reward
                                AnalyticsManager.shared.logAdWatchedForReward(rewardType: reward.lifelineType)
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
                    
                    print("🎬 Showing ad from ShopScreen...")
                    adManager.showAd(from: rootViewController)
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
              

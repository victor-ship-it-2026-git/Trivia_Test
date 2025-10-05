
import SwiftUI

struct HomeView: View {
    let startGame: () -> Void
    let showLeaderboard: () -> Void
    @StateObject private var coinsManager = CoinsManager.shared
    @StateObject private var challengeManager = DailyChallengeManager.shared
    @StateObject private var lifelineManager = LifelineManager.shared
    @State private var showShop = false
    @State private var showDailyChallengeDetail = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header with Coins
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            
                            Text("\(coinsManager.coins)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Logo & Title
                    VStack(spacing: 15) {
                        Text("🧠")
                            .font(.system(size: 80))
                        
                        Text("Trivia Master")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Test Your Knowledge!")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    
                    // Daily Challenge Card
                    if let challenge = challengeManager.currentChallenge {
                        Button(action: { showDailyChallengeDetail = true }) {
                            CompactDailyChallengeCard(challenge: challenge)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Lifelines Inventory
                    LifelinesInventoryCard()
                        .padding(.horizontal)
                    
                    // Main Actions
                    VStack(spacing: 15) {
                        Button(action: startGame) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Quiz")
                            }
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.white)
                            .cornerRadius(30)
                        }
                        
                        HStack(spacing: 15) {
                            Button(action: { showShop = true }) {
                                HStack {
                                    Image(systemName: "cart.fill")
                                    Text("Shop")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.orange.opacity(0.9))
                                .cornerRadius(28)
                            }
                            
                            Button(action: showLeaderboard) {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                    Text("Leaderboard")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(28)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showShop) {
            ShopView()
        }
        .sheet(isPresented: $showDailyChallengeDetail) {
            DailyChallengeDetailView()
        }
    }
}

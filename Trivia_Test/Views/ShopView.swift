//
//  ShopView.swift
//  Trivia_Test
//
//  Created by Win on 5/10/2568 BE.
//



import SwiftUI

struct ShopView: View {
    @StateObject private var shopManager = ShopManager.shared
    @StateObject private var coinsManager = CoinsManager.shared
    @StateObject private var lifelineManager = LifelineManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var purchaseSuccess = false
    @State private var showInsufficientCoins = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ?
                        [Color.blue.opacity(0.2), Color.purple.opacity(0.2)] :
                        [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
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
                        
                        // Shop Items by Category
                        ForEach(LifelineType.allCases, id: \.self) { lifelineType in
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
        }
    }
    
    private func purchaseItem(_ item: ShopItem) {
        if shopManager.purchaseItem(item) {
            purchaseSuccess = true
        } else {
            showInsufficientCoins = true
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

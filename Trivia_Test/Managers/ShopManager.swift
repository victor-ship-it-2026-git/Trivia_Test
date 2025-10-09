//
//  ShopManager.swift
//  Trivia_Test
//
//  Created by Win on 5/10/2568 BE.
//

import Foundation
internal import Combine

class ShopManager: ObservableObject {
    static let shared = ShopManager()
    
    @Published var shopItems: [ShopItem] = []
    @Published var adRewards: [ShopAdReward] = []
    
    private init() {
        loadShopItems()
        loadAdRewards()
    }
    
    func loadShopItems() {
        shopItems = [
            ShopItem(lifelineType: .fiftyFifty, quantity: 1, price: 50),
            ShopItem(lifelineType: .fiftyFifty, quantity: 3, price: 120),
            ShopItem(lifelineType: .fiftyFifty, quantity: 5, price: 180),
            
            ShopItem(lifelineType: .skip, quantity: 1, price: 80),
            ShopItem(lifelineType: .skip, quantity: 3, price: 200),
            ShopItem(lifelineType: .skip, quantity: 5, price: 300),
            
            ShopItem(lifelineType: .extraTime, quantity: 1, price: 60),
            ShopItem(lifelineType: .extraTime, quantity: 3, price: 150),
            ShopItem(lifelineType: .extraTime, quantity: 5, price: 220),
        ]
    }
    
    func loadAdRewards() {
        adRewards = [
            ShopAdReward(lifelineType: .fiftyFifty, quantity: 1),
            ShopAdReward(lifelineType: .skip, quantity: 1),
            ShopAdReward(lifelineType: .extraTime, quantity: 1),
        ]
    }
    
    func purchaseItem(_ item: ShopItem) -> Bool {
        guard CoinsManager.shared.spendCoins(item.price) else {
            return false
        }
        
        LifelineManager.shared.addLifeline(type: item.lifelineType, quantity: item.quantity)
        return true
    }
}

// MARK: - Shop Ad Reward Model
struct ShopAdReward: Identifiable {
    let id: UUID
    let lifelineType: LifelineType
    let quantity: Int
    
    init(lifelineType: LifelineType, quantity: Int) {
        self.id = UUID()
        self.lifelineType = lifelineType
        self.quantity = quantity
    }
}

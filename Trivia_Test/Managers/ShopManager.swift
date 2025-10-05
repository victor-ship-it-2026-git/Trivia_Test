//
//  ShopManager.swift
//  Trivia_Test
//
//  Created by Win on 5/10/2568 BE.
//

import Foundation
internal import Combine

class ShopManager: ObservableObject {
    // Remove this line - ObservableObject already provides objectWillChange
    // var objectWillChange: ObservableObjectPublisher

    static let shared = ShopManager()
    
    @Published var shopItems: [ShopItem] = []
    
    private init() {
        loadShopItems()
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
    
    func purchaseItem(_ item: ShopItem) -> Bool {
        guard CoinsManager.shared.spendCoins(item.price) else {
            return false
        }
        
        LifelineManager.shared.addLifeline(type: item.lifelineType, quantity: item.quantity)
        return true
    }
}

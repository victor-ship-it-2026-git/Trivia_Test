//
//  CoinsManager.swift
//  Trivia_Test
//
//  Created by Win on 5/10/2568 BE.
//



import Foundation
internal import Combine

class CoinsManager: ObservableObject {
    static let shared = CoinsManager()
    private let defaults = UserDefaults.standard
    private let key = "user_coins"
    
    @Published var coins: Int = 0
    
    private init() {
        loadCoins()
    }
    
    func loadCoins() {
        coins = defaults.integer(forKey: key)
    }
    
    func saveCoins() {
        defaults.set(coins, forKey: key)
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
        saveCoins()
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        saveCoins()
        return true
    }
    
    func hasEnoughCoins(_ amount: Int) -> Bool {
        return coins >= amount
    }
}

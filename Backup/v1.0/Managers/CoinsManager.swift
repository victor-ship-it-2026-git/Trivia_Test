import Foundation
internal import Combine

class CoinsManager: ObservableObject {
    static let shared = CoinsManager()
    private let defaults = UserDefaults.standard
    private let key = "user_coins"
    
    @Published var coins: Int = 0 {
        didSet {
            saveCoins()
        }
    }
    
    private init() {
        loadCoins()
    }
    
    func loadCoins() {
        coins = defaults.integer(forKey: key)
        // Add some default coins if this is first launch
        if coins == 0 && !defaults.bool(forKey: "has_launched_before") {
            coins = 500 // Give 500 coins to start with
            defaults.set(true, forKey: "has_launched_before")
            saveCoins()
        }
    }
    
    func saveCoins() {
        defaults.set(coins, forKey: key)
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
        print("💰 Added \(amount) coins. Total: \(coins)")
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        guard coins >= amount else {
            print("❌ Not enough coins. Has: \(coins), Needs: \(amount)")
            return false
        }
        coins -= amount
        print("💰 Spent \(amount) coins. Remaining: \(coins)")
        return true
    }
    
    func hasEnoughCoins(_ amount: Int) -> Bool {
        return coins >= amount
    }
}

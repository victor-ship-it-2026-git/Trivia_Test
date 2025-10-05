//
//  PowerUpManager.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//



import Foundation
internal import Combine

class PowerUpManager: ObservableObject {
    static let shared = PowerUpManager()
    private let defaults = UserDefaults.standard
    private let key = "powerups"
    
    @Published var powerUps: [PowerUp] = []
    
    private init() {
        loadPowerUps()
    }
    
    func loadPowerUps() {
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([PowerUp].self, from: data) {
            powerUps = decoded
        } else {
            // Initialize with default power-ups
            powerUps = [
                PowerUp(type: .doublePoints, quantity: 1),
                PowerUp(type: .freezeTime, quantity: 1),
                PowerUp(type: .autoCorrect, quantity: 0)
            ]
            savePowerUps()
        }
    }
    
    func savePowerUps() {
        if let encoded = try? JSONEncoder().encode(powerUps) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func activatePowerUp(type: PowerUpType) -> Bool {
        guard let index = powerUps.firstIndex(where: { $0.type == type }),
              powerUps[index].quantity > 0 else {
            return false
        }
        
        powerUps[index].quantity -= 1
        powerUps[index].isActive = true
        savePowerUps()
        return true
    }
    
    func deactivatePowerUp(type: PowerUpType) {
        if let index = powerUps.firstIndex(where: { $0.type == type }) {
            powerUps[index].isActive = false
            savePowerUps()
        }
    }
    
    func addPowerUp(type: PowerUpType, quantity: Int = 1) {
        if let index = powerUps.firstIndex(where: { $0.type == type }) {
            powerUps[index].quantity += quantity
        } else {
            powerUps.append(PowerUp(type: type, quantity: quantity))
        }
        savePowerUps()
    }
    
    func isActive(type: PowerUpType) -> Bool {
        return powerUps.first(where: { $0.type == type })?.isActive ?? false
    }
    
    func getQuantity(for type: PowerUpType) -> Int {
        return powerUps.first(where: { $0.type == type })?.quantity ?? 0
    }
}

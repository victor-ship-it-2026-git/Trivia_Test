//
//  LifelineManager.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//



import Foundation
internal import Combine

class LifelineManager: ObservableObject {
    static let shared = LifelineManager()
    private let defaults = UserDefaults.standard
    private let key = "lifelines"
    
    @Published var lifelines: [Lifeline] = []
    
    private init() {
        loadLifelines()
    }
    
    func loadLifelines() {
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Lifeline].self, from: data) {
            lifelines = decoded
        } else {
            // Initialize with default lifelines
            lifelines = [
                Lifeline(type: .fiftyFifty, quantity: 3),
                Lifeline(type: .skip, quantity: 2),
                Lifeline(type: .extraTime, quantity: 2)
            ]
            saveLifelines()
        }
    }
    
    func saveLifelines() {
        if let encoded = try? JSONEncoder().encode(lifelines) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func getLifeline(type: LifelineType) -> Lifeline? {
        return lifelines.first(where: { $0.type == type })
    }
    
    func useLifeline(type: LifelineType) -> Bool {
        guard let index = lifelines.firstIndex(where: { $0.type == type }),
              lifelines[index].quantity > 0 else {
            return false
        }
        
        lifelines[index].quantity -= 1
        saveLifelines()
        return true
    }
    
    func addLifeline(type: LifelineType, quantity: Int = 1) {
        if let index = lifelines.firstIndex(where: { $0.type == type }) {
            lifelines[index].quantity += quantity
        } else {
            lifelines.append(Lifeline(type: type, quantity: quantity))
        }
        saveLifelines()
    }
    
    func getQuantity(for type: LifelineType) -> Int {
        return lifelines.first(where: { $0.type == type })?.quantity ?? 0
    }
}

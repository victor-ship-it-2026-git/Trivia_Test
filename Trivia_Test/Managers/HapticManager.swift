//
//  HapticManager.swift
//  Trivia_Test
//
//  Created by Win on 9/10/2568 BE.
//


//
//  HapticManager.swift
//  Trivia_Test
//
//  Created by Win
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // Light impact - for small interactions like button taps
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    // Medium impact - for standard interactions
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // Heavy impact - for important actions
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // Success - for correct answers, purchases, completions
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Warning - for time running out
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    // Error - for wrong answers, insufficient coins
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // Selection - for picking options
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

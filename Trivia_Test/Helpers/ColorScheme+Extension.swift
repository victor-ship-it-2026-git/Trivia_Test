//
//  asdf.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//


import SwiftUI

extension Color {
    static let adaptiveBackground = Color("AdaptiveBackground")
    static let adaptiveCardBackground = Color("AdaptiveCardBackground")
    static let adaptiveText = Color("AdaptiveText")
    static let adaptiveSecondaryText = Color("AdaptiveSecondaryText")
    static let adaptiveBorder = Color("AdaptiveBorder")
}

// If you don't want to use Asset Catalog, use these:
extension Color {
    static var dynamicBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1) :
                UIColor.systemBackground
        })
    }
    
    static var dynamicCardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1) :
                UIColor.white
        })
    }
    
    static var dynamicText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor.white :
                UIColor.black
        })
    }
    
    static var dynamicSecondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor.lightGray :
                UIColor.darkGray
        })
    }
}


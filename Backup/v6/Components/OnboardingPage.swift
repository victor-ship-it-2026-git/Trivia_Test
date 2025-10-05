//
//  OnboardingPage.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import SwiftUI

struct OnboardingPage: View {
    let emoji: String
    let title: String
    let description: String
    let pageNumber: Int
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text(emoji)
                .font(.system(size: 100))
                .scaleEffect(appear ? 1.0 : 0.5)
                .opacity(appear ? 1 : 0)
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .offset(y: appear ? 0 : 20)
                .opacity(appear ? 1 : 0)
            
            Text(description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
                .offset(y: appear ? 0 : 20)
                .opacity(appear ? 1 : 0)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appear = true
            }
        }
    }
}

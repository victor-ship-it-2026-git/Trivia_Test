//
//  SplashView.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🧠")
                    .font(.system(size: 120))
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("Trivia Master")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("Test Your Knowledge")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1.0
            }
        }
    }
}

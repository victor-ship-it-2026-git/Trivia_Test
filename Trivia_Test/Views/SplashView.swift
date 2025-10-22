
import SwiftUI

struct SplashView: View {
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var bounceOffset: CGFloat = 0
    @State private var progress: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Animated dots and infinity symbol
                ZStack {
                    // Spinning dots container
                    ZStack {
                        // Top dot - Yellow
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 16, height: 16)
                            .offset(y: -50)
                        
                        // Bottom dot - Purple (70% opacity)
                        Circle()
                            .fill(Color.purple.opacity(0.7))
                            .frame(width: 16, height: 16)
                            .offset(y: 50)
                        
                        // Left dot - Yellow (50% opacity)
                        Circle()
                            .fill(Color.yellow.opacity(0.5))
                            .frame(width: 16, height: 16)
                            .offset(x: -50)
                        
                        // Right dot - Purple (30% opacity)
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 16, height: 16)
                            .offset(x: 50)
                    }
                    .rotationEffect(.degrees(rotation))
                    
                    // Bouncing infinity symbol
                    Text("∞")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color.yellow)
                        .offset(y: bounceOffset)
                }
                .frame(height: 150)
                
                // App Title
                Text("Trivia Time")
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundColor(Color(red: 0.12, green: 0.07, blue: 0.21))
                    .opacity(opacity)
                
                // Subtitle
                Text("Getting the fun ready...")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.12, green: 0.07, blue: 0.21).opacity(0.7))
                    .opacity(opacity)
                
                Spacer()
                
                // Progressive loading bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow)
                        .frame(width: 300 * progress, height: 8)
                }
                .frame(width: 300)
                .padding(.bottom, 50)
                .opacity(opacity)
            }
            .padding()
        }
        .onAppear {
            // Fade in elements
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1.0
            }
            
            // Continuous spinning animation for dots
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Bouncing animation for infinity symbol
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                bounceOffset = -15
            }
            
            // Progressive loading bar animation
            withAnimation(.easeInOut(duration: 2.5)) {
                progress = 1.0
            }
        }
    }
}

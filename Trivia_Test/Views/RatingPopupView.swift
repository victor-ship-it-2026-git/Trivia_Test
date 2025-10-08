// MARK: - RatingPopupView.swift
import SwiftUI

struct RatingPopupView: View {
    @Binding var isPresented: Bool
    @State private var selectedStars: Int = 0
    @State private var showThankYouMessage = false
    @State private var animateStars = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissing when tapping outside
                }
            
            // Rating card
            VStack(spacing: 0) {
                if showThankYouMessage {
                    thankYouView
                } else {
                    ratingView
                }
            }
            .frame(width: 320)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.dynamicCardBackground)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(animateStars ? 1.0 : 0.8)
            .opacity(animateStars ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateStars = true
            }
        }
    }
    
    // MARK: - Rating View
    private var ratingView: some View {
        VStack(spacing: 25) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text("⭐️")
                    .font(.system(size: 45))
            }
            .padding(.top, 30)
            
            // Title
            Text("Enjoying Trivia App?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.dynamicText)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text("Tap a star to rate our app")
                .font(.subheadline)
                .foregroundColor(.dynamicSecondaryText)
                .multilineTextAlignment(.center)
            
            // Stars
            HStack(spacing: 15) {
                ForEach(1...5, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedStars = index
                        }
                        handleStarSelection(index)
                    }) {
                        Image(systemName: index <= selectedStars ? "star.fill" : "star")
                            .font(.system(size: 35))
                            .foregroundColor(index <= selectedStars ? .yellow : .gray.opacity(0.3))
                            .scaleEffect(index <= selectedStars ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedStars)
                    }
                }
            }
            .padding(.vertical, 10)
            
            // Not Now Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isPresented = false
                }
            }) {
                Text("Not Now")
                    .font(.subheadline)
                    .foregroundColor(.dynamicSecondaryText)
                    .padding(.vertical, 12)
            }
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Thank You View
    private var thankYouView: some View {
        VStack(spacing: 25) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text("💙")
                    .font(.system(size: 45))
            }
            .padding(.top, 30)
            .scaleEffect(animateStars ? 1.0 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: animateStars)
            
            // Title
            Text("Thank You!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.dynamicText)
                .opacity(animateStars ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.2), value: animateStars)
            
            // Message
            Text("We will try our best to be better than this")
                .font(.body)
                .foregroundColor(.dynamicSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(animateStars ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.3), value: animateStars)
            
            // Stars Display
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .font(.system(size: 25))
                        .foregroundColor(index <= selectedStars ? .yellow : .gray.opacity(0.3))
                }
            }
            .padding(.vertical, 5)
            
            // OK Button
            Button(action: {
                RatingManager.shared.userRatedApp()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isPresented = false
                }
            }) {
                Text("OK")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Handle Star Selection
    private func handleStarSelection(_ stars: Int) {
        if stars == 5 {
            // Show native iOS rating popup
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                RatingManager.shared.requestAppStoreReview()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isPresented = false
                }
            }
        } else if stars >= 1 && stars <= 4 {
            // Show thank you message
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showThankYouMessage = true
                    animateStars = false
                }
                // Re-trigger animation for thank you view
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        animateStars = true
                    }
                }
            }
        }
    }
}
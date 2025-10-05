//
//  OnboardingView.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        emoji: "🎮",
                        title: "Welcome to Trivia Master!",
                        description: "The game is very simple. Test your knowledge across multiple categories and difficulty levels.",
                        pageNumber: 0
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        emoji: "✅",
                        title: "How to Win",
                        description: "If you correctly answer the question, you get a point and proceed to the next question. Easy!",
                        pageNumber: 1
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        emoji: "⏰",
                        title: "Beat the Clock",
                        description: "You have 30 seconds per question. Choose wisely and quickly!",
                        pageNumber: 2
                    )
                    .tag(2)
                    
                    OnboardingPage(
                        emoji: "📺",
                        title: "The Challenge",
                        description: "If you can't answer within the time limit, or if you choose the wrong answer, you will fail the challenge and need to watch boring ads as punishment 😈",
                        pageNumber: 3
                    )
                    .tag(3)
                    
                    OnboardingPage(
                        emoji: "🏆",
                        title: "Ready to Play?",
                        description: "Choose wisely, answer quickly, and climb the leaderboard. Good luck!",
                        pageNumber: 4
                    )
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.5))
                            .frame(width: 10, height: 10)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(width: 120, height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < 4 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onComplete()
                        }
                    }) {
                        Text(currentPage == 4 ? "Let's Go!" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

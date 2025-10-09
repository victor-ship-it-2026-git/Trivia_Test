//
//  ShareManager.swift
//  Trivia_Test
//
//  Created by Win
//

import Foundation
import UIKit
import SwiftUI

class ShareManager {
    static let shared = ShareManager()
    
    private init() {}
    
    // MARK: - Generate Share Image from View
    
    @MainActor
    func generateShareImage(from view: AnyView, size: CGSize = CGSize(width: 1080, height: 1920)) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        
        // Force layout
        controller.view.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    // MARK: - Share to Social Media
    
    func shareToSocialMedia(image: UIImage, text: String, from viewController: UIViewController) {
        let activityItems: [Any] = [text, image]
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Exclude some activities if needed
        activityViewController.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]
        
        // For iPad support
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                       y: viewController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityViewController, animated: true)
    }
    
    // MARK: - Generate Share Text
    
    func generateShareText(score: Int, total: Int, category: String, difficulty: String, rank: Int? = nil) -> String {
        let percentage = total > 0 ? (score * 100) / total : 0
        
        var text = "🎯 I just scored \(score)/\(total) (\(percentage)%) on Trivia App!\n"
        text += "📚 Category: \(category)\n"
        text += "⚡️ Difficulty: \(difficulty)\n"
        
        if let rank = rank {
            text += "🏆 Global Rank: #\(rank)\n"
        }
        
        text += "\nCan you beat my score? Download Trivia App now! 🧠✨"
        
        return text
    }
    
    // MARK: - Generate Leaderboard Share Text
    
    func generateLeaderboardShareText(playerName: String, rank: Int, score: Int, total: Int) -> String {
        let percentage = total > 0 ? (score * 100) / total : 0
        
        let emoji = rank <= 3 ? ["🥇", "🥈", "🥉"][rank - 1] : "🏆"
        
        var text = "\(emoji) I'm ranked #\(rank) on the Global Leaderboard!\n"
        text += "👤 Player: \(playerName)\n"
        text += "🎯 Score: \(score)/\(total) (\(percentage)%)\n"
        text += "\nThink you can beat me? Download Trivia App! 🧠✨"
        
        return text
    }
}

// MARK: - Share Card Views

struct ResultsShareCard: View {
    let score: Int
    let totalQuestions: Int
    let category: String
    let difficulty: String
    let playerName: String
    
    var percentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return (score * 100) / totalQuestions
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Branding
                VStack(spacing: 10) {
                    Text("🧠")
                        .font(.system(size: 80))
                    Text("TRIVIA APP")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Score Display
                VStack(spacing: 20) {
                    Text("MY SCORE")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(score)/\(totalQuestions)")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(percentage)% CORRECT")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.yellow)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.2))
                        .shadow(color: Color.black.opacity(0.3), radius: 20)
                )
                
                // Details
                VStack(spacing: 15) {
                    HStack(spacing: 20) {
                        DetailBadge(icon: "📚", text: category)
                        DetailBadge(icon: "⚡️", text: difficulty)
                    }
                    
                    Text("Player: \(playerName)")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Call to Action
                Text("Can you beat my score?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.3))
                    )
                
                Text("Download Trivia App")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
            .padding(40)
        }
        .frame(width: 1080, height: 1920)
    }
}

struct LeaderboardShareCard: View {
    let playerName: String
    let rank: Int
    let score: Int
    let totalQuestions: Int
    let category: String
    let difficulty: String
    
    var percentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return (score * 100) / totalQuestions
    }
    
    var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏆"
        }
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Branding
                VStack(spacing: 10) {
                    Text("🧠")
                        .font(.system(size: 60))
                    Text("TRIVIA APP")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("GLOBAL LEADERBOARD")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Rank Display
                VStack(spacing: 20) {
                    Text(rankEmoji)
                        .font(.system(size: 120))
                    
                    Text("RANK #\(rank)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(50)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.2))
                        .shadow(color: Color.black.opacity(0.3), radius: 20)
                )
                
                // Player Info
                VStack(spacing: 20) {
                    Text(playerName)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(score)/\(totalQuestions) • \(percentage)%")
                        .font(.system(size: 32))
                        .foregroundColor(.yellow)
                    
                    HStack(spacing: 20) {
                        DetailBadge(icon: "📚", text: category)
                        DetailBadge(icon: "⚡️", text: difficulty)
                    }
                }
                
                Spacer()
                
                // Call to Action
                VStack(spacing: 10) {
                    Text("Think you can beat me?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Download Trivia App & Join the Competition!")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                )
                
                Spacer()
            }
            .padding(40)
        }
        .frame(width: 1080, height: 1920)
    }
}

struct DetailBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.title2)
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.3))
        )
    }
}

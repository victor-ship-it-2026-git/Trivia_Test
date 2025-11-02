
import Foundation
internal import Combine

class DailyChallengeManager: ObservableObject {
    static let shared = DailyChallengeManager()
    private let defaults = UserDefaults.standard
    private let challengeKey = "daily_challenge"
    private let lastDateKey = "last_challenge_date"
    
    @Published var currentChallenge: DailyChallenge?
    
    private init() {
        loadOrCreateChallenge()
    }
    
    func loadOrCreateChallenge() {
        let lastDate = defaults.object(forKey: lastDateKey) as? Date
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            if today > lastDay {
                createNewChallenge()
            } else {
                loadChallenge()
            }
        } else {
            createNewChallenge()
        }
    }
    
    private func loadChallenge() {
        if let data = defaults.data(forKey: challengeKey),
           let decoded = try? JSONDecoder().decode(DailyChallenge.self, from: data) {
            currentChallenge = decoded
        } else {
            createNewChallenge()
        }
    }
    
    private func createNewChallenge() {
        let challenges: [(ChallengeType, Int, ChallengeReward)] = [
            (.answerCorrectly, 10, ChallengeReward(lifelines: [.fiftyFifty: 2], coins: 100)),
            (.perfectStreak, 5, ChallengeReward(lifelines: [.skip: 1, .extraTime: 1], coins: 150)),
            (.completeQuizzes, 3, ChallengeReward(lifelines: [.fiftyFifty: 1, .skip: 1, .extraTime: 1], coins: 200)),
            (.speedRun, 8, ChallengeReward(lifelines: [.extraTime: 2], coins: 120)),
        ]
        
        let randomChallenge = challenges.randomElement()!
        currentChallenge = DailyChallenge(
            type: randomChallenge.0,
            targetValue: randomChallenge.1,
            reward: randomChallenge.2
        )
        
        saveChallenge()
        defaults.set(Date(), forKey: lastDateKey)
    }
    
    func updateProgress(for type: ChallengeType, amount: Int = 1) {
        guard var challenge = currentChallenge,
              challenge.challengeType == type,
              !challenge.isCompleted else {
            return
        }
        
        challenge.currentProgress += amount
        
        if challenge.currentProgress >= challenge.targetValue {
            challenge.isCompleted = true
            
        
             
            awardReward(challenge.reward)
        }
        
        currentChallenge = challenge
        saveChallenge()
    }
    
    private func awardReward(_ reward: ChallengeReward) {
        // Note: Award lifelines
        for (type, quantity) in reward.lifelines {
            LifelineManager.shared.addLifeline(type: type, quantity: quantity)
        }
        
        // Note: Award coins
        CoinsManager.shared.addCoins(reward.coins)
    }
    
    private func saveChallenge() {
        if let challenge = currentChallenge,
           let encoded = try? JSONEncoder().encode(challenge) {
            defaults.set(encoded, forKey: challengeKey)
        }
    }
}

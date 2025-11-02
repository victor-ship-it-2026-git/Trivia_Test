
import Foundation

class LeaderboardManager {
    static let shared = LeaderboardManager()
    private let defaults = UserDefaults.standard
    private let key = "leaderboard"
    
    private init() {}
    
    func getLeaderboard() -> [LeaderboardEntry] {
        guard let data = defaults.data(forKey: key),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    func saveLeaderboard(_ entries: [LeaderboardEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: key)
        }
    }
    
    func addEntry(_ entry: LeaderboardEntry) {
        var leaderboard = getLeaderboard()
        leaderboard.append(entry)
        leaderboard.sort { $0.percentage > $1.percentage }
        
        if leaderboard.count > 50 {
            leaderboard = Array(leaderboard.prefix(50))
        }
        
        saveLeaderboard(leaderboard)
    }
    
    func clearLeaderboard() {
        saveLeaderboard([])
    }
}

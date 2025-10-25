import Foundation
import FirebaseDatabase
internal import Combine

class FirebaseLeaderboardManager: ObservableObject {
    static let shared = FirebaseLeaderboardManager()
    
    private let database = Database.database().reference()
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var leaderboardHandle: DatabaseHandle?
    
    private init() {
        observeLeaderboard()
    }
    
    // MARK: - Observe Leaderboard (Real-time Updates)
    
    func observeLeaderboard() {
        isLoading = true
        
        leaderboardHandle = database.child("leaderboard")
            .queryOrdered(byChild: "percentage")
            .queryLimited(toLast: 100)
            .observe(.value) { [weak self] snapshot in
                guard let self = self else { return }
                
                var entries: [LeaderboardEntry] = []
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let dict = snapshot.value as? [String: Any] {
                        
                        if let playerName = dict["playerName"] as? String,
                           let score = dict["score"] as? Int,
                           let totalQuestions = dict["totalQuestions"] as? Int,
                           let category = dict["category"] as? String,
                           let difficulty = dict["difficulty"] as? String,
                           let timestamp = dict["timestamp"] as? TimeInterval {
                            
                            let entry = LeaderboardEntry(
                                id: UUID(uuidString: snapshot.key) ?? UUID(),
                                playerName: playerName,
                                score: score,
                                totalQuestions: totalQuestions,
                                category: category,
                                difficulty: difficulty,
                                date: Date(timeIntervalSince1970: timestamp)
                            )
                            entries.append(entry)
                        }
                    }
                }
                
                entries.sort { $0.percentage > $1.percentage }
                
                DispatchQueue.main.async {
                    self.leaderboard = entries
                    self.isLoading = false
                }
            }
    }
    
    // MARK: - Add Entry to Leaderboard
    
    func addEntry(_ entry: LeaderboardEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        let entryRef = database.child("leaderboard").childByAutoId()
        
        let entryData: [String: Any] = [
            "playerName": entry.playerName,
            "score": entry.score,
            "totalQuestions": entry.totalQuestions,
            "category": entry.category,
            "difficulty": entry.difficulty,
            "percentage": entry.percentage,
            "timestamp": entry.date.timeIntervalSince1970
        ]
        
        entryRef.setValue(entryData) { error, _ in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save: \(error.localizedDescription)"
                    CrashlyticsManager.shared.logError(error, additionalInfo: [
                        "player_name": entry.playerName,
                        "category": entry.category,
                        "difficulty": entry.difficulty
                    ])
                    completion(.failure(error))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Delete User Entries
    
    func deleteUserEntries(playerName: String, completion: @escaping (Result<Int, Error>) -> Void) {
        database.child("leaderboard")
            .queryOrdered(byChild: "playerName")
            .queryEqual(toValue: playerName)
            .observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    DispatchQueue.main.async {
                        completion(.success(0))
                    }
                    return
                }
                
                var deletedCount = 0
                let dispatchGroup = DispatchGroup()
                var lastError: Error?
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot {
                        dispatchGroup.enter()
                        snapshot.ref.removeValue { error, _ in
                            if let error = error {
                                lastError = error
                                CrashlyticsManager.shared.logError(error, additionalInfo: [
                                    "action": "delete_user_entries",
                                    "player_name": playerName
                                ])
                            } else {
                                deletedCount += 1
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    if let error = lastError {
                        completion(.failure(error))
                    } else {
                        // Log analytics
                        AnalyticsManager.shared.logCustomEvent(
                            eventName: "user_data_deleted",
                            parameters: [
                                "player_name": playerName,
                                "entries_deleted": deletedCount
                            ]
                        )
                        completion(.success(deletedCount))
                    }
                }
            }
    }
    
    // MARK: - Get Leaderboard by Category
    
    func getLeaderboardByCategory(_ category: String, completion: @escaping ([LeaderboardEntry]) -> Void) {
        database.child("leaderboard")
            .queryOrdered(byChild: "category")
            .queryEqual(toValue: category)
            .observeSingleEvent(of: .value) { snapshot in
                var entries: [LeaderboardEntry] = []
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let dict = snapshot.value as? [String: Any] {
                        
                        if let playerName = dict["playerName"] as? String,
                           let score = dict["score"] as? Int,
                           let totalQuestions = dict["totalQuestions"] as? Int,
                           let category = dict["category"] as? String,
                           let difficulty = dict["difficulty"] as? String,
                           let timestamp = dict["timestamp"] as? TimeInterval {
                            
                            let entry = LeaderboardEntry(
                                id: UUID(uuidString: snapshot.key) ?? UUID(),
                                playerName: playerName,
                                score: score,
                                totalQuestions: totalQuestions,
                                category: category,
                                difficulty: difficulty,
                                date: Date(timeIntervalSince1970: timestamp)
                            )
                            entries.append(entry)
                        }
                    }
                }
                
                entries.sort { $0.percentage > $1.percentage }
                
                DispatchQueue.main.async {
                    completion(entries)
                }
            }
    }
    
    // MARK: - Get Leaderboard by Difficulty
    
    func getLeaderboardByDifficulty(_ difficulty: String, completion: @escaping ([LeaderboardEntry]) -> Void) {
        database.child("leaderboard")
            .queryOrdered(byChild: "difficulty")
            .queryEqual(toValue: difficulty)
            .observeSingleEvent(of: .value) { snapshot in
                var entries: [LeaderboardEntry] = []
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let dict = snapshot.value as? [String: Any] {
                        
                        if let playerName = dict["playerName"] as? String,
                           let score = dict["score"] as? Int,
                           let totalQuestions = dict["totalQuestions"] as? Int,
                           let category = dict["category"] as? String,
                           let difficulty = dict["difficulty"] as? String,
                           let timestamp = dict["timestamp"] as? TimeInterval {
                            
                            let entry = LeaderboardEntry(
                                id: UUID(uuidString: snapshot.key) ?? UUID(),
                                playerName: playerName,
                                score: score,
                                totalQuestions: totalQuestions,
                                category: category,
                                difficulty: difficulty,
                                date: Date(timeIntervalSince1970: timestamp)
                            )
                            entries.append(entry)
                        }
                    }
                }
                
                entries.sort { $0.percentage > $1.percentage }
                
                DispatchQueue.main.async {
                    completion(entries)
                }
            }
    }
    
    // MARK: - Get Top Players
    
    func getTopPlayers(limit: Int = 50, completion: @escaping ([LeaderboardEntry]) -> Void) {
        database.child("leaderboard")
            .queryOrdered(byChild: "percentage")
            .queryLimited(toLast: UInt(limit))
            .observeSingleEvent(of: .value) { snapshot in
                var entries: [LeaderboardEntry] = []
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let dict = snapshot.value as? [String: Any] {
                        
                        if let playerName = dict["playerName"] as? String,
                           let score = dict["score"] as? Int,
                           let totalQuestions = dict["totalQuestions"] as? Int,
                           let category = dict["category"] as? String,
                           let difficulty = dict["difficulty"] as? String,
                           let timestamp = dict["timestamp"] as? TimeInterval {
                            
                            let entry = LeaderboardEntry(
                                id: UUID(uuidString: snapshot.key) ?? UUID(),
                                playerName: playerName,
                                score: score,
                                totalQuestions: totalQuestions,
                                category: category,
                                difficulty: difficulty,
                                date: Date(timeIntervalSince1970: timestamp)
                            )
                            entries.append(entry)
                        }
                    }
                }
                
                entries.sort { $0.percentage > $1.percentage }
                
                DispatchQueue.main.async {
                    completion(entries)
                }
            }
    }
    
    // MARK: - Clear Local Cache
    
    func clearLocalCache() {
        leaderboard = []
    }
    
    // MARK: - Stop Observing
    
    func stopObserving() {
        if let handle = leaderboardHandle {
            database.child("leaderboard").removeObserver(withHandle: handle)
        }
    }
    
    deinit {
        stopObserving()
    }
}

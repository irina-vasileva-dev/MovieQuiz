import UIKit

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswersTotal, questionsTotal, gamesCount
        case bestGameCorrect, bestGameTotal, bestGameDate
    }
    
    // MARK: - Public Properties
    
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            GameResult(
                correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
                total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
                date: storage
                    .object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            )
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let correct = storage.integer(forKey: Keys.correctAnswersTotal.rawValue)
        let total = storage.integer(forKey: Keys.questionsTotal.rawValue)
        guard total > 0 else { return 0 }
        return (Double(correct) / Double(total)) * 100
    }
    
    // MARK: - Public Methods
    
    func store(correct count: Int, total amount: Int) {
        guard count >= 0, amount > 0, count <= amount else { return }
        
        let currentCorrect = storage.integer(
            forKey: Keys.correctAnswersTotal.rawValue
        ) + count
        let currentTotal = storage.integer(
            forKey: Keys.questionsTotal.rawValue
        ) + amount
        
        storage.set(currentCorrect, forKey: Keys.correctAnswersTotal.rawValue)
        storage.set(currentTotal, forKey: Keys.questionsTotal.rawValue)
        storage.set(gamesCount + 1, forKey: Keys.gamesCount.rawValue)
        
        let currentGame = GameResult(
            correct: count,
            total: amount,
            date: Date()
        )
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}

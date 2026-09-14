import Foundation

/// Zentrale Persistenz über UserDefaults. Alle Reads/Writes laufen über diese Klasse.
final class GameState {

    static let shared = GameState()

    private let defaults: UserDefaults
    private let calendar = Calendar.current

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        refreshDailyState()
    }

    // MARK: - Stored Values

    var bestScore: Int {
        get { defaults.integer(forKey: PersistenceKey.best) }
        set { defaults.set(newValue, forKey: PersistenceKey.best) }
    }

    var coins: Int {
        get { defaults.integer(forKey: PersistenceKey.coins) }
        set { defaults.set(newValue, forKey: PersistenceKey.coins) }
    }

    var gamesPlayed: Int {
        get { defaults.integer(forKey: PersistenceKey.games) }
        set { defaults.set(newValue, forKey: PersistenceKey.games) }
    }

    var streakDays: Int {
        get { defaults.integer(forKey: PersistenceKey.streak) }
        set { defaults.set(newValue, forKey: PersistenceKey.streak) }
    }

    var lastClaimDay: String {
        get { defaults.string(forKey: PersistenceKey.lastDay) ?? "" }
        set { defaults.set(newValue, forKey: PersistenceKey.lastDay) }
    }

    var dailyClaimed: Bool {
        get { defaults.bool(forKey: PersistenceKey.dailyClaimed) }
        set { defaults.set(newValue, forKey: PersistenceKey.dailyClaimed) }
    }

    var todayString: String {
        dayFormatter.string(from: Date())
    }

    /// Tag 1–7 im aktuellen Streak-Zyklus.
    var dailyDayIndex: Int {
        max(0, streakDays % DailyBonus.rewards.count)
    }

    var todaysReward: Int {
        DailyBonus.rewards[dailyDayIndex]
    }

    var isDailyAvailable: Bool {
        refreshDailyState()
        return dailyClaimed == false
    }

    // MARK: - Highscore / Spiele

    @discardableResult
    func registerFinalScore(_ score: Int) -> Bool {
        gamesPlayed += 1
        let isNewBest = score > bestScore
        if isNewBest {
            bestScore = score
        }
        return isNewBest
    }

    func updateBestIfNeeded(_ score: Int) -> Bool {
        guard score > bestScore else { return false }
        bestScore = score
        return true
    }

    // MARK: - Daily Bonus

    /// Setzt den Tages-Claim zurück und bricht den Streak, wenn ein Tag verpasst wurde.
    func refreshDailyState() {
        let today = todayString
        if lastClaimDay == today {
            return
        }

        dailyClaimed = false

        guard lastClaimDay.isEmpty == false,
              let lastDate = dayFormatter.date(from: lastClaimDay) else {
            return
        }

        let daysMissed = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        if daysMissed > 1 {
            streakDays = 0
        }
    }

    func claimDailyBonus() -> Int {
        refreshDailyState()
        let reward = todaysReward
        coins += reward
        streakDays += 1
        dailyClaimed = true
        lastClaimDay = todayString
        return reward
    }
}

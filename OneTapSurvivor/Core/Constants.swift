import UIKit

// ─────────────────────────────────────────────
// MARK: - Constants
// ─────────────────────────────────────────────
// SCHRITT 1: Hier deine AppLovin-Keys eintragen
//   Dashboard: https://dash.applovin.com
//   → Account → Keys → SDK Key
//   → Apps → [deine App] → Ad Units → Rewarded → Unit ID kopieren
// ─────────────────────────────────────────────

enum Constants {

    // AppLovin MAX — SDK Key aus Account-Settings
    static let maxSdkKey = "HIER_DEINEN_APPLOVIN_SDK_KEY_EINTRAGEN"

    // Rewarded Ad Unit ID aus der MAX Ad Unit
    static let maxRewardedAdUnitID = "HIER_DEINE_AD_UNIT_ID_EINTRAGEN"

    static let leaderboardID = "ots.highscore"
    static let bundleID = "eu.design-code.OneTapSurvivor"
    static let appDisplayName = "One Tap Survivor"

    // ─────────────────────────────────────────────
    // GDPR / Einwilligung (Google UMP via AppLovin MAX)
    // Diese Datenschutz-URL wird im Consent-Dialog verlinkt.
    // Standard: GitHub-Pages-Seite aus dem docs/-Ordner.
    // Bei eigener Domain hier anpassen.
    // ─────────────────────────────────────────────
    static let privacyPolicyURL = "https://marcoliverpaasche.github.io/OneTapSurvivor/"

    /// Optionale AGB/Terms-of-Service-URL. Leer lassen, wenn nicht vorhanden.
    static let termsOfServiceURL = ""

    /// true, sobald echte AppLovin-Keys eingetragen sind (kein "HIER_"-Platzhalter).
    static var hasValidAdKeys: Bool {
        maxSdkKey.isEmpty == false &&
        maxRewardedAdUnitID.isEmpty == false &&
        maxSdkKey.contains("HIER_") == false &&
        maxRewardedAdUnitID.contains("HIER_") == false
    }
}

// MARK: - Design-System

enum Palette {
    static let bg = UIColor(hex: "#080C14")
    static let surface = UIColor(hex: "#0F1623")
    static let border = UIColor(hex: "#1C2738")
    static let accent = UIColor(hex: "#00E5FF")
    static let danger = UIColor(hex: "#FF3B55")
    static let warn = UIColor(hex: "#FFB800")
    static let green = UIColor(hex: "#00E676")
    static let text = UIColor(hex: "#E8EDF5")
    static let muted = UIColor(hex: "#5A6880")
}

enum Typography {
    static func score() -> UIFont { UIFont.systemFont(ofSize: 42, weight: .heavy) }
    static func title(_ size: CGFloat = 22) -> UIFont { UIFont.systemFont(ofSize: size, weight: .heavy) }
    static func body() -> UIFont { UIFont.systemFont(ofSize: 14, weight: .regular) }
    static func label() -> UIFont { UIFont.systemFont(ofSize: 11, weight: .medium) }
    static func button() -> UIFont { UIFont.systemFont(ofSize: 16, weight: .heavy) }
}

enum Layout {
    static let cornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 24
    static let spacing: CGFloat = 16
}

// MARK: - Spielmechanik

enum Gameplay {
    static let startSpeed: CGFloat = 220
    static let maxSpeed: CGFloat = 700
    static let gravity: CGFloat = -1200
    static let jumpForce: CGFloat = 580
    static let playerRadius: CGFloat = 22
    static let playerHitboxRadius: CGFloat = 17
    static let playerX: CGFloat = 120
    static let startingLives = 3
    static let continueCountdownSeconds = 5
    static let damageCooldown: TimeInterval = 1.2
    /// Continue-Werbung erst nach so vielen abgeschlossenen Spielen.
    static let adsAfterGamesPlayed = 2

    /// speed = min(220 + score * 4, 700)
    static func speed(for score: Int) -> CGFloat {
        min(startSpeed + CGFloat(score) * 4, maxSpeed)
    }

    /// gapRatio = max(0.28, 0.38 - score * 0.001)
    static func gapRatio(for score: Int) -> CGFloat {
        max(0.28, 0.38 - CGFloat(score) * 0.001)
    }

    /// Spawn-Abstand in Sekunden: max(90 - score / 2, 50) Frames bei 60 fps.
    static func spawnInterval(for score: Int) -> TimeInterval {
        TimeInterval(max(90 - score / 2, 50)) / 60.0
    }
}

// MARK: - Persistenz

enum PersistenceKey {
    static let best = "ots_best"
    static let coins = "ots_coins"
    static let games = "ots_games"
    static let streak = "ots_streak"
    static let lastDay = "ots_last_day"
    static let dailyClaimed = "ots_daily_claimed"
}

enum DailyBonus {
    static let rewards = [25, 30, 40, 50, 60, 75, 100]
}

import UIKit
import SpriteKit
import GameKit
import AppTrackingTransparency

final class GameViewController: UIViewController {

    private let state = GameState.shared
    private let adManager = AdManager.shared

    private var gameScene: GameScene?
    private var currentScore = 0
    private var scoreDoubled = false
    private var continueTimer: Timer?
    private var continueSeconds = Gameplay.continueCountdownSeconds
    private var didRequestTracking = false
    private var didFinishRun = false

    private let skView = SKView()
    private let startScreen = StartScreenView()
    private let overlay = GameOverlay()
    private let dailyBonus = DailyBonusView()
    private let toastLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg

        setupSKView()
        setupStartScreen()
        setupOverlay()
        setupDailyBonus()
        setupToast()
        refreshStartStats()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestTrackingIfNeeded()
        if ProcessInfo.processInfo.arguments.contains("-autoPlay"), startScreen.isHidden == false {
            beginRun()
        }
    }

    override var prefersStatusBarHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    // MARK: - Setup

    private func setupSKView() {
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        view.addSubview(skView)
        skView.pinEdges(to: view)
    }

    private func setupStartScreen() {
        startScreen.delegate = self
        view.addSubview(startScreen)
        startScreen.pinEdges(to: view)
    }

    private func setupOverlay() {
        overlay.delegate = self
        view.addSubview(overlay)
        overlay.pinEdges(to: view)
    }

    private func setupDailyBonus() {
        dailyBonus.delegate = self
        view.addSubview(dailyBonus)
        dailyBonus.pinEdges(to: view)
    }

    private func setupToast() {
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        toastLabel.textColor = Palette.text
        toastLabel.backgroundColor = Palette.surface
        toastLabel.layer.cornerRadius = 20
        toastLabel.layer.borderWidth = 1
        toastLabel.layer.borderColor = Palette.border.cgColor
        toastLabel.layer.masksToBounds = true
        toastLabel.textAlignment = .center
        toastLabel.alpha = 0
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastLabel)

        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            toastLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func refreshStartStats() {
        state.refreshDailyState()
        startScreen.updateStats(
            best: state.bestScore,
            coins: state.coins,
            games: state.gamesPlayed,
            dailyAvailable: state.dailyClaimed == false
        )
    }

    private func beginRun() {
        continueTimer?.invalidate()
        overlay.hideOverlay()
        dailyBonus.hideBonus()
        scoreDoubled = false
        didFinishRun = false
        startScreen.isHidden = true
        startScreen.isUserInteractionEnabled = false
        overlay.isUserInteractionEnabled = false
        view.layoutIfNeeded()
        skView.layoutIfNeeded()

        let sceneSize = skView.bounds.size.width > 1
            ? skView.bounds.size
            : view.bounds.size
        let scene = GameScene(size: sceneSize)
        scene.scaleMode = .resizeFill
        scene.anchorPoint = .zero
        scene.gameDelegate = self
        gameScene = scene
        skView.presentScene(scene)
    }

    private func returnHome() {
        continueTimer?.invalidate()
        overlay.hideOverlay()
        dailyBonus.hideBonus()
        gameScene = nil
        skView.presentScene(nil)
        startScreen.isHidden = false
        startScreen.isUserInteractionEnabled = true
        refreshStartStats()
    }

    private func presentGameOver() {
        continueTimer?.invalidate()
        currentScore = gameScene?.score ?? currentScore
        let isNewBest = currentScore > state.bestScore
        overlay.showGameOver(score: currentScore, isNewBest: isNewBest, canDouble: scoreDoubled == false)
        if didFinishRun == false {
            didFinishRun = true
            let isNewBest = state.registerFinalScore(currentScore)
            if isNewBest {
                Feedback.best()
            }
            submitScoreToGameCenter(currentScore)
        }
        refreshStartStats()
    }

    private func startContinueCountdown() {
        continueSeconds = Gameplay.continueCountdownSeconds
        continueTimer?.invalidate()
        continueTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.continueSeconds -= 1
            if self.continueSeconds <= 0 {
                self.continueTimer?.invalidate()
                self.presentGameOver()
            } else {
                self.overlay.updateContinueTimer(seconds: self.continueSeconds)
            }
        }
        if let timer = continueTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func submitScoreToGameCenter(_ score: Int) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [Constants.leaderboardID]
        ) { error in
            if let error {
                print("[GameCenter] Submit-Fehler: \(error.localizedDescription)")
            }
        }
    }

    private func showLeaderboard() {
        let controller = GKGameCenterViewController(
            leaderboardID: Constants.leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        controller.gameCenterDelegate = self
        present(controller, animated: true)
    }

    private func showToast(_ message: String, color: UIColor = Palette.text) {
        toastLabel.text = "  \(message)  "
        toastLabel.textColor = color
        UIView.animate(withDuration: 0.2) { self.toastLabel.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            UIView.animate(withDuration: 0.3) { self?.toastLabel.alpha = 0 }
        }
    }

    @objc private func appWillResignActive() {
        gameScene?.pauseForBackground()
    }

    private func requestTrackingIfNeeded() {
        guard didRequestTracking == false else { return }
        didRequestTracking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self, self.startScreen.isHidden == false else { return }
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}

extension GameViewController: StartScreenViewDelegate {
    func startScreenDidTapPlay() {
        beginRun()
    }

    func startScreenDidTapDailyBonus() {
        state.refreshDailyState()
        dailyBonus.configure(
            streak: state.streakDays,
            claimed: state.dailyClaimed,
            reward: state.todaysReward
        )
    }

    func startScreenDidTapLeaderboard() {
        showLeaderboard()
    }
}

extension GameViewController: GameOverlayDelegate {
    func overlayDidWatchAdForLife() {
        continueTimer?.invalidate()
        adManager.showRewardedAd(from: self, placement: .extraLife) { [weak self] success in
            guard let self else { return }
            DispatchQueue.main.async {
                if success {
                    self.overlay.hideOverlay()
                    self.gameScene?.continueAfterAd()
                    self.showToast("💖 +1 Leben! Weiter gehts!", color: Palette.green)
                } else {
                    self.presentGameOver()
                }
            }
        }
    }

    func overlayDidGiveUp() {
        presentGameOver()
    }

    func overlayDidWatchAdForDouble() {
        guard scoreDoubled == false else { return }
        adManager.showRewardedAd(from: self, placement: .doubleScore) { [weak self] success in
            guard let self, success else { return }
            DispatchQueue.main.async {
                self.scoreDoubled = true
                self.currentScore *= 2
                let isNewBest = self.state.updateBestIfNeeded(self.currentScore)
                self.overlay.markScoreDoubled(newScore: self.currentScore, isNewBest: isNewBest)
                self.submitScoreToGameCenter(self.currentScore)
                self.refreshStartStats()
                self.showToast("🎉 Punkte verdoppelt! \(self.currentScore)", color: Palette.green)
            }
        }
    }

    func overlayDidPlayAgain() {
        beginRun()
    }

    func overlayDidGoHome() {
        returnHome()
    }
}

extension GameViewController: DailyBonusViewDelegate {
    func dailyBonusDidRequestAd() {
        state.refreshDailyState()
        if state.dailyClaimed {
            showToast("Heute schon abgeholt! 🕐", color: Palette.danger)
            return
        }

        adManager.showRewardedAd(from: self, placement: .dailyBonus) { [weak self] success in
            guard let self, success else { return }
            DispatchQueue.main.async {
                let reward = self.state.claimDailyBonus()
                self.dailyBonus.configure(
                    streak: self.state.streakDays,
                    claimed: true,
                    reward: reward
                )
                self.refreshStartStats()
                self.showToast("🎁 +\(reward) Coins! Streak: \(self.state.streakDays) Tage", color: Palette.warn)
            }
        }
    }

    func dailyBonusDidDismiss() {
        dailyBonus.hideBonus()
    }
}

extension GameViewController: GameSceneDelegate {
    func gameDidDie(score: Int, isFirstDeath: Bool) {
        currentScore = score
        let canOfferContinue = isFirstDeath && state.gamesPlayed >= Gameplay.adsAfterGamesPlayed
        if canOfferContinue {
            overlay.showContinue(score: score)
            startContinueCountdown()
        } else {
            presentGameOver()
        }
    }
}

extension GameViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

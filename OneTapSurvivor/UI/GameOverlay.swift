import UIKit

protocol GameOverlayDelegate: AnyObject {
    func overlayDidWatchAdForLife()
    func overlayDidGiveUp()
    func overlayDidWatchAdForDouble()
    func overlayDidPlayAgain()
    func overlayDidGoHome()
}

final class GameOverlay: UIView {

    weak var delegate: GameOverlayDelegate?

    private let continueCard = UIView()
    private let gameOverCard = UIView()
    private let continueScoreLabel = UILabel()
    private let continueTimerLabel = UILabel()
    private let finalScoreLabel = UILabel()
    private let newBestBadge = UIView()
    private var doubleButton: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func showContinue(score: Int) {
        isHidden = false
        isUserInteractionEnabled = true
        continueCard.isHidden = false
        gameOverCard.isHidden = true
        continueScoreLabel.text = "\(score)"
        continueTimerLabel.text = "Verfügbar für \(Gameplay.continueCountdownSeconds) Sekunden"
    }

    func updateContinueTimer(seconds: Int) {
        continueTimerLabel.text = "Verfügbar für \(seconds) Sekunden"
    }

    func showGameOver(score: Int, isNewBest: Bool, canDouble: Bool) {
        isHidden = false
        isUserInteractionEnabled = true
        continueCard.isHidden = true
        gameOverCard.isHidden = false
        finalScoreLabel.text = "\(score)"
        finalScoreLabel.textColor = Palette.accent
        newBestBadge.isHidden = isNewBest == false
        doubleButton?.isHidden = canDouble == false
    }

    func markScoreDoubled(newScore: Int, isNewBest: Bool) {
        finalScoreLabel.text = "\(newScore)"
        finalScoreLabel.textColor = Palette.green
        doubleButton?.isHidden = true
        newBestBadge.isHidden = isNewBest == false
    }

    func hideOverlay() {
        isHidden = true
        isUserInteractionEnabled = false
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        isHidden = true
        isUserInteractionEnabled = false

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)
        blur.pinEdges(to: self)

        setupContinueCard()
        setupGameOverCard()
    }

    private func setupContinueCard() {
        continueCard.applyCardStyle()
        continueCard.layer.cornerRadius = 20
        continueCard.translatesAutoresizingMaskIntoConstraints = false
        addSubview(continueCard)

        let icon = UILabel()
        icon.text = "💀"
        icon.font = .systemFont(ofSize: 48)
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Du bist gestorben"
        title.font = Typography.title(22)
        title.textColor = Palette.text
        title.translatesAutoresizingMaskIntoConstraints = false

        continueScoreLabel.font = UIFont.systemFont(ofSize: 56, weight: .heavy)
        continueScoreLabel.textColor = Palette.accent
        continueScoreLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = UILabel()
        subtitle.text = "Werbung schauen für ein Extra-Leben?"
        subtitle.font = Typography.body()
        subtitle.textColor = Palette.muted
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        let adButton = UIButton.appAd(
            title: "📺  Werbung schauen  →  +1 Leben",
            target: self,
            action: #selector(watchForLife)
        )

        continueTimerLabel.text = "Verfügbar für 5 Sekunden"
        continueTimerLabel.font = UIFont.systemFont(ofSize: 12)
        continueTimerLabel.textColor = Palette.muted
        continueTimerLabel.translatesAutoresizingMaskIntoConstraints = false

        let giveUp = UIButton.appGhost(title: "Aufgeben", target: self, action: #selector(giveUpTapped))

        [icon, title, continueScoreLabel, subtitle, adButton, continueTimerLabel, giveUp].forEach {
            continueCard.addSubview($0)
        }

        NSLayoutConstraint.activate([
            continueCard.centerXAnchor.constraint(equalTo: centerXAnchor),
            continueCard.centerYAnchor.constraint(equalTo: centerYAnchor),
            continueCard.widthAnchor.constraint(equalToConstant: 320),

            icon.topAnchor.constraint(equalTo: continueCard.topAnchor, constant: 28),
            icon.centerXAnchor.constraint(equalTo: continueCard.centerXAnchor),

            title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12),
            title.centerXAnchor.constraint(equalTo: continueCard.centerXAnchor),

            continueScoreLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            continueScoreLabel.centerXAnchor.constraint(equalTo: continueCard.centerXAnchor),

            subtitle.topAnchor.constraint(equalTo: continueScoreLabel.bottomAnchor, constant: 8),
            subtitle.centerXAnchor.constraint(equalTo: continueCard.centerXAnchor),

            adButton.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 20),
            adButton.leadingAnchor.constraint(equalTo: continueCard.leadingAnchor, constant: 20),
            adButton.trailingAnchor.constraint(equalTo: continueCard.trailingAnchor, constant: -20),
            adButton.heightAnchor.constraint(equalToConstant: 50),

            continueTimerLabel.topAnchor.constraint(equalTo: adButton.bottomAnchor, constant: 8),
            continueTimerLabel.centerXAnchor.constraint(equalTo: continueCard.centerXAnchor),

            giveUp.topAnchor.constraint(equalTo: continueTimerLabel.bottomAnchor, constant: 12),
            giveUp.centerXAnchor.constraint(equalTo: continueCard.centerXAnchor),
            giveUp.heightAnchor.constraint(equalToConstant: 44),
            giveUp.leadingAnchor.constraint(equalTo: continueCard.leadingAnchor, constant: 20),
            giveUp.trailingAnchor.constraint(equalTo: continueCard.trailingAnchor, constant: -20),
            giveUp.bottomAnchor.constraint(equalTo: continueCard.bottomAnchor, constant: -Layout.cardPadding)
        ])
    }

    private func setupGameOverCard() {
        gameOverCard.applyCardStyle()
        gameOverCard.layer.cornerRadius = 20
        gameOverCard.isHidden = true
        gameOverCard.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gameOverCard)

        let icon = UILabel()
        icon.text = "🏁"
        icon.font = .systemFont(ofSize: 48)
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Game Over"
        title.font = Typography.title(22)
        title.textColor = Palette.text
        title.translatesAutoresizingMaskIntoConstraints = false

        finalScoreLabel.font = UIFont.systemFont(ofSize: 56, weight: .heavy)
        finalScoreLabel.textColor = Palette.accent
        finalScoreLabel.translatesAutoresizingMaskIntoConstraints = false

        newBestBadge.backgroundColor = Palette.warn.withAlphaComponent(0.15)
        newBestBadge.layer.cornerRadius = 14
        newBestBadge.layer.borderWidth = 1
        newBestBadge.layer.borderColor = Palette.warn.cgColor
        newBestBadge.isHidden = true
        newBestBadge.translatesAutoresizingMaskIntoConstraints = false

        let badgeLabel = UILabel()
        badgeLabel.text = "✨ NEUER HIGHSCORE"
        badgeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        badgeLabel.textColor = Palette.warn
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        newBestBadge.addSubview(badgeLabel)

        let divider = UIView()
        divider.backgroundColor = Palette.border
        divider.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = UILabel()
        subtitle.text = "Doppelte Punkte? Schau jetzt eine Werbung."
        subtitle.font = UIFont.systemFont(ofSize: 13)
        subtitle.textColor = Palette.muted
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 2
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        let doubleBtn = UIButton.appAd(
            title: "📺  Werbung schauen  →  Score ×2",
            target: self,
            action: #selector(watchForDouble)
        )
        doubleButton = doubleBtn

        let playAgain = UIButton.appPrimary(title: "NOCHMAL", target: self, action: #selector(playAgainTapped))
        let menu = UIButton.appGhost(title: "Menü", target: self, action: #selector(homeTapped))
        let buttonRow = UIStackView(arrangedSubviews: [playAgain, menu])
        buttonRow.axis = .horizontal
        buttonRow.spacing = 10
        buttonRow.translatesAutoresizingMaskIntoConstraints = false

        [icon, title, finalScoreLabel, newBestBadge, divider, subtitle, doubleBtn, buttonRow].forEach {
            gameOverCard.addSubview($0)
        }

        NSLayoutConstraint.activate([
            gameOverCard.centerXAnchor.constraint(equalTo: centerXAnchor),
            gameOverCard.centerYAnchor.constraint(equalTo: centerYAnchor),
            gameOverCard.widthAnchor.constraint(equalToConstant: 320),

            icon.topAnchor.constraint(equalTo: gameOverCard.topAnchor, constant: 28),
            icon.centerXAnchor.constraint(equalTo: gameOverCard.centerXAnchor),

            title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12),
            title.centerXAnchor.constraint(equalTo: gameOverCard.centerXAnchor),

            finalScoreLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            finalScoreLabel.centerXAnchor.constraint(equalTo: gameOverCard.centerXAnchor),

            newBestBadge.topAnchor.constraint(equalTo: finalScoreLabel.bottomAnchor, constant: 6),
            newBestBadge.centerXAnchor.constraint(equalTo: gameOverCard.centerXAnchor),

            badgeLabel.topAnchor.constraint(equalTo: newBestBadge.topAnchor, constant: 5),
            badgeLabel.bottomAnchor.constraint(equalTo: newBestBadge.bottomAnchor, constant: -5),
            badgeLabel.leadingAnchor.constraint(equalTo: newBestBadge.leadingAnchor, constant: 12),
            badgeLabel.trailingAnchor.constraint(equalTo: newBestBadge.trailingAnchor, constant: -12),

            divider.topAnchor.constraint(equalTo: newBestBadge.bottomAnchor, constant: Layout.spacing),
            divider.leadingAnchor.constraint(equalTo: gameOverCard.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: gameOverCard.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 1),

            subtitle.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 14),
            subtitle.leadingAnchor.constraint(equalTo: gameOverCard.leadingAnchor, constant: 20),
            subtitle.trailingAnchor.constraint(equalTo: gameOverCard.trailingAnchor, constant: -20),

            doubleBtn.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 14),
            doubleBtn.leadingAnchor.constraint(equalTo: gameOverCard.leadingAnchor, constant: 20),
            doubleBtn.trailingAnchor.constraint(equalTo: gameOverCard.trailingAnchor, constant: -20),
            doubleBtn.heightAnchor.constraint(equalToConstant: 50),

            buttonRow.topAnchor.constraint(equalTo: doubleBtn.bottomAnchor, constant: 10),
            buttonRow.leadingAnchor.constraint(equalTo: gameOverCard.leadingAnchor, constant: 20),
            buttonRow.trailingAnchor.constraint(equalTo: gameOverCard.trailingAnchor, constant: -20),
            buttonRow.heightAnchor.constraint(equalToConstant: 50),
            buttonRow.bottomAnchor.constraint(equalTo: gameOverCard.bottomAnchor, constant: -Layout.cardPadding),

            playAgain.heightAnchor.constraint(equalToConstant: 50),
            menu.heightAnchor.constraint(equalToConstant: 50),
            menu.widthAnchor.constraint(equalToConstant: 90)
        ])
    }

    @objc private func watchForLife() {
        delegate?.overlayDidWatchAdForLife()
    }

    @objc private func giveUpTapped() {
        delegate?.overlayDidGiveUp()
    }

    @objc private func watchForDouble() {
        delegate?.overlayDidWatchAdForDouble()
    }

    @objc private func playAgainTapped() {
        delegate?.overlayDidPlayAgain()
    }

    @objc private func homeTapped() {
        delegate?.overlayDidGoHome()
    }
}

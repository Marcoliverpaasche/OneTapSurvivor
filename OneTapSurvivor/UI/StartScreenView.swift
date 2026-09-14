import UIKit

protocol StartScreenViewDelegate: AnyObject {
    func startScreenDidTapPlay()
    func startScreenDidTapDailyBonus()
    func startScreenDidTapLeaderboard()
}

final class StartScreenView: UIView {

    weak var delegate: StartScreenViewDelegate?

    private let bestValue = UILabel()
    private let coinsValue = UILabel()
    private let gamesValue = UILabel()
    private var dailyButton: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func updateStats(best: Int, coins: Int, games: Int, dailyAvailable: Bool) {
        bestValue.text = "\(best)"
        coinsValue.text = "🪙 \(coins)"
        gamesValue.text = "\(games)"

        var config = dailyButton?.configuration
        config?.title = dailyAvailable ? "🎁  Bonus verfügbar" : "🎁  Täglicher Bonus"
        dailyButton?.configuration = config
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = Palette.bg

        let iconBg = UIView()
        iconBg.backgroundColor = Palette.accent.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 20
        iconBg.layer.borderWidth = 1.5
        iconBg.layer.borderColor = Palette.accent.cgColor
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconBg)

        let iconLabel = UILabel()
        iconLabel.text = "⚡"
        iconLabel.font = .systemFont(ofSize: 38)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconLabel)

        let titleLabel = UILabel()
        titleLabel.text = Constants.appDisplayName
        titleLabel.font = Typography.title(26)
        titleLabel.textColor = Palette.text
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        let subLabel = UILabel()
        subLabel.text = "EIN FINGER · ENDLOS · IMMER SCHWERER"
        subLabel.font = Typography.label()
        subLabel.textColor = Palette.muted
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subLabel)

        let statsRow = UIStackView()
        statsRow.axis = .horizontal
        statsRow.spacing = 12
        statsRow.distribution = .fillEqually
        statsRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statsRow)

        let bestBox = makeStatBox(title: "HIGHSCORE", valueLabel: bestValue)
        let coinsBox = makeStatBox(title: "COINS", valueLabel: coinsValue)
        let gamesBox = makeStatBox(title: "SPIELE", valueLabel: gamesValue)
        statsRow.addArrangedSubview(bestBox)
        statsRow.addArrangedSubview(coinsBox)
        statsRow.addArrangedSubview(gamesBox)

        let playButton = UIButton.appPrimary(title: "SPIELEN", target: self, action: #selector(playTapped))
        addSubview(playButton)

        let daily = UIButton.appTag(title: "🎁  Täglicher Bonus", color: Palette.warn, target: self, action: #selector(dailyTapped))
        dailyButton = daily
        let leaderboard = UIButton.appTag(title: "🏆  Rangliste", color: Palette.accent, target: self, action: #selector(leaderboardTapped))

        let tagRow = UIStackView(arrangedSubviews: [daily, leaderboard])
        tagRow.axis = .horizontal
        tagRow.spacing = 12
        tagRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tagRow)

        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 72),
            iconBg.heightAnchor.constraint(equalToConstant: 72),
            iconBg.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconBg.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -Layout.spacing),

            iconLabel.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -80),

            subLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            statsRow.centerXAnchor.constraint(equalTo: centerXAnchor),
            statsRow.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 32),
            statsRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.cardPadding),
            statsRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.cardPadding),

            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.topAnchor.constraint(equalTo: statsRow.bottomAnchor, constant: 32),
            playButton.widthAnchor.constraint(equalToConstant: 200),
            playButton.heightAnchor.constraint(equalToConstant: 54),

            tagRow.centerXAnchor.constraint(equalTo: centerXAnchor),
            tagRow.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20)
        ])
    }

    private func makeStatBox(title: String, valueLabel: UILabel) -> UIView {
        let box = UIView()
        box.applyCardStyle()

        valueLabel.text = "0"
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = Palette.accent
        valueLabel.textAlignment = .center

        let caption = UILabel()
        caption.text = title
        caption.font = Typography.label()
        caption.textColor = Palette.muted
        caption.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, caption])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            box.heightAnchor.constraint(equalToConstant: 72)
        ])
        return box
    }

    @objc private func playTapped() {
        delegate?.startScreenDidTapPlay()
    }

    @objc private func dailyTapped() {
        delegate?.startScreenDidTapDailyBonus()
    }

    @objc private func leaderboardTapped() {
        delegate?.startScreenDidTapLeaderboard()
    }
}

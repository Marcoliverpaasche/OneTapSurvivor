import UIKit

protocol DailyBonusViewDelegate: AnyObject {
    func dailyBonusDidRequestAd()
    func dailyBonusDidDismiss()
}

final class DailyBonusView: UIView {

    weak var delegate: DailyBonusViewDelegate?

    private let card = UIView()
    private let dayLabel = UILabel()
    private let rewardLabel = UILabel()
    private let claimButton = UIButton.appAd(
        title: "📺  Werbung schauen  →  Coins",
        target: nil,
        action: #selector(DailyBonusView.claimTapped)
    )
    private let daysStack = UIStackView()
    private var dayDots: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        claimButton.addTarget(self, action: #selector(claimTapped), for: .touchUpInside)
        setup()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func configure(streak: Int, claimed: Bool, reward: Int) {
        isHidden = false
        isUserInteractionEnabled = true
        let dayIndex = streak % DailyBonus.rewards.count
        dayLabel.text = "Tag \(dayIndex + 1) von 7"
        rewardLabel.text = "🪙 \(reward) Coins"

        for (index, dot) in dayDots.enumerated() {
            let reached = index <= dayIndex && streak > 0 || (streak == 0 && index == 0)
            let filled = claimed ? index < ((streak - 1) % 7) + 1 : (index < dayIndex)
            let isCurrent = index == dayIndex
            dot.backgroundColor = isCurrent ? Palette.warn : (filled || reached && index < dayIndex ? Palette.green : Palette.border)
            dot.layer.borderColor = isCurrent ? Palette.warn.cgColor : Palette.border.cgColor
        }

        claimButton.isEnabled = claimed == false
        claimButton.alpha = claimed ? 0.45 : 1
        var config = claimButton.configuration
        config?.title = claimed ? "Heute schon abgeholt" : "📺  Werbung schauen  →  +\(reward)"
        claimButton.configuration = config
    }

    func hideBonus() {
        isHidden = true
        isUserInteractionEnabled = false
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.75)
        isHidden = true
        isUserInteractionEnabled = false

        card.applyCardStyle()
        card.layer.cornerRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)

        let icon = UILabel()
        icon.text = "🎁"
        icon.font = .systemFont(ofSize: 48)
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Täglicher Bonus"
        title.font = Typography.title(22)
        title.textColor = Palette.text
        title.translatesAutoresizingMaskIntoConstraints = false

        dayLabel.font = Typography.body()
        dayLabel.textColor = Palette.muted
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        rewardLabel.font = UIFont.systemFont(ofSize: 42, weight: .heavy)
        rewardLabel.textColor = Palette.warn
        rewardLabel.translatesAutoresizingMaskIntoConstraints = false

        daysStack.axis = .horizontal
        daysStack.spacing = 8
        daysStack.distribution = .equalSpacing
        daysStack.translatesAutoresizingMaskIntoConstraints = false

        dayDots = DailyBonus.rewards.enumerated().map { index, _ in
            let dot = UIView()
            dot.backgroundColor = Palette.border
            dot.layer.cornerRadius = 14
            dot.layer.borderWidth = 1
            dot.layer.borderColor = Palette.border.cgColor
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 28),
                dot.heightAnchor.constraint(equalToConstant: 28)
            ])

            let number = UILabel()
            number.text = "\(index + 1)"
            number.font = UIFont.systemFont(ofSize: 11, weight: .bold)
            number.textColor = Palette.text
            number.textAlignment = .center
            number.translatesAutoresizingMaskIntoConstraints = false
            dot.addSubview(number)
            NSLayoutConstraint.activate([
                number.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
                number.centerYAnchor.constraint(equalTo: dot.centerYAnchor)
            ])
            daysStack.addArrangedSubview(dot)
            return dot
        }

        let closeButton = UIButton.appGhost(title: "Schließen", target: self, action: #selector(closeTapped))

        [icon, title, dayLabel, rewardLabel, daysStack, claimButton, closeButton].forEach {
            card.addSubview($0)
        }

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 320),

            icon.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            icon.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12),
            title.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            dayLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            dayLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            rewardLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 8),
            rewardLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            daysStack.topAnchor.constraint(equalTo: rewardLabel.bottomAnchor, constant: Layout.spacing),
            daysStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            daysStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            daysStack.heightAnchor.constraint(equalToConstant: 28),

            claimButton.topAnchor.constraint(equalTo: daysStack.bottomAnchor, constant: 20),
            claimButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            claimButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            claimButton.heightAnchor.constraint(equalToConstant: 50),

            closeButton.topAnchor.constraint(equalTo: claimButton.bottomAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Layout.cardPadding)
        ])
    }

    @objc private func claimTapped() {
        delegate?.dailyBonusDidRequestAd()
    }

    @objc private func closeTapped() {
        delegate?.dailyBonusDidDismiss()
    }
}

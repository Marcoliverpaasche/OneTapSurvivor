import UIKit
import SpriteKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if sanitized.hasPrefix("#") {
            sanitized.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: alpha
        )
    }
}

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(other.x - x, other.y - y)
    }

    func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: x + dx, y: y + dy)
    }
}

extension UIView {
    func pinEdges(to view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }

    func applyCardStyle() {
        backgroundColor = Palette.surface
        layer.cornerRadius = Layout.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = Palette.border.cgColor
    }
}

extension UIButton {
    static func appPrimary(title: String, target: Any?, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = .black
        config.baseBackgroundColor = Palette.accent
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = Typography.button()
            return outgoing
        }

        let button = UIButton(configuration: config)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    static func appAd(title: String, target: Any?, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = Palette.warn
        config.baseBackgroundColor = Palette.warn.withAlphaComponent(0.1)
        config.background.strokeColor = Palette.warn
        config.background.strokeWidth = 1.5
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            return outgoing
        }

        let button = UIButton(configuration: config)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    static func appGhost(title: String, target: Any?, action: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = Palette.muted
        config.background.strokeColor = Palette.border
        config.background.strokeWidth = 1
        config.background.cornerRadius = Layout.cornerRadius
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            return outgoing
        }

        let button = UIButton(configuration: config)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    static func appTag(title: String, color: UIColor, target: Any?, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = color
        config.baseBackgroundColor = color.withAlphaComponent(0.1)
        config.background.strokeColor = color.withAlphaComponent(0.4)
        config.background.strokeWidth = 1
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            return outgoing
        }

        let button = UIButton(configuration: config)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}

extension SKLabelNode {
    static func appLabel(
        text: String,
        size: CGFloat,
        weight: UIFont.Weight,
        color: UIColor
    ) -> SKLabelNode {
        let node = SKLabelNode(fontNamed: UIFont.systemFont(ofSize: size, weight: weight).fontName)
        node.text = text
        node.fontSize = size
        node.fontColor = color
        return node
    }
}


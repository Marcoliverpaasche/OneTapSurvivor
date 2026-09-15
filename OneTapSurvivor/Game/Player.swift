import SpriteKit

/// Spieler: runder Orb, Glow, Trail. Jeder Tap gibt Höhe, danach fällt der Ball.
final class Player {

    let root = SKNode()
    private let glowNode: SKSpriteNode
    private let trailLayer = SKNode()
    private var trailNodes: [SKSpriteNode] = []
    private let trailCount = 6
    private var hoverY: CGFloat = 0
    private var hasJumped = false
    private var velocityY: CGFloat = 0

    var hasStarted: Bool { hasJumped }

    var position: CGPoint {
        get { root.position }
        set { root.position = newValue }
    }

    var physicsBody: SKPhysicsBody? {
        root.physicsBody
    }

    init(startPosition: CGPoint) {
        let diameter = Gameplay.playerRadius * 2
        hoverY = startPosition.y

        glowNode = SKSpriteNode.circle(
            diameter: diameter * 1.7,
            color: Palette.accent.withAlphaComponent(0.35)
        )
        glowNode.zPosition = 0
        glowNode.blendMode = .add

        let ring = SKSpriteNode.circle(diameter: diameter + 10, color: .white)
        ring.zPosition = 1

        let body = SKSpriteNode.circle(diameter: diameter, color: Palette.accent)
        body.name = "player"
        body.zPosition = 2

        let shine = SKSpriteNode.circle(diameter: 12, color: .white)
        shine.position = CGPoint(x: -7, y: 8)
        shine.zPosition = 3
        body.addChild(shine)

        let physics = SKPhysicsBody(circleOfRadius: Gameplay.playerHitboxRadius)
        physics.categoryBitMask = PhysicsCategory.player
        physics.contactTestBitMask = PhysicsCategory.obstacle
        physics.collisionBitMask = PhysicsCategory.none
        physics.allowsRotation = false
        physics.linearDamping = 0
        physics.friction = 0
        physics.restitution = 0
        physics.affectedByGravity = false
        physics.isDynamic = true
        physics.usesPreciseCollisionDetection = true
        root.physicsBody = physics
        root.zPosition = 50
        root.position = startPosition

        root.addChild(glowNode)
        root.addChild(ring)
        root.addChild(body)

        trailLayer.zPosition = 40
        for index in 0..<trailCount {
            let factor = 1 - CGFloat(index) / CGFloat(trailCount)
            let trail = SKSpriteNode.circle(
                diameter: diameter * (0.35 + factor * 0.4),
                color: Palette.accent.withAlphaComponent(0.18 + factor * 0.4)
            )
            trail.zPosition = CGFloat(trailCount - index)
            trail.position = startPosition
            trailNodes.append(trail)
            trailLayer.addChild(trail)
        }
    }

    func add(to scene: SKScene) {
        if trailLayer.parent == nil {
            scene.addChild(trailLayer)
        }
        if root.parent == nil {
            scene.addChild(root)
        }
    }

    func reset(to startPosition: CGPoint) {
        hoverY = startPosition.y
        hasJumped = false
        velocityY = 0
        root.alpha = 1
        root.position = startPosition
        physicsBody?.velocity = .zero
        trailNodes.forEach { $0.position = startPosition }
    }

    func jump() {
        hasJumped = true
        velocityY = Gameplay.jumpForce
        physicsBody?.velocity = .zero
        Feedback.tap()
    }

    func flashHit() {
        root.removeAction(forKey: "hitFlash")
        root.run(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: 0.07),
                SKAction.fadeAlpha(to: 1, duration: 0.07),
                SKAction.fadeAlpha(to: 0.2, duration: 0.07),
                SKAction.fadeAlpha(to: 1, duration: 0.07)
            ]),
            withKey: "hitFlash"
        )
    }

    func isAtVerticalEdge(in size: CGSize) -> Bool {
        guard hasJumped else { return false }
        let minY = max(Gameplay.playerRadius + 24, size.height * 0.12)
        let maxY = min(size.height - Gameplay.playerRadius - 24, size.height * 0.88)
        let y = root.position.y
        return y <= minY + 0.5 || y >= maxY - 0.5
    }

    func step(dt: CGFloat, in size: CGSize, pulseTime: TimeInterval) {
        if hasJumped == false {
            root.position = CGPoint(
                x: Gameplay.playerX,
                y: hoverY + sin(pulseTime * 3.2) * 16
            )
        } else {
            velocityY += Gameplay.gravity * dt
            var y = root.position.y + velocityY * dt

            let minY = max(Gameplay.playerRadius + 24, size.height * 0.12)
            let maxY = min(size.height - Gameplay.playerRadius - 24, size.height * 0.88)

            if y < minY {
                y = minY
                if velocityY < 0 { velocityY = 0 }
            } else if y > maxY {
                y = maxY
                if velocityY > 0 { velocityY = 0 }
            }

            root.position = CGPoint(x: Gameplay.playerX, y: y)
        }

        physicsBody?.velocity = .zero

        for index in stride(from: trailNodes.count - 1, through: 1, by: -1) {
            trailNodes[index].position = trailNodes[index - 1].position
        }
        trailNodes.first?.position = root.position

        let pulse = 1.0 + sin(pulseTime * 4) * 0.08
        glowNode.setScale(pulse)
    }
}

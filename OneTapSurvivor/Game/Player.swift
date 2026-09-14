import SpriteKit

/// Spieler: farbige Sprites wie die Säulen. Sprung ist manuell — jeder Tap gibt Höhe, danach fällt der Ball.
final class Player {

    let root = SKNode()
    private let glowNode: SKSpriteNode
    private let trailLayer = SKNode()
    private var trailNodes: [SKSpriteNode] = []
    private let trailCount = 6
    private var hoverY: CGFloat = 0
    private var hasJumped = false
    private var velocityY: CGFloat = 0

    var position: CGPoint {
        get { root.position }
        set { root.position = newValue }
    }

    var physicsBody: SKPhysicsBody? {
        root.physicsBody
    }

    init(startPosition: CGPoint) {
        let side = Gameplay.playerRadius * 2
        hoverY = startPosition.y

        glowNode = SKSpriteNode(
            color: Palette.accent.withAlphaComponent(0.35),
            size: CGSize(width: side * 1.55, height: side * 1.55)
        )
        glowNode.zPosition = 0

        let ring = SKSpriteNode(
            color: .white,
            size: CGSize(width: side + 10, height: side + 10)
        )
        ring.zPosition = 1

        let body = SKSpriteNode(
            color: Palette.accent,
            size: CGSize(width: side, height: side)
        )
        body.name = "player"
        body.zPosition = 2

        let shine = SKSpriteNode(
            color: .white,
            size: CGSize(width: 12, height: 12)
        )
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
            let trail = SKSpriteNode(
                color: Palette.accent.withAlphaComponent(0.18 + factor * 0.4),
                size: CGSize(width: side * (0.35 + factor * 0.4), height: side * (0.35 + factor * 0.4))
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
        root.position = startPosition
        physicsBody?.velocity = .zero
        trailNodes.forEach { $0.position = startPosition }
    }

    /// Jeder Tap setzt die Aufwärtsgeschwindigkeit neu — danach fällt der Ball von selbst.
    func jump() {
        hasJumped = true
        velocityY = Gameplay.jumpForce
        physicsBody?.velocity = .zero
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

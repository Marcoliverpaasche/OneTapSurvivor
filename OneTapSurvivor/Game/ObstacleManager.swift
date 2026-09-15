import SpriteKit

/// Spawnt und bewegt Wände plus optionale roaming Hindernisse.
final class ObstacleManager {

    let layer = SKNode()
    private weak var scene: SKScene?

    func attach(to scene: SKScene) {
        self.scene = scene
        layer.zPosition = 8
        if layer.parent == nil {
            scene.addChild(layer)
        }
    }

    func reset() {
        layer.removeAllChildren()
    }

    /// Entfernt Hindernisse direkt vor dem Spieler nach einem Extra-Leben.
    func clearNearby(playerX: CGFloat) {
        layer.children.forEach { node in
            if node.position.x < playerX + 250 {
                node.removeFromParent()
            }
        }
    }

    /// Bewegt alle Hindernisse, zählt Punkte und räumt Offscreen-Nodes auf.
    @discardableResult
    func update(gameSpeed: CGFloat, playerX: CGFloat, dt: CGFloat) -> Int {
        var scored = 0
        var toRemove: [SKNode] = []
        let sceneHeight = scene?.size.height ?? 0

        for node in layer.children {
            node.position.x -= gameSpeed * dt

            if let name = node.name, name.hasPrefix("wallTop_"),
               node.position.x + wallWidth(of: node) < playerX,
               node.userData?["scored"] == nil {
                let data = NSMutableDictionary()
                data["scored"] = true
                node.userData = data
                scored += 1
            }

            if let body = node.physicsBody, node.name?.hasPrefix("roamer_") == true {
                if node.position.y < 40 || node.position.y > sceneHeight - 40 {
                    body.velocity.dy *= -1
                }
            }

            if node.position.x < -200 {
                toRemove.append(node)
            }
        }

        toRemove.forEach { $0.removeFromParent() }
        return scored
    }

    func spawn(score: Int, frameCount: Int) {
        guard let scene else { return }

        let gapRatio = Gameplay.gapRatio(for: score)
        let gapHeight = scene.size.height * gapRatio
        let minGapY = scene.size.height * 0.15
        let maxGapY = scene.size.height * 0.7 - gapHeight
        let span = max(maxGapY - minGapY, 1)
        let gapY = minGapY + CGFloat.random(in: 0...1) * span

        let wallW: CGFloat = 36
        let startX = scene.size.width + wallW

        let topHeight = scene.size.height - (gapY + gapHeight)
        let top = makeWall(width: wallW, height: topHeight, at: CGPoint(x: startX, y: gapY + gapHeight))
        top.name = "wallTop_\(frameCount)"
        layer.addChild(top)

        let bottom = makeWall(width: wallW, height: gapY, at: CGPoint(x: startX, y: 0))
        bottom.name = "wallBot_\(frameCount)"
        layer.addChild(bottom)

        if score > 5 && Bool.random() {
            spawnRoamer(atX: startX + wallW / 2, gapY: gapY, gapHeight: gapHeight, frameCount: frameCount)
        }
    }

    // MARK: - Private

    private func makeWall(width: CGFloat, height: CGFloat, at pos: CGPoint) -> SKSpriteNode {
        let wall = SKSpriteNode(
            color: Palette.danger.withAlphaComponent(0.9),
            size: CGSize(width: width, height: height)
        )
        wall.position = CGPoint(x: pos.x + width / 2, y: pos.y + height / 2)
        wall.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let edge = SKSpriteNode(
            color: Palette.danger,
            size: CGSize(width: 5, height: height)
        )
        edge.position = CGPoint(x: -width / 2 + 2.5, y: 0)
        wall.addChild(edge)

        let body = SKPhysicsBody(rectangleOf: wall.size)
        body.categoryBitMask = PhysicsCategory.obstacle
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        body.affectedByGravity = false
        body.isDynamic = false
        wall.physicsBody = body
        return wall
    }

    private func spawnRoamer(atX x: CGFloat, gapY: CGFloat, gapHeight: CGFloat, frameCount: Int) {
        let emojis = ["🔺", "💣", "⚡", "🔥", "☠️", "💀"]
        let emoji = SKLabelNode(text: emojis.randomElement() ?? "🔥")
        emoji.fontSize = 30
        emoji.verticalAlignmentMode = .center
        emoji.horizontalAlignmentMode = .center
        emoji.position = CGPoint(x: x, y: gapY + gapHeight / 2)
        emoji.name = "roamer_\(frameCount)"

        let roamBody = SKPhysicsBody(circleOfRadius: 18)
        roamBody.categoryBitMask = PhysicsCategory.obstacle
        roamBody.contactTestBitMask = PhysicsCategory.player
        roamBody.collisionBitMask = PhysicsCategory.none
        roamBody.affectedByGravity = false
        roamBody.velocity = CGVector(
            dx: 0,
            dy: (Bool.random() ? 1 : -1) * CGFloat.random(in: 60...140)
        )
        emoji.physicsBody = roamBody
        layer.addChild(emoji)
    }

    private func wallWidth(of node: SKNode) -> CGFloat {
        (node as? SKSpriteNode)?.size.width ?? 0
    }
}

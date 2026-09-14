import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameDidDie(score: Int, isFirstDeath: Bool)
}

final class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var gameDelegate: GameSceneDelegate?

    private(set) var score = 0
    private(set) var lives = Gameplay.startingLives

    private var isRunning = false
    private var gameSpeed: CGFloat = Gameplay.startSpeed
    private var frameCount = 0
    private var lastObstacleFrame = 0
    private var combo = 0
    private var comboTimer: TimeInterval = 0
    private var hasDied = false
    private var damageCooldown: TimeInterval = 0
    private var totalTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0

    private var player: Player?
    private let obstacles = ObstacleManager()
    private var hudScore: SKLabelNode?
    private var livesNodes: [SKSpriteNode] = []
    private var bgGrid: SKNode?

    override func didMove(to view: SKView) {
        isUserInteractionEnabled = true
        backgroundColor = Palette.bg
        physicsWorld.gravity = CGVector(dx: 0, dy: Gameplay.gravity)
        physicsWorld.contactDelegate = self

        setupBackground()
        obstacles.attach(to: self)
        setupPlayer()
        setupHUD()
        startGame()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard oldSize != size, size.height > 1 else { return }
        hudScore?.position = CGPoint(x: 24, y: size.height - 20)
        if let caption = childNode(withName: "scoreCaption") as? SKLabelNode {
            caption.position = CGPoint(x: 24, y: size.height - 68)
        }
        for (index, dot) in livesNodes.enumerated() {
            dot.position = CGPoint(
                x: size.width - 30 - CGFloat(2 - index) * 22,
                y: size.height - 36
            )
        }
        if isRunning {
            player?.step(dt: 0, in: size, pulseTime: totalTime)
        }
    }

    func startGame() {
        score = 0
        lives = Gameplay.startingLives
        gameSpeed = Gameplay.startSpeed
        frameCount = 0
        lastObstacleFrame = 0
        combo = 0
        hasDied = false
        damageCooldown = 0
        totalTime = 0
        lastUpdateTime = 0
        isRunning = true
        isPaused = false

        let start = CGPoint(x: Gameplay.playerX, y: size.height / 2)
        player?.reset(to: start)
        obstacles.reset()
        hudScore?.text = "0"
        updateLivesUI()
    }

    func continueAfterAd() {
        lives = Gameplay.startingLives
        damageCooldown = 1.0
        updateLivesUI()
        isRunning = true
        isPaused = false
        obstacles.clearNearby(playerX: Gameplay.playerX)
    }

    override func update(_ currentTime: TimeInterval) {
        guard isRunning else { return }

        frameCount += 1
        let dt: CGFloat
        if lastUpdateTime == 0 {
            dt = 1.0 / 60.0
        } else {
            dt = CGFloat(min(currentTime - lastUpdateTime, 1.0 / 30.0))
        }
        lastUpdateTime = currentTime
        totalTime += dt

        if damageCooldown > 0 { damageCooldown -= 1.0 / 60.0 }
        if comboTimer > 0 {
            comboTimer -= 1.0 / 60.0
        } else {
            combo = 0
        }

        if let bgGrid {
            bgGrid.position.x -= gameSpeed / 60.0 * 0.3
            if bgGrid.position.x < -60 {
                bgGrid.position.x = 0
            }
        }

        gameSpeed = Gameplay.speed(for: score)

        let gained = obstacles.update(gameSpeed: gameSpeed, playerX: Gameplay.playerX)
        if gained > 0 {
            for _ in 0..<gained {
                addScore()
            }
        }

        if frameCount - lastObstacleFrame > Gameplay.spawnInterval(for: score) {
            obstacles.spawn(score: score, frameCount: frameCount)
            lastObstacleFrame = frameCount
        }

        player?.step(dt: dt, in: size, pulseTime: totalTime)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard isRunning, damageCooldown <= 0 else { return }
        let masks = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if masks == PhysicsCategory.player | PhysicsCategory.obstacle {
            handleDamage()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTap()
    }

    func handleTap() {
        guard isRunning else { return }
        player?.jump()
        if let player {
            spawnParticles(at: player.position, color: Palette.accent)
        }
    }

    // MARK: - Setup

    private func setupBackground() {
        let grid = SKNode()
        bgGrid = grid
        addChild(grid)

        let color = Palette.border.withAlphaComponent(0.15)
        let spacing: CGFloat = 60

        for x in stride(from: CGFloat(0), through: size.width, by: spacing) {
            let line = SKShapeNode(rect: CGRect(x: x, y: 0, width: 1, height: size.height))
            line.fillColor = color
            line.strokeColor = .clear
            grid.addChild(line)
        }
        for y in stride(from: CGFloat(0), through: size.height, by: spacing) {
            let line = SKShapeNode(rect: CGRect(x: 0, y: y, width: size.width, height: 1))
            line.fillColor = color
            line.strokeColor = .clear
            grid.addChild(line)
        }
    }

    private func setupPlayer() {
        let start = CGPoint(x: Gameplay.playerX, y: size.height / 2)
        let player = Player(startPosition: start)
        player.add(to: self)
        self.player = player
    }

    private func setupHUD() {
        let scoreNode = SKLabelNode.appLabel(text: "0", size: 42, weight: .heavy, color: Palette.text)
        scoreNode.horizontalAlignmentMode = .left
        scoreNode.verticalAlignmentMode = .top
        scoreNode.position = CGPoint(x: 24, y: size.height - 20)
        scoreNode.zPosition = 80
        addChild(scoreNode)
        hudScore = scoreNode

        let scoreCaption = SKLabelNode.appLabel(text: "PUNKTE", size: 11, weight: .medium, color: Palette.muted)
        scoreCaption.name = "scoreCaption"
        scoreCaption.horizontalAlignmentMode = .left
        scoreCaption.verticalAlignmentMode = .top
        scoreCaption.position = CGPoint(x: 24, y: size.height - 68)
        scoreCaption.zPosition = 80
        addChild(scoreCaption)

        livesNodes.removeAll()
        for index in 0..<Gameplay.startingLives {
            let dot = SKSpriteNode(color: Palette.danger, size: CGSize(width: 14, height: 14))
            dot.position = CGPoint(
                x: size.width - 30 - CGFloat(2 - index) * 22,
                y: size.height - 36
            )
            dot.zPosition = 80
            addChild(dot)
            livesNodes.append(dot)
        }
    }

    private func addScore() {
        score += 1
        hudScore?.text = "\(score)"
        combo += 1
        comboTimer = 2.0
        if combo >= 5 {
            showComboLabel(combo)
        }
        hudScore?.run(SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.08)
        ]))
    }

    private func showComboLabel(_ count: Int) {
        let label = SKLabelNode.appLabel(
            text: "\(count)× COMBO! 🔥",
            size: 32,
            weight: .heavy,
            color: Palette.warn
        )
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 20
        label.setScale(0)
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 0.6),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    private func handleDamage() {
        guard damageCooldown <= 0 else { return }
        damageCooldown = Gameplay.damageCooldown
        lives -= 1
        updateLivesUI()
        shakeCamera()
        if let player {
            spawnParticles(at: player.position, color: Palette.danger)
        }

        if lives <= 0 {
            isRunning = false
            let isFirst = hasDied == false
            hasDied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                guard let self else { return }
                self.isPaused = true
                self.gameDelegate?.gameDidDie(score: self.score, isFirstDeath: isFirst)
            }
        }
    }

    private func shakeCamera() {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -6, y: 3, duration: 0.05),
            SKAction.moveBy(x: 6, y: -3, duration: 0.05),
            SKAction.moveBy(x: -4, y: 2, duration: 0.05),
            SKAction.moveBy(x: 4, y: -2, duration: 0.05),
            SKAction.moveBy(x: 0, y: 0, duration: 0)
        ])
        run(shake)
    }

    private func spawnParticles(at position: CGPoint, color: UIColor) {
        for _ in 0..<10 {
            let radius = CGFloat.random(in: 2...5)
            let particle = SKSpriteNode(
                color: color,
                size: CGSize(width: radius * 2, height: radius * 2)
            )
            particle.position = position
            particle.zPosition = 15
            addChild(particle)

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let dist = CGFloat.random(in: 40...80)
            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: cos(angle) * dist, y: sin(angle) * dist, duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.scale(to: 0, duration: 0.5)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func updateLivesUI() {
        for (index, dot) in livesNodes.enumerated() {
            dot.color = index < lives ? Palette.danger : Palette.border
        }
    }
}

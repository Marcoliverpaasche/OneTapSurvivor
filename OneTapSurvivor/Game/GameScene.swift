import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameDidDie(score: Int, isFirstDeath: Bool)
}

final class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var gameDelegate: GameSceneDelegate?

    private(set) var score = 0
    private(set) var lives = Gameplay.startingLives

    private var isRunning = false
    private var isWaitingForResumeTap = false
    private var gameSpeed: CGFloat = Gameplay.startSpeed
    private var frameCount = 0
    private var timeSinceSpawn: TimeInterval = 0
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
    private var hintLabel: SKLabelNode?
    private var pauseLabel: SKLabelNode?

    override func didMove(to view: SKView) {
        isUserInteractionEnabled = true
        backgroundColor = Palette.bg
        physicsWorld.gravity = CGVector(dx: 0, dy: Gameplay.gravity)
        physicsWorld.contactDelegate = self

        setupBackground()
        obstacles.attach(to: self)
        setupPlayer()
        setupHUD()
        layoutHUD()
        startGame()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard oldSize != size, size.height > 1 else { return }
        layoutHUD()
        hintLabel?.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        pauseLabel?.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        if isRunning {
            player?.step(dt: 0, in: size, pulseTime: totalTime)
        }
    }

    func startGame() {
        score = 0
        lives = Gameplay.startingLives
        gameSpeed = Gameplay.startSpeed
        frameCount = 0
        timeSinceSpawn = 0
        combo = 0
        hasDied = false
        damageCooldown = 0
        totalTime = 0
        lastUpdateTime = 0
        isRunning = true
        isPaused = false
        isWaitingForResumeTap = false

        let start = CGPoint(x: Gameplay.playerX, y: size.height / 2)
        player?.reset(to: start)
        obstacles.reset()
        hudScore?.text = "0"
        updateLivesUI()
        showHint(true)
        showPauseHint(false)
    }

    func continueAfterAd() {
        lives = 1
        damageCooldown = 1.0
        updateLivesUI()
        isRunning = true
        isPaused = false
        isWaitingForResumeTap = false
        obstacles.clearNearby(playerX: Gameplay.playerX)
        showPauseHint(false)
    }

    func pauseForBackground() {
        guard isRunning, hasDied == false else { return }
        isPaused = true
        isWaitingForResumeTap = true
        lastUpdateTime = 0
        showPauseHint(true)
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

        if damageCooldown > 0 { damageCooldown -= dt }
        if comboTimer > 0 {
            comboTimer -= dt
        } else {
            combo = 0
        }

        player?.step(dt: dt, in: size, pulseTime: totalTime)

        guard player?.hasStarted == true else { return }

        if let bgGrid {
            bgGrid.position.x -= gameSpeed * dt * 0.3
            if bgGrid.position.x < -60 {
                bgGrid.position.x = 0
            }
        }

        gameSpeed = Gameplay.speed(for: score)

        let gained = obstacles.update(gameSpeed: gameSpeed, playerX: Gameplay.playerX, dt: dt)
        if gained > 0 {
            for _ in 0..<gained {
                addScore()
            }
        }

        timeSinceSpawn += dt
        if timeSinceSpawn > Gameplay.spawnInterval(for: score) {
            obstacles.spawn(score: score, frameCount: frameCount)
            timeSinceSpawn = 0
        }

        if player?.isAtVerticalEdge(in: size) == true, damageCooldown <= 0 {
            handleDamage()
        }
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
        if isWaitingForResumeTap {
            isWaitingForResumeTap = false
            isPaused = false
            lastUpdateTime = 0
            showPauseHint(false)
        }

        guard isRunning else { return }
        player?.jump()
        showHint(false)
        if let player {
            spawnParticles(at: player.position, color: Palette.accent)
        }
    }

    // MARK: - Setup

    private func setupBackground() {
        let grid = SKNode()
        bgGrid = grid
        addChild(grid)

        let color = Palette.border.withAlphaComponent(0.35)
        let spacing: CGFloat = 60

        for x in stride(from: CGFloat(0), through: size.width + spacing, by: spacing) {
            let line = SKSpriteNode(color: color, size: CGSize(width: 1, height: size.height))
            line.anchorPoint = CGPoint(x: 0, y: 0)
            line.position = CGPoint(x: x, y: 0)
            grid.addChild(line)
        }
        for y in stride(from: CGFloat(0), through: size.height, by: spacing) {
            let line = SKSpriteNode(color: color, size: CGSize(width: size.width + spacing, height: 1))
            line.anchorPoint = CGPoint(x: 0, y: 0)
            line.position = CGPoint(x: 0, y: y)
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
        scoreNode.zPosition = 80
        addChild(scoreNode)
        hudScore = scoreNode

        let scoreCaption = SKLabelNode.appLabel(text: "PUNKTE", size: 11, weight: .medium, color: Palette.muted)
        scoreCaption.name = "scoreCaption"
        scoreCaption.horizontalAlignmentMode = .left
        scoreCaption.verticalAlignmentMode = .top
        scoreCaption.zPosition = 80
        addChild(scoreCaption)

        livesNodes.removeAll()
        for _ in 0..<Gameplay.startingLives {
            let dot = SKSpriteNode.circle(diameter: 14, color: Palette.danger)
            dot.zPosition = 80
            addChild(dot)
            livesNodes.append(dot)
        }

        let hint = SKLabelNode.appLabel(
            text: "TIPPEN ZUM STARTEN",
            size: 16,
            weight: .heavy,
            color: Palette.accent
        )
        hint.horizontalAlignmentMode = .center
        hint.verticalAlignmentMode = .center
        hint.zPosition = 90
        addChild(hint)
        hintLabel = hint

        let pause = SKLabelNode.appLabel(
            text: "PAUSE  ·  TIPPEN",
            size: 18,
            weight: .heavy,
            color: Palette.text
        )
        pause.horizontalAlignmentMode = .center
        pause.verticalAlignmentMode = .center
        pause.zPosition = 90
        pause.isHidden = true
        addChild(pause)
        pauseLabel = pause

        layoutHUD()
    }

    private func layoutHUD() {
        let insetTop = view?.safeAreaInsets.top ?? 0
        let insetRight = view?.safeAreaInsets.right ?? 0
        let top = size.height - max(insetTop, 20) - 8

        hudScore?.position = CGPoint(x: 24, y: top)
        if let caption = childNode(withName: "scoreCaption") as? SKLabelNode {
            caption.position = CGPoint(x: 24, y: top - 48)
        }
        for (index, dot) in livesNodes.enumerated() {
            dot.position = CGPoint(
                x: size.width - 30 - insetRight - CGFloat(2 - index) * 22,
                y: top - 16
            )
        }
        hintLabel?.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        pauseLabel?.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
    }

    private func showHint(_ visible: Bool) {
        hintLabel?.removeAllActions()
        hintLabel?.isHidden = visible == false
        hintLabel?.alpha = visible ? 1 : 0
        guard visible, let hintLabel else { return }
        hintLabel.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.35, duration: 0.7),
                    SKAction.fadeAlpha(to: 1, duration: 0.7)
                ])
            )
        )
    }

    private func showPauseHint(_ visible: Bool) {
        pauseLabel?.isHidden = visible == false
        pauseLabel?.alpha = visible ? 1 : 0
    }

    private func addScore() {
        score += 1
        hudScore?.text = "\(score)"
        combo += 1
        comboTimer = 2.0
        Feedback.score()
        if combo >= 5 {
            showComboLabel(combo)
            Feedback.combo()
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
        player?.flashHit()
        Feedback.hit()
        if let player {
            spawnParticles(at: player.position, color: Palette.danger)
        }

        if lives <= 0 {
            isRunning = false
            let isFirst = hasDied == false
            hasDied = true
            Feedback.gameOver()
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
            let particle = SKSpriteNode.circle(diameter: radius * 2, color: color)
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
            let color = index < lives ? Palette.danger : Palette.border
            let replacement = SKSpriteNode.circle(diameter: 14, color: color)
            dot.texture = replacement.texture
            dot.color = color
        }
    }
}

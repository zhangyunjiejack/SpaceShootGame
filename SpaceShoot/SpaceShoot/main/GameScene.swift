
import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    
    var backGroundPlayer = AVAudioPlayer()
    var torpedoPlayer = AVAudioPlayer()
    var explosionPlayer = AVAudioPlayer()
    
    // Add lives
    var livesArray:[SKSpriteNode]!
    
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer:Timer!
    
    var possibleAliens = ["alien", "alien2", "alien3"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var yAcceleration:CGFloat = 0
    
    func stopBackGround() {
        self.backGroundPlayer.stop()
    }
    
    func playBackGroundMusic(fileNamed: String) {
        
        let url = Bundle.main.url(forResource: fileNamed, withExtension: nil)
        
        guard let newUrl = url else {
            
            print("Could not find file")
            return
        }
        do {
            backGroundPlayer = try AVAudioPlayer(contentsOf: newUrl)
            backGroundPlayer.numberOfLoops = -1
            backGroundPlayer.prepareToPlay()
            backGroundPlayer.volume = 0.5
            backGroundPlayer.play()
        }
        catch let error as NSError {
            print(error.description)
        }
        
    }
    
    func playTorpedo(fileNamed: String) {
        let url = Bundle.main.url(forResource: fileNamed, withExtension: nil)
        
        guard let newUrl = url else {
            
            print("Could not find file")
            return
        }
        do {
            torpedoPlayer = try AVAudioPlayer(contentsOf: newUrl)
            torpedoPlayer.numberOfLoops = 1
            torpedoPlayer.prepareToPlay()
            torpedoPlayer.volume = 0.2
            torpedoPlayer.play()
        }
        catch let error as NSError {
            print(error.description)
        }
        
    }
    
    func playExplosion(fileNamed: String) {
        let url = Bundle.main.url(forResource: fileNamed, withExtension: nil)
        
        guard let newUrl = url else {
            
            print("Could not find file")
            return
        }
        do {
            explosionPlayer = try AVAudioPlayer(contentsOf: newUrl)
            explosionPlayer.numberOfLoops = 1
            explosionPlayer.prepareToPlay()
            explosionPlayer.volume = 0.2
            explosionPlayer.play()
        }
        catch let error as NSError {
            print(error.description)
        }
        
    }
    
    override func didMove(to view: SKView) {
        
        addLives()
        
        self.playBackGroundMusic(fileNamed: "shootingStarsSelected.mp3")
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 20)
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 80, y: self.frame.size.height - 70)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
                //0.50 is for compensating the user holding angle
                self.yAcceleration = (CGFloat(acceleration.y) + 0.50) * 0.75 + self.yAcceleration * 0.25
            }
        }
        
        
        
    }
    
    // Add lives
    func addLives() {
        livesArray = [SKSpriteNode]()
        
        for live in 1 ... 3 {
            let liveNode = SKSpriteNode(imageNamed: "shuttle")
            liveNode.position = CGPoint(x: self.frame.size.width - CGFloat(4 - live) * liveNode.size.width * 0.5, y: self.frame.size.height - 60)
            
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
        
    }

    
    
    
    @objc func addAlien () {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height - CGFloat(arc4random_uniform(300)))
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        
        actionArray.append(SKAction.run {
            
            self.run(SKAction.playSoundFileNamed("loose.mp3", waitForCompletion: false))
            
            if self.livesArray.count > 0 {
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst()
                
                if self.livesArray.count == 0 {
                    // Game Over sound and screen
                    //                    self.run(SKAction.playSoundFileNamed("looseGame.mp3", waitForCompletion: true))
                    self.stopBackGround()
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    let gameOver = SKScene(fileNamed: "GameOver") as! GameOver
                    gameOver.score = self.score
                    self.view?.presentScene(gameOver, transition: transition)
                    
                }
            }
        })
        
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
    
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
    
    func fireTorpedo() {
        // self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        playTorpedo(fileNamed: "torpedo.mp3")
        
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        let torpedoNode2 = SKSpriteNode(imageNamed: "torpedo")
        let torpedoNode3 = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode2.position = player.position
        torpedoNode3.position = player.position
        torpedoNode.position.y += 5
        torpedoNode2.position.y += 5
        torpedoNode3.position.y += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        torpedoNode2.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode2.physicsBody?.isDynamic = true
        torpedoNode3.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode3.physicsBody?.isDynamic = true
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        torpedoNode2.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode2.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode2.physicsBody?.collisionBitMask = 0
        torpedoNode2.physicsBody?.usesPreciseCollisionDetection = true
        
        torpedoNode3.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode3.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode3.physicsBody?.collisionBitMask = 0
        torpedoNode3.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        self.addChild(torpedoNode2)
        self.addChild(torpedoNode3)
        
        let animationDuration:TimeInterval = 0.3
        
        
        var actionArray = [SKAction]()
        var actionArray2 = [SKAction]()
        var actionArray3 = [SKAction]()
        
        //CGFloat(arc4random_uniform(300)) - CGFloat(150)
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        actionArray2.append(SKAction.move(to: CGPoint(x: 10, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray2.append(SKAction.removeFromParent())
        
        actionArray3.append(SKAction.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray3.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
        torpedoNode2.run(SKAction.sequence(actionArray2))
        torpedoNode3.run(SKAction.sequence(actionArray3))
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
           torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    
    func torpedoDidCollideWithAlien (torpedoNode:SKSpriteNode, alienNode:SKSpriteNode) {
    
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        //        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        playExplosion(fileNamed: "explosion.mp3")
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 2)) { 
            explosion.removeFromParent()
        }
        
        score += 5
        
        
    }
    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 50
        player.position.y += yAcceleration * 50 //may should be deleted
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
        if player.position.y < -20 {
            player.position = CGPoint(x: player.position.x, y: self.size.height + 20)
        }else if player.position.y > self.size.height + 20 {
            player.position = CGPoint(x: player.position.x, y: -20)
        }
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
    }
}

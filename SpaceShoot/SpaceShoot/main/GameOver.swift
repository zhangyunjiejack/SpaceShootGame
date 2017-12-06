
import UIKit
import SpriteKit

class GameOver: SKScene {
    var score: Int = 0
    var startBackgroundNode: SKEmitterNode!
    var scoreLabel:SKLabelNode!
    var newGameButtonNode: SKSpriteNode!
    var backToMenu: SKSpriteNode!
    
    override func didMove (to view: SKView) {
        
        startBackgroundNode = self.childNode(withName: "starBackground") as! SKEmitterNode
        startBackgroundNode.advanceSimulationTime(10)
        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "\(score)"
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        
        backToMenu = self.childNode(withName: "backToMenu") as! SKSpriteNode
        
        self.run(SKAction.playSoundFileNamed("looseGame.mp3", waitForCompletion: true))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let node = self.nodes(at: location)
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)

            if node[0].name == "newGameButton" {
                let gameScene = GameScene(size: self.size)
                self.view!.presentScene(gameScene, transition: transition)
            }
            
            if node[0].name == "backToMenu" {
//                print(node[-1].name)

//                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
//                let menu = menuScene(size: self.size)
//                self.view!.presentScene(menu, transition: transition)
                
                if let view = self.view as! SKView? {
                    if let scene = SKScene(fileNamed: "Menu") {
                        scene.scaleMode = .aspectFill

                        view.presentScene(scene)
                    }

                    view.ignoresSiblingOrder = true

                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
}

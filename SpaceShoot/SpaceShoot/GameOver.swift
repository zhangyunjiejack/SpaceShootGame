//
//  GameOver.swift
//  SpacegameReloaded
//
//  Created by Ruijie Zhou on 12/5/17.
//  Copyright © 2017 Training. All rights reserved.
//

import UIKit
import SpriteKit

class GameOver: SKScene {
    var score: Int = 0
    var scoreLabel:SKLabelNode!
    var newGameButtonNode: SKSpriteNode!
    
    override func didMove (to view: SKView) {
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "\(score)"
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "newGameButton")
        
        self.run(SKAction.playSoundFileNamed("looseGame.mp3", waitForCompletion: true))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let node = self.nodes(at: location)
            
            if node[0].name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view!.presentScene(gameScene, transition: transition)
            }
        }
    }
    
}

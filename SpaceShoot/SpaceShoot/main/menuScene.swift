//
//  menuScene.swift
//  SpacegameReloaded
//
//  Created by 石济 on 11/11/17.
//  Copyright © 2017 Training. All rights reserved.
//

import SpriteKit

class menuScene: SKScene {
    var startBackgroundNode: SKEmitterNode!
    var newGameButtonNode: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        startBackgroundNode = self.childNode(withName: "starBackground") as! SKEmitterNode
        startBackgroundNode.advanceSimulationTime(10)
        newGameButtonNode = self.childNode(withName: "startButton") as! SKSpriteNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "startButton" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
            
            if nodesArray.first?.name == "info" {
                if let view = self.view as SKView? {
                    if let scene = SKScene(fileNamed: "AboutUs") {
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

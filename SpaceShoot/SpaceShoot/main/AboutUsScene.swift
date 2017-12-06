//
//  AboutUsScene.swift
//  SpaceShoot
//
//  Created by 石济 on 12/6/17.
//  Copyright © 2017 TeamNoobs. All rights reserved.
//

import SpriteKit

class AboutUsScene: SKScene {

    var startBackgroundNode: SKEmitterNode!
    var sj: SKSpriteNode!
    var zqe: SKSpriteNode!
    var zrj: SKSpriteNode!
    var zyj: SKSpriteNode!
    var back: SKSpriteNode!
    
    
    override func didMove(to view: SKView) {
        startBackgroundNode = self.childNode(withName: "starBackground") as! SKEmitterNode
        startBackgroundNode.advanceSimulationTime(10)
        sj = self.childNode(withName: "sj") as! SKSpriteNode
        zqe = self.childNode(withName: "zqe") as! SKSpriteNode
        zrj = self.childNode(withName: "zrj") as! SKSpriteNode
        zyj = self.childNode(withName: "zyj") as! SKSpriteNode
        back = self.childNode(withName: "backToMenu") as! SKSpriteNode
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let node = self.nodes(at: location)
            if node.first?.name == "startGame" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
}

//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Frank Thamel on 6/6/16.
//  Copyright © 2016 co.talene. All rights reserved.
//  Practice project. Orginal source included in the book "2D IOS and tvOS Games by Tutorials" - by
//  https://www.raywenderlich.com
//

import Foundation
import SpriteKit

class MainMenuScene : SKScene {
    override func didMoveToView(view: SKView) {
        let background  = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        addChild(background)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let block = SKAction.runBlock(){
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.doorwayWithDuration(1.5)
            self.view?.presentScene(myScene, transition: reveal)
        }
        
        runAction(block)
    }
}

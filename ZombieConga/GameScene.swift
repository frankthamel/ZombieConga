//
//  GameScene.swift
//  ZombieConga
//
//  Created by Frank Thamel on 6/4/16.
//  Copyright (c) 2016 co.talene. All rights reserved.
//  Practice project. Orginal source included in the book "2D IOS and tvOS Games by Tutorials" - by
//  https://www.raywenderlich.com
//

import SpriteKit

class GameScene: SKScene {
    
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime : NSTimeInterval = 0
    var dt : NSTimeInterval = 0
    let zombieMovePointsPerSec : CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect : CGRect
    var lastTouchLocation : CGPoint?
    let zombieRotateRadiansPerSecond = 4.0 * π
    let zombieAnimation : SKAction
    
    override init(size: CGSize) {
        let maxAspectRatio : CGFloat  = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        var textures : [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        
        super.init(size : size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.blackColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        /* Add the zombie to the scene*/
        zombie.position  = CGPoint(x: 400, y: 400)
        addChild(zombie)
        
        
        debugDrawPlayableArea()
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),SKAction.waitForDuration(2.0)])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat),SKAction.waitForDuration(1.0)])))

    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        //print("\(dt*1000) milliseconds since last update.")
        //zombie.position = CGPoint(x: zombie.position.x + 8, y: zombie.position.y)
        boundsCheckZombie()
        
        if let lastTouchLocation  = lastTouchLocation {
            let diff = lastTouchLocation - zombie.position
            if diff.length() <= zombieMovePointsPerSec * CGFloat(dt) {
                zombie.position = lastTouchLocation
                velocity = CGPointZero
                stopZombieAnimation()
            }else {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity,rotateRadiansPerSec: zombieRotateRadiansPerSecond)
            }
        }
    }
    
    func moveSprite (sprite : SKSpriteNode , velocity : CGPoint){
        let amountToMove = velocity * CGFloat(dt)        //print("Amount to move \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZombieTowards(location : CGPoint) {
        startZombieAnimation()
        let ofset = CGPoint(x: location.x - zombie.position.x, y:  location.y - zombie.position.y)
        let length = sqrt(Double(ofset.x * ofset.x + ofset.y * ofset.y))
        let direction = CGPoint(x: ofset.x / CGFloat(length), y: ofset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
    }
    
    func sceneTouched(touchLocation : CGPoint) {
        moveZombieTowards(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation  = touch.locationInNode(self)
        lastTouchLocation = touchLocation
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation  = touch.locationInNode(self)
        lastTouchLocation = touchLocation
        sceneTouched(touchLocation)
    }
    
    func boundsCheckZombie(){
        let bottomleft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomleft.x {
            zombie.position.x = bottomleft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x  >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomleft.y {
            zombie.position.y = bottomleft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y  = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func debugDrawPlayableArea () {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func rotateSprite(sprite : SKSpriteNode , direction : CGPoint , rotateRadiansPerSec : CGFloat) {
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt) , abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(
            x: size.width + enemy.size.width/2,
            y: CGFloat.random(
                min : CGRectGetMinY(playableRect) + enemy.size.height / 2 ,
                max : CGRectGetMaxY(playableRect) - enemy.size.height / 2 ))
        addChild(enemy)
        let actionMove = SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionReemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove , actionReemove]))
    }
    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(
                SKAction.repeatActionForever(zombieAnimation),
                withKey: "animation"
            )
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
    }
    
    func spawnCat () {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPoint(
            x: CGFloat.random(
                min: CGRectGetMinX(playableRect),
                max: CGRectGetMaxX(playableRect)
            ),
            y: CGFloat.random(
                min: CGRectGetMinY(playableRect),
                max: CGRectGetMaxY(playableRect)
            ))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        let wait = SKAction.waitForDuration(10.0)
        let dissapear = SKAction.scaleTo(0, duration: 0.5)
        let removeFormParent = SKAction.removeFromParent()
        let action = SKAction.sequence([appear, wait , dissapear , removeFormParent])
        cat.runAction(action)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

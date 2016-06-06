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
    let catCollisionSound = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var zombieIsInvisible = false
    let catMovePointsPerSec:CGFloat = 480.0
    var lives = 10
    var gameOver = false
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSec : CGFloat = 200.0
    
    
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
        playBackgroundMusic("backgroundMusic.mp3")
        
        backgroundColor = SKColor.blackColor()
        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        
        /* Add the zombie to the scene*/
        zombie.position  = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        addChild(zombie)
        
        
        //debugDrawPlayableArea()
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),SKAction.waitForDuration(2.0)])))
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat),SKAction.waitForDuration(1.0)])))
        
        addChild(cameraNode)
        camera = cameraNode
        //cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        //cameraNode.position = zombie.position
        setCameraPosition(CGPoint(x: size.width/2, y: size.height/2))

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
        
//        if let lastTouchLocation  = lastTouchLocation {
//            let diff = lastTouchLocation - zombie.position
//            if diff.length() <= zombieMovePointsPerSec * CGFloat(dt) {
//                zombie.position = lastTouchLocation
//                velocity = CGPointZero
//                stopZombieAnimation()
//            }else {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity,rotateRadiansPerSec: zombieRotateRadiansPerSecond)
//            }
//        }
        //checkCollisions()
        moveTrain()
        moveCamera()
        
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size : size ,won: false)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)
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
        let bottomleft = CGPoint(x: CGRectGetMinX(cameraRect), y: CGRectGetMinY(cameraRect))
        let topRight = CGPoint(x: CGRectGetMaxX(cameraRect) ,y: CGRectGetMaxY(cameraRect))
        
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
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: CGRectGetMaxX(cameraRect) + enemy.size.width/2,
            y: CGFloat.random(
                min : CGRectGetMinY(cameraRect) + enemy.size.height / 2 ,
                max : CGRectGetMaxY(cameraRect) - enemy.size.height / 2 ))
        enemy.zPosition = 50
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
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(
                min: CGRectGetMinX(cameraRect),
                max: CGRectGetMaxX(cameraRect)
            ),
            y: CGFloat.random(
                min: CGRectGetMinY(cameraRect),
                max: CGRectGetMaxY(cameraRect)
            ))
        cat.setScale(0)
        cat.zPosition = 50
        addChild(cat)
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        
        cat.zRotation = -π/16.0
        let leftWiggle = SKAction.rotateByAngle(π / 8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle , rightWiggle])
       
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp , scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        let dissapear = SKAction.scaleTo(0, duration: 0.5)
        let removeFormParent = SKAction.removeFromParent()
        let action = SKAction.sequence([appear , groupWait , dissapear , removeFormParent])
        cat.runAction(action)
    }
    
    func zombieHitCat (cat : SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0
        
        let turnGreen = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
        cat.runAction(turnGreen)
        
        runAction(catCollisionSound)
        //cat.removeFromParent()
    }
    
    func zombieHitEnemy (enemy : SKSpriteNode) {
        looseCats()
        lives--
      
        if !zombieIsInvisible {
            runAction(enemyCollisionSound)
            enemy.removeFromParent()
        }
        
        zombieIsInvisible = true
        
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration){
            node , elapsedTime in
            let slice = duration/blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        
        let setHidden = SKAction.runBlock(){
            self.zombie.hidden = false
            self.zombieIsInvisible = false
        }
        zombie.runAction(SKAction.sequence([blinkAction,setHidden]))
        
    }
    
    func checkCollisions() {
        var hitCats : [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame){
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        
        var hitEnimies : [SKSpriteNode] = []
        enumerateChildNodesWithName("enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(enemy.frame, self.zombie.frame){
                hitEnimies.append(enemy)
            }
        }
        for enemy in hitEnimies {
            zombieHitEnemy(enemy)
        }
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func moveTrain() {
        
        var trainCount  = 0
        var targetPosition = zombie.position
        
        enumerateChildNodesWithName("train") { node, stop in
            trainCount++
            if !node.hasActions() {
                
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.runAction(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 10 && !gameOver {
            gameOver = true
            print("you Win!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size : size ,won: true)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func looseCats() {
        var loseCount  = 0
        enumerateChildNodesWithName("train") {
            node , stop in
            var randomSpot  = node.position
            randomSpot.x += CGFloat.random(min : -100 , max : 100)
            randomSpot.y += CGFloat.random(min : -100 , max : 100)
            
            node.name = ""
            node.runAction(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotateByAngle(π*4, duration: 1.0),
                        SKAction.moveTo(randomSpot, duration: 1.0),
                        SKAction.scaleTo(0, duration: 1.0)
                        ]),
                    SKAction.removeFromParent()
                    ])
            )
            loseCount++
            if loseCount >= 2 {
                stop.memory = true
            }
        }
    }
    
    func overlapAmount() -> CGFloat {
        guard let view = self.view else {
            return 0
        }
        let scale = view.bounds.size.width / self.size.width
        let scaledHeight = self.size.height * scale
        let scaledOverlap = scaledHeight - view.bounds.size.height
        return scaledOverlap / scale
    }
    
    func getCameraPosition() -> CGPoint {
        return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + overlapAmount()/2)
    }
    
    func setCameraPosition(position : CGPoint) {
        cameraNode.position = CGPoint(x: position.x, y: position.y - overlapAmount()/2)
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }
    
    func moveCamera () {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodesWithName("background"){
            node , _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
    }
    
    var cameraRect : CGRect {
        return CGRect (
            x: getCameraPosition().x - size.width/2 + (size.width - playableRect.width)/2,
            y: getCameraPosition().y - size.height/2 + (size.height - playableRect.height)/2,
                width : playableRect.width,
                height: playableRect.height)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

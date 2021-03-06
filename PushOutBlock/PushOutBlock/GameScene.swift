//
//  GameScene.swift
//  PushOutBlock
//
//  Created by takashi on 2016/05/29.
//  Copyright (c) 2016年 Takashi Ikeda. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    enum ContactCategory: UInt32 {
        case Target = 1
        case Ball = 2
    }
    
    var gameSceneDelegate : GameSceneDelegate?
    
    var trialCount = 0
    var trialsLabel : SKLabelNode? {
        get {
            return self.childNode(withName: "trialsLabel") as? SKLabelNode
        }
    }
    
    var cueBlock : SKSpriteNode? {
        get {
            return self.childNode(withName: "moveNode") as? SKSpriteNode
        }
    }
    
    override func didMove(to view: SKView) {
        
        // 物理衝突のハンドリング
        self.physicsWorld.contactDelegate = self
        
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        //myLabel.text = "Push out the Orange Block! \n 1 Shot Only by swiping up the blue block !"
        myLabel.text = "swipe up the blue!".localized()
        myLabel.fontSize = 100
        myLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        myLabel.position.y -= myLabel.frame.size.height * 2
        myLabel.name = "panDataLabel"
        self.addChild(myLabel)
        
        /* Setup your scene here */
        let trialsLabel = SKLabelNode(fontNamed:"Chalkduster")
        trialsLabel.text = "\(self.trialCount)"
        trialsLabel.fontSize = 360
        trialsLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY + myLabel.frame.size.height)
        trialsLabel.name = "trialsLabel"
        self.addChild(trialsLabel)
        
        
        createAndAddMovingNode()
        
        // ぶつける対象
        createAndAddTargetNode()
    }
    
    let targetRamdom = GKRandomDistribution(lowestValue: 350, highestValue: 650)
    private func createAndAddTargetNode() {
        
        
        
        // ぶつける対象
        let targetNode = SKSpriteNode(color: UIColor.orange, size: CGSize(width: 200, height: 200))
        targetNode.position = CGPoint(x: targetRamdom.nextInt(), y: 1500)
        targetNode.name = "targetNode"
        targetNode.physicsBody = SKPhysicsBody(rectangleOf: targetNode.size)
        targetNode.physicsBody?.categoryBitMask = ContactCategory.Target.rawValue
//        targetNode.physicsBody?.contactTestBitMask = ContactCategory.Ball.rawValue
        targetNode.physicsBody?.affectedByGravity = false
        //targetNode.physicsBody?.dynamic = false
        self.addChild(targetNode)
        
        
    }
    
    private func createAndAddMovingNode() {
        // 移動制御の対象
        let moveNode = SKSpriteNode(color: UIColor(red:0, green:0.3, blue:1.0, alpha:1.0), size: CGSize(width: 200, height: 200))
        moveNode.position = CGPoint(x: 500, y: 500)
        moveNode.name = "moveNode"
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.panNode(_:)))
        self.view?.addGestureRecognizer(gesture)
        
        // 物理演算
        moveNode.physicsBody = SKPhysicsBody(rectangleOf: moveNode.size)
        // falseにしないと落ちる
        moveNode.physicsBody?.affectedByGravity = false
        // 自分が所蔵するカテゴリ
        moveNode.physicsBody?.categoryBitMask = ContactCategory.Ball.rawValue
        // 衝突判定用のビットフラグ
        // 衝突相手として有効にするカテゴリをビットフラグで設定する
        moveNode.physicsBody?.contactTestBitMask = ContactCategory.Target.rawValue
        
        self.addChild(moveNode)
        
    }
    
    // 指で上に強めにスワイプしたら移動するサンプル
    var isBeginAtMoveNode = false
    @objc func panNode(_ sender : UIPanGestureRecognizer) {
        var logtext = ""
        
        //retrieve pan movement along the x-axis of the view since the gesture began
        let currentTranslateLocation = sender.location(in: self.view)
        let currentTranslateTranslation = sender.translation(in: view!)
        let currentTranslateVelocity = sender.velocity(in: self.view)
        
        let currentTranslatePositionConverted = self.convertPoint(fromView: currentTranslateLocation)
        let currentTranslateVelocityConverted = self.convertPoint(fromView: currentTranslateVelocity)
        
        logtext = "currentTranslateLocation:\(currentTranslateLocation) currentTranslateVelocity:\(currentTranslateVelocity) currentTranslatePositionConverted:\(currentTranslatePositionConverted) currentTranslateVelocityConverted:\(currentTranslateVelocityConverted)"
        
        //        if let moveNode = self.childNodeWithName("moveNode") {
        //            moveNode.position.x = currentTranslatePositionConverted.x
        //            moveNode.position.y = currentTranslatePositionConverted.y
        //        }
        
        //calculate translation since last measurement
        //        let translateX = currentTranslatePosition.x - previousTranslateX
        //
        //        //move shape within frame boundaries
        //        let newShapeX = shape.position.x + translateX
        //        if newShapeX < frame.maxX && newShapeX > frame.minX {
        //            shape.position = CGPointMake(shape.position.x + translateX, shape.position.y)
        //        }
        
        //(re-)set previous measurement
        if sender.state == .ended {
            //previousTranslateX = 0
            logtext += " Ended"
            if self.isBeginAtMoveNode && currentTranslateVelocityConverted.y > 2000 {
                //self.childNodeWithName("moveNode")?.position.y += 100
                //self.moveTo(self.childNodeWithName("moveNode")!, to: self.childNodeWithName("targetNode")!)
                self.moveBy(from: self.childNode(withName: "moveNode")!, dx: currentTranslateVelocityConverted.x, dy: currentTranslateVelocityConverted.y)
                (self.childNode(withName: "panDataLabel") as? SKLabelNode)?.text = "Fire !".localized()
                
            }
            
            self.isBeginAtMoveNode = false
        }
        else if sender.state == .began {
            //self.isBeginAtMoveNode = self.nodeAtPoint(currentTranslatePositionConverted).name == "moveNode"
        }
        else {
            //previousTranslateX = currentTranslateX
            //sender.setTranslation(CGPointZero, inView:view)
        }
        
        print(logtext)
        
        //(self.childNodeWithName("panDataLabel") as? SKLabelNode)?.text = logtext
    }
    
    private func moveTo(from : SKNode, to : SKNode) {
        let action = SKAction.move(to: to.position, duration: 1)
        action.timingMode = .easeIn
        from.run(action)
    }
    
    private func moveBy(from : SKNode, dx : CGFloat, dy : CGFloat) {
        
        let action = SKAction.move(by: CGVector(dx: dx, dy: dy), duration: 1)
        action.timingMode = .easeIn
        from.run(action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.location(in: self)
            
            // 移動させる対象のノードでタッチを開始したか
            self.isBeginAtMoveNode = self.atPoint(location).name == "moveNode"
            
//            let sprite = self.atPoint(location)
//            sprite.position = location
//            rotationNode(node: sprite)
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        removeMovingNodeIfOutOfSceneAndCreateMovingNode()
    }
    
    let initialYOfCueBlock = 500
    
    private func resetPositionMovingBlock() {
        self.cueBlock?.removeAllActions()
        self.cueBlock?.position = CGPoint(x: 500, y: self.initialYOfCueBlock)
        self.cueBlock?.zRotation = 0
        
    }
    
    private func removeMovingNodeIfOutOfSceneAndCreateMovingNode() {
        // 領域外のノードを取り除くのも、ひとつの機能（Component）だから、
        // 本番で作るときは、GKComponentで処理する
        // あとは、Stateがからむかどうかだけど…
        if let moveNode = self.childNode(withName: "moveNode") {
            if !moveNode.intersects(self) {
                moveNode.removeAllActions()
                
                // 除去＆作成だとなんか、touchesBeganでアニメーション止まるくらい遅く？なる影響あり
                resetPositionMovingBlock()
                //moveNode.removeFromParent()
                //                self.removeChildrenInArray([moveNode])
                //                createAndAddMovingNode()
                
                if (self.childNode(withName: "panDataLabel") as? SKLabelNode)?.text == "Fire !".localized() {
                    (self.childNode(withName: "panDataLabel") as? SKLabelNode)?.text = "Missed !".localized()
                }
                
                self.trialCount += 1
                self.trialsLabel?.text = "\(self.trialCount)"
            }
        }
        
        if let targetNode = self.childNode(withName: "targetNode") {
            // 外に出る順番が、ターゲット→持ち球の順になるため、カウンターのリセットが難しい
            // ターゲットが外に出たら
            if !targetNode.intersects(self) {
                targetNode.removeAllActions()
                //targetNode.removeFromParent()
                targetNode.position = CGPoint(x: targetRamdom.nextInt(), y: 1500)
                targetNode.zRotation = 0
                
                //                self.removeChildrenInArray([targetNode])
                //
                //                createAndAddTargetNode()
                
                if Int(self.cueBlock?.position.y ?? 0) != self.initialYOfCueBlock {
                    self.trialCount += 1
                }
                resetPositionMovingBlock()
                
                (self.childNode(withName: "panDataLabel") as? SKLabelNode)?.text = "WonMessage".localized(args : ["\(self.trialCount)"])
                self.trialCount = 0
                self.trialsLabel?.text = "\(self.trialCount)"
                
                self.gameSceneDelegate?.didClear()
            }
        }
        
    }
    
    private func rotationNode(node : SKNode) {
        let sprite = node
        sprite.xScale = 1.1
        sprite.yScale = 1.1
        
        let action = SKAction.rotate(byAngle: CGFloat(M_PI), duration:1)
        
        // なんか足し込めるらしく、何回もタップすると、回転が早くなる。
        sprite.run(SKAction.repeatForever(action))
    }
}

extension GameScene : SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        (self.childNode(withName: "panDataLabel") as? SKLabelNode)?.text = "Hit !".localized()
        if let node = firstBody.node {
            // 回転して、衝突して、回転して、衝突して、…を細かく繰り返し、ぎりぎり衝突しないところまで続く。
            rotationNode(node: node)
        }
        
        //        if firstBody.categoryBitMask & ContactCategory.Target.rawValue > 0 && secondBody.categoryBitMask & ContactCategory.Ball.rawValue > 0 {
        //            secondBody.node?.removeFromParent()
        //        }
    }
}

protocol GameSceneDelegate {
    func didClear()
}

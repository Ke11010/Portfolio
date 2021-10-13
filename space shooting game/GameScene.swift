//
//  GameScene.swift
//  space shooting game
//
//  Created by Keiju Kashimoto on 2021/09/26.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameVC: GameViewController!
    
    let explosionSound = SKAction.playSoundFileNamed("爆発1.mp3", waitForCompletion: false)

    let motionManager = CMMotionManager()
    var accelaration: CGFloat = 0.0
    
    var timer: Timer?
    var timerForUFO: Timer?
        var ufoDuration: TimeInterval = 6.0 {
            didSet {
                if ufoDuration < 2.0 {
                    timerForUFO?.invalidate()
                }
            }
        }
    
    
    var score: Int = 0 {
            didSet {
                scoreLabel.text = "Score: \(score)"
            }
        }

    
    let spaceshipCategory: UInt32 = 0b001
    let missileCategory: UInt32 = 0b0010
    let ufoCategory: UInt32 = 0b0100
    let redCategory: UInt32 = 0b1000
    
    
    var red: SKSpriteNode!
    var spaceship: SKSpriteNode!
    var hearts: [SKSpriteNode] = []
    var scoreLabel: SKLabelNode!
    
    
    override func didMove(to view: SKView){
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        self.red = SKSpriteNode(imageNamed: "red")
        self.red.xScale = 1.5
        self.red.yScale = 0.3
        self.red.position = CGPoint(x: 0, y: -frame.height / 2-100 )
        self.red.zPosition = -1.0
        self.red.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 100))
        self.red.physicsBody?.categoryBitMask = redCategory
        self.red.physicsBody?.contactTestBitMask = ufoCategory
        self.red.physicsBody?.collisionBitMask = 0
        addChild(self.red)
    
        self.spaceship=SKSpriteNode(imageNamed: "spaceship")
        self.spaceship.scale(to: CGSize(width: frame.width / 5, height: frame.width / 5))
        self.spaceship.position = CGPoint(x:self.frame.size.width / 2, y:spaceship.size.height/2-500)
        self.spaceship.physicsBody = SKPhysicsBody(circleOfRadius:
                                                    self.spaceship.frame.width * 0.1)
        self.spaceship.physicsBody?.categoryBitMask = spaceshipCategory
        self.spaceship.physicsBody?.contactTestBitMask = ufoCategory
        self.spaceship.physicsBody?.collisionBitMask = 0
        addChild(self.spaceship)
        
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!){ (data, _) in
            guard let data = data else {return}
            let a = data.acceleration
            self.accelaration = CGFloat(a.x) * 0.75 + self.accelaration * 0.25
            
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block:{_ in self.addUFO()
            
        } )
        
        
        for i in 1...5 {
                    let heart = SKSpriteNode(imageNamed: "heart")
                    heart.position = CGPoint(x: -frame.width / 2 + heart.frame.height * CGFloat(i), y: frame.height / 2 - heart.frame.height)
                    addChild(heart)
                    hearts.append(heart)
        }
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 50
        scoreLabel.position = CGPoint(x: -frame.width / 2 + scoreLabel.frame.width / 2 + 50, y: frame.height / 2 - scoreLabel.frame.height * 5)
        addChild(scoreLabel)
        
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        let bestScoreLabel = SKLabelNode(text: "Best Score: \(bestScore)")
        bestScoreLabel.fontName = "AmericanTypewriter-Bold"
        bestScoreLabel.fontSize = 30
        bestScoreLabel.position = scoreLabel.position.applying(CGAffineTransform(translationX: 0, y: -bestScoreLabel.frame.height * 1.5))
        addChild(bestScoreLabel)
        
        timerForUFO = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { _ in
            self.ufoDuration -= 0.25
        })
        
    }
    
    
    override func didSimulatePhysics(){
        let nextPosition = self.spaceship.position.x + self.accelaration * 50
        if nextPosition > frame.width / 2 - 30 {return}
        if nextPosition < -frame.width / 2 + 30 {return}
        self.spaceship.position.x = nextPosition
        }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPaused{return}
        let missile = SKSpriteNode(imageNamed: "missile")
        missile.position = CGPoint(x: self.spaceship.position.x, y: self.spaceship.position.y + 50)
        missile.physicsBody = SKPhysicsBody(circleOfRadius: missile.frame.height / 2)
        missile.physicsBody?.categoryBitMask = missileCategory
        missile.physicsBody?.contactTestBitMask = ufoCategory
        missile.physicsBody?.collisionBitMask = 0
        addChild(missile)
        
        let moveToTop = SKAction.moveTo(y: frame.height + 10, duration: 0.3)
        let remove = SKAction.removeFromParent()
        missile.run(SKAction.sequence([moveToTop, remove]))
        self.run(SKAction.playSoundFileNamed("shot.mp3", waitForCompletion: false))
    }
    
    func addUFO() {
        let names = ["ufo1", "ufo2", "ufo3"]
        let index = Int(arc4random_uniform(UInt32(names.count)))
        let name = names[index]
        let ufo = SKSpriteNode(imageNamed: name)
        let random = CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX)
        let positionX = frame.width * (random - 0.5)
        ufo.position = CGPoint(x: positionX, y:frame.height / 2 + ufo.frame.height)
        ufo.scale(to: CGSize(width: 70, height: 70))
        ufo.physicsBody = SKPhysicsBody(circleOfRadius: ufo.frame.width)
        ufo.physicsBody?.categoryBitMask = ufoCategory
        ufo.physicsBody?.contactTestBitMask = missileCategory + spaceshipCategory + redCategory
        ufo.physicsBody?.collisionBitMask = 0
        addChild(ufo)
        
        let move = SKAction.moveTo(y: -frame.height / 2 - ufo.frame.height, duration : ufoDuration)
        let remove = SKAction.removeFromParent()
        ufo.run(SKAction.sequence([move, remove]))
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var ufo: SKPhysicsBody
        var target: SKPhysicsBody

        if contact.bodyA.categoryBitMask == ufoCategory {
                ufo = contact.bodyA
                target = contact.bodyB
        } else {
            ufo = contact.bodyB
            target = contact.bodyA
        }

        guard let ufoNode = ufo.node else { return }
        guard let targetNode = target.node else { return }
        guard let explosion = SKEmitterNode(fileNamed: "explosion") else { return }
        explosion.position = ufoNode.position
        addChild(explosion)
        self.run(SKAction.playSoundFileNamed("爆発1.mp3", waitForCompletion: false))

        ufoNode.removeFromParent()
        if target.categoryBitMask == missileCategory {
            targetNode.removeFromParent()
            score += 5
            
            }

        self.run(SKAction.wait(forDuration: 1.0)) {
                explosion.removeFromParent()
            }
        
        if target.categoryBitMask == spaceshipCategory || target.categoryBitMask == redCategory {
            self.run(SKAction.playSoundFileNamed("大爆発.mp3", waitForCompletion: false))
            guard let heart = hearts.last else { return }
            heart.removeFromParent()
            hearts.removeLast()
            
            if hearts.isEmpty{
                gameOver()
            }
                }
    }
    
    
    func gameOver(){
        isPaused = true
        timer?.invalidate()
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        if score > bestScore {
                    UserDefaults.standard.set(score, forKey: "bestScore")
                }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in self.gameVC.dismiss(animated: true, completion: nil)
            
        }
    }
    
}

//
//  GameScene.swift
//  Project20
//
//  Created by Mehmet Sadıç on 03/06/2017.
//  Copyright © 2017 Mehmet Sadıç. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  var timer: Timer!
  var fireWorks = [SKNode]()
  var scoreLabel: SKLabelNode!
  
  var score: Int = 0 {
    didSet {
      // Set score label
      scoreLabel.text = "Score: \(score)"
    }
  }
  
  let leftEdge = -22
  let rightEdge = 1024 + 22
  let bottomEdge = -22
  
  override func didMove(to view: SKView) {
    // Create background
    let background = SKSpriteNode(imageNamed: "background")
    background.position = CGPoint(x: 512, y: 384)
    background.zPosition = -1
    background.blendMode = .replace
    addChild(background)
    
    // Initialize scoreLabel and add to parent view
    scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    scoreLabel.position = CGPoint(x: 8, y: 8)
    scoreLabel.text = "Score: 0"
    scoreLabel.zPosition = 1
    scoreLabel.horizontalAlignmentMode = .left
    addChild(scoreLabel)
    
    // Schedule a timer which every 6 seconds calls launchFireworks function
    timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    checkTouches(touches)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    checkTouches(touches)
  }
  
  override func update(_ currentTime: TimeInterval) {
    for (index, node) in fireWorks.enumerated().reversed() {
      if node.position.y > 900 {
        node.removeFromParent()
        fireWorks.remove(at: index)
      }
    }
  }
  
  /* Creates one firework given its initial position and target x value */
  private func createFirework(xMovement: CGFloat, x: Int, y: Int) {
    
    // Create the rocket container node
    let container = SKNode()
    container.position = CGPoint(x: x, y: y)
    addChild(container)
    fireWorks.append(container)
    
    
    // Create rocket node
    let firework = SKSpriteNode(imageNamed: "rocket")
    firework.name = "firework"
    container.addChild(firework)
    
    // Create emitter node
    let fuseEmitter = SKEmitterNode(fileNamed: "fuse")!
    fuseEmitter.position = CGPoint(x: 0, y: -22)
    container.addChild(fuseEmitter)
    
    let randomColorNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
    
    // Choose a random color for firework
    switch randomColorNumber {
    case 0:
      firework.color = .cyan
      firework.colorBlendFactor = 1
    case 1:
      firework.color = .red
      firework.colorBlendFactor = 1
    case 2:
      firework.color = .yellow
      firework.colorBlendFactor = 1
    default:
      break
    }
    
    
    // Create the path for firework to follow
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: xMovement, y: 1000))
    
    // Our firework follows the given path
    let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
    container.run(move)
    
  }
  
  /* Call several fireworks */
  func launchFireworks() {
    
    // Number for firework movement left to right or right to left
    let sideToSideNumber: CGFloat = 1500
    
    // random number for different mode of launching fireworks
    let randomFireworkModeNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 4)
    
    switch randomFireworkModeNumber {
    case 0:
      // Fireworks from left and right
      createFirework(xMovement: 800, x: leftEdge, y: 0)
      createFirework(xMovement: 800, x: leftEdge, y: 100)
      createFirework(xMovement: 800, x: leftEdge, y: 200)
      createFirework(xMovement: -800, x: rightEdge, y: 300)
      createFirework(xMovement: -800, x: rightEdge, y: 400)
      
    case 1:
      // Fireworks up in a fan
      createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
      createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
      createFirework(xMovement: 0, x: 512, y: bottomEdge)
      createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
      createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
      
    case 2:
      // Fireworks from left edge to right
      createFirework(xMovement: sideToSideNumber, x: leftEdge, y: 0)
      createFirework(xMovement: sideToSideNumber, x: leftEdge, y: 100)
      createFirework(xMovement: sideToSideNumber, x: leftEdge, y: 200)
      createFirework(xMovement: sideToSideNumber, x: leftEdge, y: 300)
      createFirework(xMovement: sideToSideNumber, x: leftEdge, y: 400)
      
    case 3:
      // Fireworks from right edge to left
      createFirework(xMovement: -sideToSideNumber, x: rightEdge, y: 0)
      createFirework(xMovement: -sideToSideNumber, x: rightEdge, y: 100)
      createFirework(xMovement: -sideToSideNumber, x: rightEdge, y: 200)
      createFirework(xMovement: -sideToSideNumber, x: rightEdge, y: 300)
      createFirework(xMovement: -sideToSideNumber, x: rightEdge, y: 400)
      
    default:
      break
    }
    
  }
  
  /* Select fireworks. Same color fireworks can be selected.
   If a different color firework is selected then all selected ones are 
   deselected */
  private func checkTouches(_ touches: Set<UITouch>) {
    
    // We should have at least one touch to call this function
    guard let touch = touches.first else { return }
    
    // Location of our touch
    let location = touch.location(in: self)
    
    // Array of nodes at touching point
    let nodesAtPoint = nodes(at: location)
    
    // Iterate through all the nodes at touched point.
    for node in nodesAtPoint {
      // We should find only fireworks not parent node or emitter node
      if let sprite = node as? SKSpriteNode {
        // If we find a firework then it is marked as selected.
        if sprite.name == "firework" {
          
          // If the new selected firework is of different color then
          // all the previous selected fireworks should be deselected
          for parentNode in fireWorks {
            let firework = parentNode.children[0] as! SKSpriteNode
            if firework.name == "selected" && sprite.color != firework.color {
              firework.name = "firework"
              firework.colorBlendFactor = 1
            }
          }
          
          // Change the name so that it cant be selected more than once
          sprite.name = "selected"
          
          // Clear the color of firework
          sprite.colorBlendFactor = 0
        }
      }
      
    }
    
  }
  
  /* Explode one firework */
  private func explode(firework: SKNode) {
    
    let emitter = SKEmitterNode(fileNamed: "explode")!
    emitter.position = firework.position
    addChild(emitter)
  }
  
  /* Explode selected fireworks */
  func explodeFireworks() {
  
    // Number of selected fireworks before explosion
    var numSelectedFireworks = 0
    
    // Loop over fireworks array and find selected ones
    // Destroy the selected fireworks
    for (index, containerNode) in fireWorks.enumerated().reversed() {
      let firework = containerNode.children[0] as! SKSpriteNode
      if firework.name == "selected" {
        explode(firework: containerNode)
        fireWorks.remove(at: index)
        containerNode.removeFromParent()
        numSelectedFireworks += 1
      }
    }
    
    // According to number of explosion in one shot calculate the score
    switch numSelectedFireworks {
    case 0:
      // No explosion.
      break
    case 1:
      score += 200
    case 2:
      score += 500
    case 3:
      score += 1500
    case 4:
      score += 2500
    default:
      score += 4000
    }
    
  }
  
  
}

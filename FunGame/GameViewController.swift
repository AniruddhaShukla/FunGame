//
//  GameViewController.swift
//  FunGame
//
//  Created by Aniruddha Shukla on 6/17/17.
//  Copyright © 2017 Innovating Solutions LLC. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    var gameView: SCNView!
    var gameScene: SCNScene!
    var cameraNode: SCNNode!
    var targetCreationTime: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
    }
    
    func initView () {
        gameView = self.view as! SCNView
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        gameView.delegate = self
    }
    
    func initScene () {
        gameScene = SCNScene ()
        gameView.scene = gameScene
        
        gameView.isPlaying = true
    }
    
    
    func initCamera () {
        cameraNode = SCNNode ()
        cameraNode.camera = SCNCamera ()
        cameraNode.position = SCNVector3(x:0, y:5, z:10)
        gameScene.rootNode.addChildNode(cameraNode)
        
    }
    
    func createTarget () {
        let geometry:SCNGeometry = SCNPyramid(width:1, height:1, length:1)
        
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.green : UIColor.red
        geometry.materials.first?.diffuse.contents = randomColor
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor.red {
            geometryNode.name = "enemy"
        } else {
            geometryNode.name = "friend"
        }
        gameScene.rootNode.addChildNode(geometryNode)
        
        let randomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3(x:randomDirection, y:15, z:0)
        geometryNode.physicsBody?.applyForce(force, at:SCNVector3Make(0.05, 0.05, 0.05), asImpulse:true)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            createTarget()
            targetCreationTime = time + 0.6
        }
        cleanUp()
    }
    
    func cleanUp () {
        for node in gameScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        
        // Perform hit test to see what object it hit
        let hitList = self.gameView.hitTest(location, options: nil)
        
        if let hitObject = hitList.first {
            let node = hitObject.node
            
            if node.name == "friend" {
                node.removeFromParentNode()
                self.gameView.backgroundColor = .black
            } else {
                node.removeFromParentNode()
                self.gameView.backgroundColor = .red
            }
        }
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

//
//  ViewController.swift
//  worlds
//
//  Created by Johan Halin on 17/10/2017.
//  Copyright © 2017 Dekadence. All rights reserved.
//

import UIKit
import AVFoundation
import SceneKit

class ViewController: UIViewController {
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let sceneView: SCNView
    let camera: SCNNode
    let skyBoxes: [SCNNode]
    
    var boxes: [SCNNode]

    // MARK: Private
    
    @objc private func startButtonTouched(button: UIButton) {
        UIView.animate(withDuration: 1, animations: {
            self.startButton.alpha = 0
        }, completion: { _ in
            self.startButton.removeFromSuperview()
            self.start()
        })
    }
    
    fileprivate func moveCamera() {
        let cameraDuration = TimeInterval(120)
        
        let cameraMoveAction = SCNAction.move(to: SCNVector3Make(0, 30, 200), duration: cameraDuration)
        cameraMoveAction.timingMode = SCNActionTimingMode.easeInEaseOut
        self.camera.runAction(cameraMoveAction)
        
        let cameraRotateAction = SCNAction.rotateBy(x: -0.15, y: 0, z: 0, duration: cameraDuration)
        cameraRotateAction.timingMode = cameraMoveAction.timingMode
        self.camera.runAction(cameraRotateAction)
    }
    
    fileprivate func rotateSphereBoxes() {
        for boxNode in self.boxes {
            boxNode.runAction(
                SCNAction.repeatForever(
                    SCNAction.rotateBy(
                        x: CGFloat(-10 + Int(arc4random_uniform(20))),
                        y: CGFloat(-10 + Int(arc4random_uniform(20))),
                        z: CGFloat(-10 + Int(arc4random_uniform(20))),
                        duration: TimeInterval(8 + arc4random_uniform(5))
                    )
                )
            )
        }
    }
    
    private func start() {
        self.audioPlayer.play()
        
        UIView.animate(withDuration: 10, animations: {
            self.sceneView.alpha = 1.0
        })

        moveCamera()
        rotateSphereBoxes()
        
        for skybox in self.skyBoxes {
            skybox.runAction(
                SCNAction.repeatForever(
                    SCNAction.rotateBy(
                        x: CGFloat(-10 + Int(arc4random_uniform(20))),
                        y: CGFloat(-10 + Int(arc4random_uniform(20))),
                        z: CGFloat(-10 + Int(arc4random_uniform(20))),
                        duration: TimeInterval(18 + arc4random_uniform(5))
                    )
                )
            )
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audioPlayer.prepareToPlay()
        
        self.sceneView.alpha = 0
        self.view.backgroundColor = UIColor.black
        
        let scene = SCNScene()
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor(white: 0.5, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLight.LightType.omni
        omniLightNode.light!.color = UIColor(white: 0.75, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 50, 50)
        scene.rootNode.addChildNode(omniLightNode)
        
        scene.rootNode.addChildNode(self.camera)

        var i = 0 // this whole thing is for debugging purposes. should be a texture actually or something
        
        for skyboxNode in self.skyBoxes {
            guard let skybox = skyboxNode.geometry as! SCNBox? else { abort() }
            
            let length = CGFloat(500)
            skybox.width = length
            skybox.height = length
            skybox.length = length
            
            skybox.firstMaterial?.diffuse.contents = i == 0 ? UIColor.green : UIColor.red
            skybox.firstMaterial?.isDoubleSided = true
            
            scene.rootNode.addChildNode(skyboxNode)
            
            i += 1
        }
        
        let boxCount = 32
        
        for i in 0...boxCount {
            let ratio = sin((Float.pi) * (Float(i) / Float(boxCount)))
            let half = Float(boxCount) / Float(2)
            let ratio2 = sin((Float.pi / 2.0) * ((half - Float(i)) / half))
            let radius = 50.0 * ratio
            let boxesPerRow = Int(ratio * Float(boxCount))
            
            for j in 0..<boxesPerRow {
                let box = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0)
                let boxNode = SCNNode(geometry: box)
                let angle = (Float(j) / Float(boxesPerRow)) * (Float.pi * 2)

                boxNode.position = SCNVector3Make(
                    sin(angle) * radius,
                    50.0 * ratio2,
                    cos(angle) * radius
                )
                
                self.boxes.append(boxNode)
                scene.rootNode.addChildNode(boxNode)
            }
        }
        
        self.sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FIXME: temporary
        self.startButton.isHidden = true
//        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        
        self.sceneView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.start()
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    init() {
        if let trackUrl = Bundle.main.url(forResource: "track", withExtension: "m4a") {
            guard let audioPlayer = try? AVAudioPlayer(contentsOf: trackUrl) else {
                abort()
            }
            
            self.audioPlayer = audioPlayer
        } else {
            abort()
        }
        
        self.startButton = UIButton.init(type: UIButtonType.custom)
        self.startButton.setTitle("start", for: UIControlState.normal)
        self.startButton.backgroundColor = UIColor.black
        
        self.sceneView = SCNView(frame: CGRect.zero)
        
        self.boxes = []
        
        self.camera = SCNNode()
        let camera = SCNCamera()
        camera.zFar = 600
        camera.vignettingIntensity = 1
        camera.vignettingPower = 1
        self.camera.camera = camera // lol
        self.camera.position = SCNVector3Make(0, 0, 58)
        
        self.skyBoxes = [ SCNNode(geometry: SCNBox()), SCNNode(geometry: SCNBox()) ]
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.addSubview(self.sceneView)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.startButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

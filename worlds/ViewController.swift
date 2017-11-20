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

class ViewController: UIViewController, AVAudioPlayerDelegate {
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let sceneView: SCNView
    let camera: SCNNode
    let skyBoxes: [SCNNode]
    let endView: UIView = UIView.init(frame: CGRect.zero)

    var boxes: [SCNNode]

    // MARK: - Private
    
    @objc private func startButtonTouched(button: UIButton) {
        UIView.animate(withDuration: 4, animations: {
            self.startButton.alpha = 0
        }, completion: { _ in
            self.startButton.removeFromSuperview()
            self.start()
        })
    }
    
    fileprivate func moveCamera() {
        let cameraDuration = TimeInterval(160)
        
        let cameraMoveAction = SCNAction.move(to: SCNVector3Make(0, 30, 200), duration: cameraDuration)
        cameraMoveAction.timingMode = SCNActionTimingMode.easeIn
        self.camera.runAction(cameraMoveAction)
        
        let cameraRotateAction = SCNAction.rotateBy(x: -0.25, y: 0, z: 0, duration: cameraDuration)
        cameraRotateAction.timingMode = cameraMoveAction.timingMode
        self.camera.runAction(cameraRotateAction)
    }
    
    fileprivate func rotateSkyboxes() {
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
    
    fileprivate func crunchEnding() {
        let waitAction = SCNAction.wait(duration: 118)
        
        let moveAction = SCNAction.move(to: SCNVector3Make(0, 0, 0), duration: 1)
        moveAction.timingMode = SCNActionTimingMode.easeIn
        
        let sequence = SCNAction.sequence([ waitAction, moveAction ])
        
        for box in self.boxes {
            box.runAction(sequence)
        }
    }
    
    fileprivate func start() {
        self.audioPlayer.play()
        
        UIView.animate(withDuration: 10, animations: {
            self.sceneView.alpha = 1.0
        })

        moveCamera()
        rotateSkyboxes()
        rotateSphereBoxes()
        crunchEnding()
    }

    fileprivate func configureLight(_ scene: SCNScene) {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = SCNLight.LightType.omni
        omniLightNode.light?.color = UIColor(white: 1.0, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, -60, 60)
        scene.rootNode.addChildNode(omniLightNode)
    }
    
    fileprivate func configureSkyboxes(_ scene: SCNScene) {
        for skyboxNode in self.skyBoxes {
            guard let skybox = skyboxNode.geometry as! SCNBox? else { abort() }
            
            let length = CGFloat(500)
            skybox.width = length
            skybox.height = length
            skybox.length = length
            
            skybox.firstMaterial?.diffuse.contents = UIImage.init(named: "texture1")
            skybox.firstMaterial?.isDoubleSided = true
            
            scene.rootNode.addChildNode(skyboxNode)
        }
    }
    
    fileprivate func configureSphereBoxes(_ scene: SCNScene) {
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
                
                box.firstMaterial?.diffuse.contents = UIColor.init(white: 1.0, alpha: 1.0)
                
                self.boxes.append(boxNode)
                scene.rootNode.addChildNode(boxNode)
            }
        }
    }
    
    fileprivate func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black
        
        scene.rootNode.addChildNode(self.camera)

        configureLight(scene)
        configureSkyboxes(scene)
        configureSphereBoxes(scene)
        
        return scene
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (flag) {
            self.sceneView.isHidden = true
            self.endView.isHidden = false
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audioPlayer.prepareToPlay()
        self.audioPlayer.delegate = self
        
        self.sceneView.alpha = 0
        self.view.backgroundColor = UIColor.black
        
        self.sceneView.scene = createScene()
        
        self.endView.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.sceneView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.endView.frame = CGRect(
            x: (self.view.bounds.size.width / 2) - 1,
            y: (self.view.bounds.size.height / 2) - 1,
            width: 2,
            height: 2
        )
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
        
        self.endView.isHidden = true
        self.view.addSubview(self.endView)
        
        self.view.addSubview(self.sceneView)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.startButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

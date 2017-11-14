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
    
    private func start() {
        self.audioPlayer.play()
        
        UIView.animate(withDuration: 10, animations: {
            self.sceneView.alpha = 1.0
        })

        self.camera.runAction(SCNAction.move(to: SCNVector3Make(0, 10, 50), duration: 10))
        
        for boxNode in self.boxes {
            boxNode.runAction(
                SCNAction.repeatForever(
                    SCNAction.rotateBy(
                        x: CGFloat(-10 + Int(arc4random_uniform(20))),
                        y: CGFloat(-10 + Int(arc4random_uniform(20))),
                        z: CGFloat(-10 + Int(arc4random_uniform(20))),
                        duration: 10
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
//        self.sceneView.allowsCameraControl = true

        for i in 0...10 {
            let box = SCNBox(width: 10, height: 10, length: 10, chamferRadius: 0)
            let boxNode = SCNNode(geometry: box)
            boxNode.position = SCNVector3Make(Float(-100 + (i * 20)), 0, 0)
            self.boxes.append(boxNode)
            scene.rootNode.addChildNode(boxNode)
        }
        
        self.sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FIXME: temporary
        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.sceneView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        self.start()
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
        self.camera.camera = SCNCamera()
        self.camera.position = SCNVector3Make(0, 0, 25)

        super.init(nibName: nil, bundle: nil)
        
        self.view.addSubview(self.sceneView)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.startButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

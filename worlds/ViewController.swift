//
//  ViewController.swift
//  worlds
//
//  Created by Johan Halin on 17/10/2017.
//  Copyright © 2017 Dekadence. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    
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
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FIXME: temporary
//        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.startButton.isHidden = true
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
            self.audioPlayer.prepareToPlay()
        } else {
            abort()
        }
        
        self.startButton = UIButton.init(type: UIButtonType.custom)
        self.startButton.setTitle("start", for: UIControlState.normal)

        super.init(nibName: nil, bundle: nil)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.startButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

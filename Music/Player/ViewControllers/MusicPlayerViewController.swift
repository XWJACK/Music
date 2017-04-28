//
//  MusicPlayerViewController.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import Wave

final class MusicPlayerViewController: UIViewController {
    
    private let musicPlayerView = MusicPlayerView()
    private var player: StreamAudioPlayer? = nil
    
    override func loadView() {
        view = musicPlayerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func createPlayer() {
        player = StreamAudioPlayer()
        player?.delegate = self
    }
}

extension MusicPlayerViewController: MusicPlayerViewDelegate {
    
    func leftSwipe(sender: UISwipeGestureRecognizer) {
        
    }
    
    func rightSwipe(sender: UISwipeGestureRecognizer) {
        
    }
    
    func playButtonClicked(sender: UIButton) {
        
    }
    
    func lastButtonClicked(sender: UIButton) {
        
    }
    
    func nextButtonClicked(sender: UIButton) {
        
    }
    
    func lovedClicked(sender: UIButton) {
        
    }
    
    func downloadClicked(sender: UIButton) {
        
    }
}

extension MusicPlayerViewController: StreamAudioPlayerDelegate {
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, parsedDuration duration: TimeInterval) {
        
    }
}

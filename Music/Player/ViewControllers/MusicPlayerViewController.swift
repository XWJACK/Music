//
//  MusicPlayerViewController.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

final class MusicPlayerViewController: UIViewController, MusicPlayerViewDelegate {
    
    private let musicPlayerView = MusicPlayerView()
    private var player: AudioPlayer?
    
    override func loadView() {
        view = musicPlayerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


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

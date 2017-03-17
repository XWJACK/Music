//
//  MusicPlayerViewController.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

final class MusicPlayerViewController: UIViewController {
    
    private let musicPlayerView = MusicPlayerView()
    
    override func loadView() {
        view = musicPlayerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - MusicPlayerViewDelegate
extension MusicPlayerViewController: MusicPlayerViewDelegate {
    
    func last() {
        
    }
    func play() {
        
    }
    func next() {
        
    }
    func download() {
        
    }
}

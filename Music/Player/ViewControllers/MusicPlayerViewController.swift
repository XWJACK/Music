//
//  MusicPlayerViewController.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

final class MusicPlayerViewController<Player: AudioPlayer>: UIViewController, MusicPlayerViewDelegate {
    
    private let musicPlayerView = MusicPlayerView()
    private var player: Player?
//    private let resourcesManager
    
    override func loadView() {
        view = musicPlayerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func last() {
        
    }
    
    func play() {
//        player?.play(with: <#T##AudioPlayerResourcesConvertible#>)
    }
    
    func next() {
        
    }
    
    func download() {
        
    }
}

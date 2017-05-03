//
//  MusicPlayerViewController.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import Wave

final class MusicPlayerViewController: MusicViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: MusicPlayerSlider!
    @IBOutlet weak var durationTimeLabel: UILabel!
    
    @IBOutlet weak var downloadButton: MusicPlayerDownloadButton!
    @IBOutlet weak var loveButton: MusicLoveButton!
    
    @IBOutlet weak var playModeButton: MusicPlayerModeButton!
    @IBOutlet weak var lastButton: UIButton!

    @IBOutlet weak var controlButton: MusicPlayerControlButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    private var player: StreamAudioPlayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadButton.mode = .disable
        controlButton.mode = .paused
        
        lastButton.setImage(#imageLiteral(resourceName: "player_control_last_press"), for: .highlighted)
        nextButton.setImage(#imageLiteral(resourceName: "player_control_next_press"), for: .highlighted)
        
        timeSlider.setThumbImage(#imageLiteral(resourceName: "player_slider"), for: .normal)
        timeSlider.thumbImage(for: .normal)
        timeSlider.setThumbImage(#imageLiteral(resourceName: "player_slider_prs"), for: .highlighted)
        
        listButton.setImage(#imageLiteral(resourceName: "player_control_list_press"), for: .highlighted)
//        addSwipGesture(target: self, action: #selector(left(sender:)), direction: .left)
//        addSwipGesture(target: self, action: #selector(right(sender:)), direction: .right)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    fileprivate func createPlayer() {
        player = StreamAudioPlayer()
        player?.delegate = self
    }
    
    @IBAction func playModeButtonClicked(_ sender: MusicPlayerModeButton) {
        sender.changePlayMode()
    }
    
    
    @IBAction func controlButtonClicked(_ sender: MusicPlayerControlButton) {
        if sender.mode == .paused { sender.mode = .playing }
        else { sender.mode = .paused }
    }
    
    @IBAction func lastButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func timeSliderSeek(_ sender: MusicPlayerSlider) {
        
    }
    
    @IBAction func listButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func loveButtonClicked(_ sender: MusicLoveButton) {
        if sender.mode == .love { sender.mode = .loved }
        else { sender.mode = .love }
    }
    
    @IBAction func downloadButtonClicked(_ sender: MusicPlayerDownloadButton) {
        
    }
}

extension MusicPlayerViewController: StreamAudioPlayerDelegate {
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, parsedDuration duration: TimeInterval) {
        
    }
}

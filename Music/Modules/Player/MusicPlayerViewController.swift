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

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: MusicPlayerSlider!
    @IBOutlet weak var durationTimeLabel: UILabel!
    
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBOutlet weak var cycleButton: UIButton!
    @IBOutlet weak var lastButton: UIButton!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    
    private var player: StreamAudioPlayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loveButton.setImage(#imageLiteral(resourceName: "player_button_love"), for: .normal)
//        loveButton.setImage(#imageLiteral(resourceName: "player_button_love_prs"), for: .highlighted)
        loveButton.setImage(#imageLiteral(resourceName: "player_button_loved"), for: .selected)

        
        downloadButton.setImage(#imageLiteral(resourceName: "player_button_download"), for: .normal)
//        downloadButton.setImage(#imageLiteral(resourceName: "player_button_downloaded_prs"), for: .highlighted)
        downloadButton.setImage(#imageLiteral(resourceName: "player_button_downloaded"), for: .selected)
        
        controlButton.setImage(#imageLiteral(resourceName: "player_button_play"), for: .normal)
        controlButton.setImage(#imageLiteral(resourceName: "player_button_pause"), for: .selected)

        
        timeSlider.setThumbImage(#imageLiteral(resourceName: "player_slider"), for: .normal)
        timeSlider.setThumbImage(#imageLiteral(resourceName: "player_slider_prs"), for: .highlighted)
        
        
        listButton.setImage(#imageLiteral(resourceName: "player_button_list_prs"), for: .highlighted)
//        addSwipGesture(target: self, action: #selector(left(sender:)), direction: .left)
//        addSwipGesture(target: self, action: #selector(right(sender:)), direction: .right)
    }
    
    fileprivate func createPlayer() {
        player = StreamAudioPlayer()
        player?.delegate = self
    }
    
    @IBAction func cycleButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func controlButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func lastButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func timeSliderSeek(_ sender: MusicPlayerSlider) {
        
    }
    
    @IBAction func listButtonClicked(_ sender: UIButton) {
        
    }
}

extension MusicPlayerViewController: StreamAudioPlayerDelegate {
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, parsedDuration duration: TimeInterval) {
        
    }
}

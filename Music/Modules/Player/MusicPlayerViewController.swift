//
//  MusicPlayerViewController.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import Wave
import Kingfisher
import Alamofire

class MusicPlayerViewController: MusicViewController, StreamAudioPlayerDelegate {
    
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
    
    private var isUserInteraction: Bool = false
    private var player: StreamAudioPlayer? = nil
    private var timer: Timer? = nil
    private var resource: MusicPlayerResource? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadButton.mode = .disable
        loveButton.mode = .love
        controlButton.mode = .paused
        
        lastButton.setImage(#imageLiteral(resourceName: "player_control_last_press"), for: .highlighted)
        nextButton.setImage(#imageLiteral(resourceName: "player_control_next_press"), for: .highlighted)
        
        timeSlider.setThumbImage(#imageLiteral(resourceName: "player_slider").scaleToSize(newSize: timeSlider.thumbImageSize), for: .normal)
        timeSlider.thumbImage(for: .normal)
        timeSlider.setThumbImage(#imageLiteral(resourceName: "player_slider_prs").scaleToSize(newSize: timeSlider.thumbImageSize), for: .highlighted)
        timeSlider.isEnabled = false
        
        listButton.setImage(#imageLiteral(resourceName: "player_control_list_press"), for: .highlighted)
//        addSwipGesture(target: self, action: #selector(left(sender:)), direction: .left)
//        addSwipGesture(target: self, action: #selector(right(sender:)), direction: .right)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func play(withResourceID id: String) {
        
        self.resource?.id = id
        
        destory()
        create()

        MusicResourceManager.default.request(id,
                                             response: MusicPlayerResponse(
                                                music: MusicPlayerResponse.Music(response: {
                                                self.player?.respond(with: $0)
                                             }, progress: {
                                                print(String(format: "%d%%", Int($0.fractionCompleted * 100)))
                                             }),
                                                lyric: MusicPlayerResponse.Lyric(success: {
                                                    print($0)
                                                })))
        
        backgroundImageView.kf.setImage(with: resource?.backgroundImageURL,
                                        placeholder: backgroundImageView.image ?? #imageLiteral(resourceName: "backgroundImage"),
                                        options: [.transition(.fade(1))])
        //TODO: 封面图
    }
    
    fileprivate func create() {
        player = StreamAudioPlayer()
        player?.delegate = self
        
        timer = Timer(timeInterval: 0.1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    private func destory() {
        player?.stop()
        timer?.invalidate()
        
        player = nil
        timer = nil
    }
    
    @objc private func refresh() {
        guard !isUserInteraction, let currentTime = player?.currentTime else { return }
        currentTimeLabel.text = currentTime.musicTime
        timeSlider.value = currentTime.float
    }
    
    @IBAction func playModeButtonClicked(_ sender: MusicPlayerModeButton) {
        sender.changePlayMode()
        MusicResourceManager.default.resourceLoadMode = sender.mode
    }
    
    @IBAction func controlButtonClicked(_ sender: MusicPlayerControlButton) {
        if sender.mode == .paused {
            sender.mode = .playing
            player?.play()
        } else {
            sender.mode = .paused
            player?.pause()
        }
    }
    
    @IBAction func lastButtonClicked(_ sender: UIButton) {
//        play(withResource: MusicResourceManager.default.last())
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
//        play(withResource: MusicResourceManager.default.next())
    }
    
    @IBAction func timeSliderSeek(_ sender: MusicPlayerSlider) {
        player?.seek(toTime: TimeInterval(sender.value))
    }
    
    @IBAction func listButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func loveButtonClicked(_ sender: MusicLoveButton) {
        if sender.mode == .love { sender.mode = .loved }
        else { sender.mode = .love }
    }
    
    @IBAction func downloadButtonClicked(_ sender: MusicPlayerDownloadButton) {
        MusicResourceManager.default
    }
    
    //MARK - StreamAudioPlayerDelegate
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, parsedDuration duration: TimeInterval) {
        timeSlider.isEnabled = true
        durationTimeLabel.text = duration.musicTime
    }
}

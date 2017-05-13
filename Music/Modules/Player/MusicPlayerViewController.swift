//
//  MusicPlayerViewController.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

/// Music Player Status
enum MusicPlayerStatus {
    case playing
    case paused
    prefix public static func !(a: MusicPlayerStatus) -> MusicPlayerStatus {
        return a == .playing ? .paused : .playing
    }
}

class MusicPlayerViewController: MusicViewController, AudioPlayerDelegate {
    
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
    private var player: AudioPlayer? = nil
    private var timer: Timer? = nil
    private var resourceId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        musicNavigationBar.titleLabel.font = .font18
        
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
    
    func play(withResourceId id: String) {
        
        self.resourceId = id
        
        reset()

        MusicResourceManager.default.request(id, responseBlock: {
            self.player?.respond(with: $0)
        }, progressBlock: {
            print(String(format: "%d%%", Int($0.fractionCompleted * 100)))
        }, resourceBlock: { (resource) in
            self.title = resource.name
            self.backgroundImageView.kf.setImage(with: resource.picUrl,
                                                 placeholder: self.backgroundImageView.image ?? #imageLiteral(resourceName: "backgroundImage"),
                                                 options: [.forceTransition, .transition(.fade(1))])
            self.downloadButton.mode = .downloaded
        })
    }
    
    private func reset() {
        player?.stop()
        player = nil
        
        destoryTimer()
        
        player = AudioPlayer()
        player?.delegate = self
        
        timer = Timer(timeInterval: 0.1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    private func destoryTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func refresh() {
        guard !isUserInteraction,
            let currentTime = player?.currentTime else { return }
//        if player!.currentTime >= player!.duration { destoryTimer() }
        currentTimeLabel.text = currentTime.musicTime
        timeSlider.value = currentTime.float
    }
    
    @IBAction func playModeButtonClicked(_ sender: MusicPlayerModeButton) {
        sender.changePlayMode()
        MusicResourceManager.default.resourceLoadMode = sender.mode
    }
    
    @IBAction func controlButtonClicked(_ sender: MusicPlayerControlButton) {
        
        guard let player = player else { return }
        
        if sender.mode == .paused { player.play() }
        else { player.pause() }
        sender.mode = !sender.mode
    }
    
    @IBAction func lastButtonClicked(_ sender: UIButton) {
        play(withResourceId: MusicResourceManager.default.last())
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        play(withResourceId: MusicResourceManager.default.next())
    }
    
    @IBAction func timeSliderValueChange(_ sender: MusicPlayerSlider) {
        isUserInteraction = true
        currentTimeLabel.text = TimeInterval(sender.value).musicTime
    }
    
    @IBAction func timeSliderSeek(_ sender: MusicPlayerSlider) {
        isUserInteraction = false
        player?.seek(toTime: TimeInterval(sender.value))
        player?.play()
        controlButton.mode = .playing
    }
    
    @IBAction func listButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func loveButtonClicked(_ sender: MusicLoveButton) {
        guard let id = resourceId else { return }
        MusicNetwork.default.request(MusicAPI.default.like(musicID: id, isLike: sender.mode == .love), success: {
            if $0.isSuccess { sender.mode = !sender.mode }
        })
    }
    
    @IBAction func downloadButtonClicked(_ sender: MusicPlayerDownloadButton) {
        MusicResourceManager.default
    }
    
    //MARK - StreamAudioPlayerDelegate
    
    func streamAudioPlayer(_ player: AudioPlayer, parsedDuration duration: TimeInterval) {
        DispatchQueue.main.async {
            self.timeSlider.isEnabled = true
            self.timeSlider.maximumValue = duration.float
            self.durationTimeLabel.text = duration.musicTime
        }
    }
    
    func didCompletedPlayAudio(_ player: AudioPlayer) {
        nextButtonClicked(nextButton)
    }
}

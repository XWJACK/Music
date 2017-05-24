//
//  MusicPlayerViewController.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import MediaPlayer
import Wave

/// Music Player Status
enum MusicPlayerStatus {
    case playing
    case paused
    prefix public static func !(a: MusicPlayerStatus) -> MusicPlayerStatus {
        return a == .playing ? .paused : .playing
    }
}

class MusicPlayerViewController: MusicViewController, StreamAudioPlayerDelegate {
    
    /// UI
    private let effectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let backgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "background_default_dark-ip5"))
//    private let maskBackgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "player_background_mask-ip5"))
    
    private let displayView: UIView = UIView()
    private let coverView: MusicPlayerCoverView = MusicPlayerCoverView()
    
    private let actionView: UIView = UIView()
    private let downloadButton: MusicPlayerDownloadButton = MusicPlayerDownloadButton(type: .custom)
    private let loveButton: MusicPlayerLoveButton = MusicPlayerLoveButton(type: .custom)
    
    private let progressView: UIView = UIView()
    private let currentTimeLabel: UILabel = UILabel()
    private let timeSlider: MusicPlayerSlider = MusicPlayerSlider()
    private let durationTimeLabel: UILabel = UILabel()
    
    private let controlView: UIView = UIView()
    private let playModeButton: MusicPlayerModeButton = MusicPlayerModeButton(type: .custom)
    private let lastButton: UIButton = UIButton(type: .custom)
    private let controlButton: MusicPlayerControlButton = MusicPlayerControlButton(type: .custom)
    private let nextButton: UIButton = UIButton(type: .custom)
    private let listButton: UIButton = UIButton(type: .custom)
    
    var isHiddenInput: Bool { return resource == nil }
    
    private var isUserInteraction: Bool = false
    private var player: StreamAudioPlayer? = nil
    private var timer: Timer? = nil
    private var resource: MusicResource? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        currentTimeLabel.text = "00:00"
        durationTimeLabel.text = "00:00"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        musicNavigationBar.titleLabel.font = .font18
        
        //        addSwipGesture(target: self, action: #selector(left(sender:)), direction: .left)
        //        addSwipGesture(target: self, action: #selector(right(sender:)), direction: .right)
        
        view.addSubview(backgroundImageView)
        view.addSubview(effectView)
        
        super.viewDidLoad()
        
        displayView.addSubview(coverView)
        
        actionView.addSubview(loveButton)
        actionView.addSubview(downloadButton)
        
        progressView.addSubview(currentTimeLabel)
        progressView.addSubview(durationTimeLabel)
        progressView.addSubview(timeSlider)
        
        controlView.addSubview(playModeButton)
        controlView.addSubview(listButton)
        controlView.addSubview(lastButton)
        controlView.addSubview(controlButton)
        controlView.addSubview(nextButton)
        
//        effectView.addSubview(maskBackgroundImageView)
        effectView.addSubview(displayView)
        effectView.addSubview(actionView)
        effectView.addSubview(progressView)
        effectView.addSubview(controlView)
        
        
        // - Background View
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        effectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
//        maskBackgroundImageView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
        // - Display View
        
        displayView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(90)
        }
        coverView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(225)
        }
        // - Action View
        
        loveButton.mode = .disable
        loveButton.addTarget(self, action: #selector(loveButtonClicked(_:)), for: .touchUpInside)
        
        downloadButton.addTarget(self, action: #selector(downloadButtonClicked(_:)), for: .touchUpInside)
        
        actionView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.left.right.equalToSuperview()
            make.top.equalTo(displayView.snp.bottom)
        }
        loveButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        downloadButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        // - Progress View
        
        currentTimeLabel.font = .font10
        currentTimeLabel.textColor = .white
        
        timeSlider.isEnabled = false
        timeSlider.minimumTrackTintColor = .white
        timeSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.1)
        timeSlider.setThumbImage(#imageLiteral(resourceName: "player_slider").scaleToSize(newSize: timeSlider.thumbImageSize), for: .normal)
        timeSlider.setThumbImage(#imageLiteral(resourceName: "player_slider_prs").scaleToSize(newSize: timeSlider.thumbImageSize), for: .highlighted)
        timeSlider.addTarget(self, action: #selector(timeSliderSeek(_:)), for: .touchUpInside)
        timeSlider.addTarget(self, action: #selector(timeSliderSeek(_:)), for: .touchUpOutside)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChange(_:)), for: .valueChanged)
        
        durationTimeLabel.font = .font10
        durationTimeLabel.textColor = .white
        
        progressView.snp.makeConstraints { (make) in
            make.height.equalTo(36)
            make.left.right.equalToSuperview()
            make.top.equalTo(actionView.snp.bottom)
        }
        currentTimeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
        durationTimeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        timeSlider.snp.makeConstraints { (make) in
            make.left.equalTo(55)
            make.right.equalTo(-55)
            make.centerY.equalToSuperview()
        }
        
        // - Control View
        
        controlButton.mode = .paused
        controlButton.addTarget(self, action: #selector(controlButtonClicked(_:)), for: .touchUpInside)
        
        playModeButton.setImage(#imageLiteral(resourceName: "player_control_model_order"), for: .normal)
        playModeButton.setImage(#imageLiteral(resourceName: "player_control_model_order_highlighted"), for: .highlighted)
        playModeButton.addTarget(self, action: #selector(playModeButtonClicked(_:)), for: .touchUpInside)
        
        lastButton.setImage(#imageLiteral(resourceName: "player_control_last"), for: .normal)
        lastButton.setImage(#imageLiteral(resourceName: "player_control_last_press"), for: .highlighted)
        lastButton.addTarget(self, action: #selector(lastButtonClicked(_:)), for: .touchUpInside)
        
        nextButton.setImage(#imageLiteral(resourceName: "player_control_next"), for: .normal)
        nextButton.setImage(#imageLiteral(resourceName: "player_control_next_press"), for: .highlighted)
        nextButton.addTarget(self, action: #selector(nextButtonClicked(_:)), for: .touchUpInside)
        
        listButton.setImage(#imageLiteral(resourceName: "player_control_list"), for: .normal)
        listButton.setImage(#imageLiteral(resourceName: "player_control_list_press"), for: .highlighted)
        listButton.addTarget(self, action: #selector(listButtonClicked(_:)), for: .touchUpInside)
        
        controlView.snp.makeConstraints { (make) in
            make.height.equalTo(54)
            make.left.right.equalToSuperview()
            make.top.equalTo(progressView.snp.bottom)
            make.bottom.equalToSuperview().offset(-20)
        }
        controlButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(54)
            make.center.equalToSuperview()
        }
        lastButton.snp.makeConstraints { (make) in
            make.right.equalTo(controlButton.snp.left).offset(-15)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        nextButton.snp.makeConstraints { (make) in
            make.left.equalTo(controlButton.snp.right).offset(15)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        playModeButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(50)
            make.centerY.equalToSuperview()
        }
        listButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(50)
            make.centerY.equalToSuperview()
        }
    }
    
    func playResource(_ resource: MusicResource = MusicResourceManager.default.current()) {
        
        reset()

        self.resource = resource
        
        title = resource.name
        backgroundImageView.kf.setImage(with: resource.album?.picUrl,
                                        placeholder: backgroundImageView.image ?? #imageLiteral(resourceName: "background_default_dark-ip5"),
                                        options: [.forceTransition,
                                                  .transition(.fade(1))])
        
        let rawDuration = resource.duration / 1000
        durationTimeLabel.text = rawDuration.musicTime
        timeSlider.maximumValue = rawDuration.float
        
        coverView.setImage(url: resource.album?.picUrl)
        downloadButton.mode = resource.resourceSource == .download ? .downloaded : .download
        controlButton.mode = .paused
        
        MusicResourceManager.default.register(resource.id, responseBlock: {
            self.player?.respond(with: $0)
        })
    }
    
    func playCommand() {
        player?.play()
        controlButton.mode = .paused
    }
    
    func pauseCommand() {
        player?.pause()
        controlButton.mode = .playing
    }
    
    func nextTrack() {
        nextButtonClicked(nextButton)
    }
    
    func lastTrack() {
        lastButtonClicked(lastButton)
    }
    
    private func reset() {
        player?.stop()
        player = nil
        
        destoryTimer()
        
        player = StreamAudioPlayer()
        player?.delegate = self
        
        createTimer()
        
        timeSlider.isEnabled = false
        timeSlider.resetProgress()
        dismissBuffingStatus()
        
        MusicResourceManager.default.unRegister(resource?.id ?? "No Resource")
    }
    
    private func createTimer() {
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
        currentTimeLabel.text = currentTime.musicTime
        timeSlider.value = currentTime.float
        updateRemoteControl(currentTime)
    }
    
    private func updateRemoteControl(_ time: TimeInterval) {
        var info: [String: Any] = [:]
        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: backgroundImageView.image ?? #imageLiteral(resourceName: "background_default_dark"))
        info[MPMediaItemPropertyTitle] = resource?.name ?? ""
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        info[MPMediaItemPropertyPlaybackDuration] = (resource?.duration ?? 0) / 1000
            
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func post(status: MusicPlayerStatus) {
        NotificationCenter.default.post(name: .playStatusChange, object: nil, userInfo: ["Status": status])
    }
    
    private func showBuffingStatus() {
        player?.pause()
        timeSlider.loading(true)
    }
    
    private func dismissBuffingStatus() {
        timeSlider.loading(false)
    }
    
    //MARK: - Progress Target
    
    @objc private func timeSliderValueChange(_ sender: MusicPlayerSlider) {
        isUserInteraction = true
        currentTimeLabel.text = TimeInterval(sender.value).musicTime
    }
    
    @objc private func timeSliderSeek(_ sender: MusicPlayerSlider) {
        isUserInteraction = false
        if player?.seek(toTime: TimeInterval(sender.value)) == true {
            player?.play()
            controlButton.mode = .paused
        } else {
            showBuffingStatus()
            ConsoleLog.verbose("timeSliderSeek to time: " + "\(sender.value)" + " but need to watting")
        }
    }
    
    //MARK: - Action Target
    
    @objc private func loveButtonClicked(_ sender: MusicPlayerLoveButton) {
//        guard let id = resourceId else { return }
//        MusicNetwork.default.request(API.default.like(musicID: id, isLike: sender.mode == .love), success: {
//            if $0.isSuccess { sender.mode = !sender.mode }
//        })
    }
    
    @objc private func downloadButtonClicked(_ sender: MusicPlayerDownloadButton) {
        switch sender.mode {
        case .download:
            guard let resource = resource else { return }
            MusicResourceManager.default.download(resource, successBlock: {
                DispatchQueue.main.async {
                    self.downloadButton.mode = .downloaded
                }
            })
        case .downloaded:
            let controller = UIAlertController(title: "Delete this Music?", message: nil, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                guard let resource = self.resource else { return }
                DispatchQueue.global().async {
                    MusicResourceManager.default.delete(resource)
                    DispatchQueue.main.async {
                        sender.mode = .download
                        self.view.makeToast("Delete Music Successful")
                    }
                }
            }))
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(controller, animated: true, completion: nil)
        default: break
        }
    }
    
    //MARK: - Control Target
    
    @objc private func playModeButtonClicked(_ sender: MusicPlayerModeButton) {
        sender.changePlayMode()
        MusicResourceManager.default.resourceLoadMode = sender.mode
    }
    
    @objc private func controlButtonClicked(_ sender: MusicPlayerControlButton) {
        if sender.mode == .playing { playCommand() }
        else { pauseCommand() }
    }
    
    @objc private func lastButtonClicked(_ sender: UIButton) {
        playResource(MusicResourceManager.default.last())
    }
    
    @objc private func nextButtonClicked(_ sender: UIButton) {
        playResource(MusicResourceManager.default.next())
    }
    
    @objc private func listButtonClicked(_ sender: UIButton) {
        
    }
    
    //MARK: - StreamAudioPlayerDelegate
    
    func streamAudioPlayerCompletedParsedAudioInfo(_ player: StreamAudioPlayer) {
        ConsoleLog.verbose("streamAudioPlayerCompletedParsedAudioInfo")
        DispatchQueue.main.async {
            self.timeSlider.isEnabled = true
        }
    }
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, didCompletedPlayFromTime time: TimeInterval) {
        ConsoleLog.verbose("didCompletedSeekToTime: " + "\(time)")
        DispatchQueue.main.async {
            self.dismissBuffingStatus()
            guard self.controlButton.mode == .paused else { return }
            self.player?.play()
        }
    }
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, didCompletedPlayAudio isEnd: Bool) {
        DispatchQueue.main.async {
            if isEnd {
                self.nextTrack()
            } else {
                self.showBuffingStatus()
            }
        }
    }
    
//    func streamAudioPlayer(_ player: StreamAudioPlayer, queueStatusChange status: AudioQueueStatus) {
//        DispatchQueue.main.async {
//            switch status {
//            case .playing: self.controlButton.mode = .paused
//            case .paused: self.controlButton.mode = .playing
//            case .stop: self.controlButton.mode = .playing
//            }
//        }
//    }
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, parsedProgress progress: Progress) {
        DispatchQueue.main.async {
            self.timeSlider.buffProgress(progress)
            if progress.fractionCompleted > 0.01 && self.controlButton.mode == .paused {
                self.player?.play()
            }
        }
    }
    
//    func streamAudioPlayer(_ player: StreamAudioPlayer, anErrorOccur error: WaveError) {
//        ConsoleLog.error(error)
//    }
}

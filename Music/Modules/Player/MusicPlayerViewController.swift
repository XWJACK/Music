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

class MusicPlayerViewController: MusicViewController {
    
    //MARK: - UI property
    
    //MARK: - Base View
    
    fileprivate let backgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "background_default_dark-ip5"))
    fileprivate let effectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    fileprivate let maskBackgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "player_background_mask-ip5"))
    fileprivate let mainView: UIView = UIView()
    
    //MARK: - Display View
    
    fileprivate let displayView: UIView = UIView()
    fileprivate let coverView: MusicPlayerCoverView = MusicPlayerCoverView()
    
    //MARK: - Action View
    
    fileprivate let actionView: UIView = UIView()
    fileprivate let downloadButton: MusicPlayerDownloadButton = MusicPlayerDownloadButton(type: .custom)
    fileprivate let loveButton: MusicPlayerLoveButton = MusicPlayerLoveButton(type: .custom)
    fileprivate let lyricTableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    //MARK: - Progress View
    
    fileprivate let progressView: UIView = UIView()
    fileprivate let currentTimeLabel: UILabel = UILabel()
    fileprivate let timeSlider: MusicPlayerSlider = MusicPlayerSlider()
    fileprivate let durationTimeLabel: UILabel = UILabel()
    
    //MARK: - Control View
    
    fileprivate let controlView: UIView = UIView()
    fileprivate let playModeButton: MusicPlayerModeButton = MusicPlayerModeButton(type: .custom)
    fileprivate let lastButton: UIButton = UIButton(type: .custom)
    fileprivate let controlButton: MusicPlayerControlButton = MusicPlayerControlButton(type: .custom)
    fileprivate let nextButton: UIButton = UIButton(type: .custom)
    fileprivate let listButton: UIButton = UIButton(type: .custom)
    
    //MARK: - Other property
    
    fileprivate var isUserInteraction: Bool = false
    fileprivate var player: StreamAudioPlayer? = nil
    fileprivate var timer: Timer? = nil
    fileprivate var resource: MusicResource? = nil
    fileprivate var isBuffering: Bool = false
    
    fileprivate var lyricParser: LyricParser?
    fileprivate var lyricCellHeight: CGFloat = 26
    fileprivate var lyricInsert: CGFloat = 12//(actionViewHeight - lyricCellHeight) / 2
    fileprivate var lastLyricIndex: Int = 0
    
    var isHiddenInput: Bool { return resource == nil }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        currentTimeLabel.text = "00:00"
        durationTimeLabel.text = "00:00"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        view.backgroundColor = .clear
        musicNavigationBar.titleLabel.font = .font18
        mainView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        displayView.addSubview(coverView)
        
        actionView.addSubview(loveButton)
        actionView.addSubview(downloadButton)
        actionView.addSubview(lyricTableView)
        
        progressView.addSubview(currentTimeLabel)
        progressView.addSubview(durationTimeLabel)
        progressView.addSubview(timeSlider)
        
        controlView.addSubview(playModeButton)
        controlView.addSubview(listButton)
        controlView.addSubview(lastButton)
        controlView.addSubview(controlButton)
        controlView.addSubview(nextButton)
        
        mainView.addSubview(maskBackgroundImageView)
        mainView.addSubview(displayView)
        mainView.addSubview(actionView)
        mainView.addSubview(progressView)
        mainView.addSubview(controlView)
        
        view.addSubview(backgroundImageView)
        view.addSubview(effectView)
        view.addSubview(mainView)
        
        super.viewDidLoad()
        
        // - Base View
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        effectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        maskBackgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // - Display View
        
        displayView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(88)
        }
        coverView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(234)
        }
        // - Action View
        
        loveButton.mode = .disable
        loveButton.addTarget(self, action: #selector(loveButtonClicked(_:)), for: .touchUpInside)
        
        downloadButton.addTarget(self, action: #selector(downloadButtonClicked(_:)), for: .touchUpInside)
        
        lyricTableView.backgroundColor = .clear
        lyricTableView.separatorStyle = .none
        lyricTableView.contentInset = UIEdgeInsets(top: lyricInsert, left: 0, bottom: lyricInsert, right: 0)
        lyricTableView.delegate = self
        lyricTableView.dataSource = self
        lyricTableView.showsVerticalScrollIndicator = false
        lyricTableView.showsHorizontalScrollIndicator = false
        lyricTableView.register(MusicLyricTableViewCell.self, forCellReuseIdentifier: MusicLyricTableViewCell.reuseIdentifier)
        
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
        lyricTableView.snp.makeConstraints { (make) in
            make.left.equalTo(loveButton.snp.right).offset(15)
            make.right.equalTo(downloadButton.snp.left).offset(-15)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
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
        
        MusicResourceManager.default.register(resource.id, responseBlock: { self.player?.respond(with: $0) }, lyricBlock: { (model) in
            if let lyric = model?.lyric {
                DispatchManager.default.playerQueue.async {
                    self.lyricParser = LyricParser(lyric)
                    DispatchManager.default.main.async {
                        self.lyricTableView.reloadData()
                    }
                }
            } else {
                DispatchManager.default.main.async {
                    self.lyricParser = nil
                    self.lyricTableView.reloadData()
                }
            }
        }, failedBlock: networkBusy)
    }
    
    //MARK: - Control
    
    func playCommand() {
        if !isBuffering { player?.play() }
        controlButton.mode = .paused
    }
    
    func pauseCommand() {
        player?.pause()
        controlButton.mode = .playing
    }
    
    func lastTrack() {
        playResource(MusicResourceManager.default.last())
    }
    
    func nextTrack() {
        playResource(MusicResourceManager.default.next())
    }
    
    //MARK: - Reset
    
    fileprivate func reset() {
        player?.stop()
        player = nil
        
        destoryTimer()
        
        player = StreamAudioPlayer()
        player?.delegate = self
        
        timeSlider.isEnabled = false
        timeSlider.resetProgress()
        dismissBuffingStatus()
        
        MusicResourceManager.default.unRegister(resource?.id ?? "No Resource")
        
        createTimer()
    }
    
    //MARK: - Timer
    
    fileprivate func createTimer() {
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    fileprivate func destoryTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: - Refresh
    
    @objc fileprivate func refresh() {
        guard !isUserInteraction,
            let currentTime = player?.currentTime else { return }
        currentTimeLabel.text = currentTime.musicTime
        timeSlider.value = currentTime.float
        self.updateLyric(currentTime)
        DispatchManager.default.playerQueue.async {
            self.updateRemoteControl(currentTime)
        }
    }
    
    fileprivate func updateLyric(_ time: TimeInterval) {
        guard let lyricParser = lyricParser else { return }
        
        /// 0..<lyricParser.timeLyric.count
        let index: Int = (lyricParser.timeLyric.index(where: { $0.time > time }) ?? lyricParser.timeLyric.count) - 1
        let offSet: CGFloat = CGFloat(index) * lyricCellHeight - lyricInsert
        
        if let cell = self.lyricTableView.cellForRow(at: IndexPath(row: self.lastLyricIndex, section: 0)) as? MusicLyricTableViewCell {
            cell.normal()
        }
        if let cell = lyricTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? MusicLyricTableViewCell {
            cell.heightLight()
        }
        lastLyricIndex = index
        
        guard !lyricTableView.isDragging else { return }
        self.lyricTableView.setContentOffset(CGPoint(x: 0, y: offSet), animated: true)
    }
    
    fileprivate func updateRemoteControl(_ time: TimeInterval) {
        var info: [String: Any] = [:]
        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: backgroundImageView.image ?? #imageLiteral(resourceName: "background_default_dark"))
        info[MPMediaItemPropertyTitle] = resource?.name ?? ""
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        info[MPMediaItemPropertyPlaybackDuration] = (resource?.duration ?? 0) / 1000
            
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    fileprivate func post(status: MusicPlayerStatus) {
        NotificationCenter.default.post(name: .playStatusChange, object: nil, userInfo: ["Status": status])
    }
    
    //MARK: - Buffing Status
    
    fileprivate func showBuffingStatus() {
        player?.pause()
        timeSlider.loading(true)
        isBuffering = true
    }
    
    fileprivate func dismissBuffingStatus() {
        timeSlider.loading(false)
        isBuffering = false
    }
}

//MARK: - Progress Target
extension MusicPlayerViewController {
    
    @objc fileprivate func timeSliderValueChange(_ sender: MusicPlayerSlider) {
        isUserInteraction = true
        currentTimeLabel.text = TimeInterval(sender.value).musicTime
    }
    
    @objc fileprivate func timeSliderSeek(_ sender: MusicPlayerSlider) {
        isUserInteraction = false
        if player?.seek(toTime: TimeInterval(sender.value)) == true {
            playCommand()
        } else {
            showBuffingStatus()
            ConsoleLog.verbose("timeSliderSeek to time: " + "\(sender.value)" + " but need to watting")
        }
    }
}

//MARK: - Action Target
extension MusicPlayerViewController {
    
    @objc fileprivate func loveButtonClicked(_ sender: MusicPlayerLoveButton) {
//        guard let id = resource?.id else { return }
//        MusicNetwork.send(API.like(musicID: id, isLike: sender.mode == .love))
//            .receive(json: { if $0.isSuccess { sender.mode = !sender.mode } })
    }
    
    @objc fileprivate func downloadButtonClicked(_ sender: MusicPlayerDownloadButton) {
        switch sender.mode {
        case .download:
            guard let resource = resource else { return }
            sender.mode = .disable
            MusicResourceManager.default.download(resource, successBlock: {
                DispatchManager.default.main.async {
                    self.downloadButton.mode = .downloaded
                }
            })
        case .downloaded:
            let controller = UIAlertController(title: "Delete this Music?", message: nil, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                guard let resource = self.resource else { return }
                DispatchManager.default.resourceQueue.async {
                    MusicResourceManager.default.delete(resource)
                    DispatchManager.default.main.async {
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
}

//MARK: - Control Target
extension MusicPlayerViewController {
    
    @objc fileprivate func playModeButtonClicked(_ sender: MusicPlayerModeButton) {
        sender.changePlayMode()
        MusicResourceManager.default.resourceLoadMode = sender.mode
    }
    
    @objc fileprivate func controlButtonClicked(_ sender: MusicPlayerControlButton) {
        if sender.mode == .playing { playCommand() }
        else { pauseCommand() }
    }
    
    @objc fileprivate func lastButtonClicked(_ sender: UIButton) {
        lastTrack()
    }
    
    @objc fileprivate func nextButtonClicked(_ sender: UIButton) {
        nextTrack()
    }
    
    @objc fileprivate func listButtonClicked(_ sender: UIButton) {
        
    }
}

//MARK: - StreamAudioPlayerDelegate
extension MusicPlayerViewController: StreamAudioPlayerDelegate {
    
    func streamAudioPlayerCompletedParsedAudioInfo(_ player: StreamAudioPlayer) {
        ConsoleLog.verbose("streamAudioPlayerCompletedParsedAudioInfo")
        DispatchManager.default.main.async {
            self.timeSlider.isEnabled = true
        }
    }
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, didCompletedPlayFromTime time: TimeInterval) {
        ConsoleLog.verbose("didCompletedSeekToTime: " + "\(time)")
        DispatchManager.default.main.async {
            self.dismissBuffingStatus()
            guard self.controlButton.mode == .paused else { return }
            self.playCommand()
        }
    }
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, didCompletedPlayAudio isEnd: Bool) {
        DispatchManager.default.main.async {
            if isEnd {
                self.nextTrack()
            } else {
                self.showBuffingStatus()
            }
        }
    }
    
    func streamAudioPlayer(_ player: StreamAudioPlayer, parsedProgress progress: Progress) {
        DispatchManager.default.main.async {
            self.timeSlider.buffProgress(progress)
        }
    }
}

// MARK: - UITableViewDelegate
extension MusicPlayerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return lyricCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

// MARK: - UITableViewDataSource
extension MusicPlayerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyricParser?.timeLyric.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MusicLyricTableViewCell.reuseIdentifier, for: indexPath) as? MusicLyricTableViewCell else { return MusicLyricTableViewCell() }
        cell.indexPath = indexPath
        cell.normal(lyric: lyricParser?.timeLyric[indexPath.row].lyric ?? "No Lyric")
        return cell
    }
}

//
//  MusicPlayerView.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol MusicPlayerViewDelegate: MusicPlayerDisplayViewDelegate, MusicPlayerActionViewDelegate, MusicPlayerControlViewDelegate {
}

/// Music Player View
final class MusicPlayerView: UIView {
    
    weak var delegate: MusicPlayerViewDelegate? {
        didSet {
            displayView.delegate = delegate
            actionView.delegate = delegate
            controlView.delegate = delegate
        }
    }
    
    private let backgroundImage = UIImageView()
    private var effectView: UIVisualEffectView?
    private let displayView = MusicPlayerDisplayView(frame: .zero)
    private let actionView = MusicPlayerActionView(frame: .zero)
    private let controlView = MusicPlayerControlView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundImage.contentMode = .scaleAspectFill
        effectView = addBlurEffect(style: .light)
        
        addSubview(backgroundImage)
        addSubview(displayView)
        addSubview(actionView)
        addSubview(controlView)
        
        displayView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
        }
        actionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(displayView.snp.bottom)
            make.height.equalTo(56)
        }
        controlView.snp.makeConstraints { (make) in
            make.top.equalTo(actionView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        effectView?.frame.size = frame.size
        backgroundImage.frame.size = frame.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Display

/// Delegate for Music Player Display
@objc protocol MusicPlayerDisplayViewDelegate {
    
    @objc func leftSwipe(sender: UISwipeGestureRecognizer)
    ///  play next music
    @objc func rightSwipe(sender: UISwipeGestureRecognizer)
}

/// Music Player Display View
private final class MusicPlayerDisplayView: UIView, Gesture {
    
    weak var delegate: MusicPlayerDisplayViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSwipGesture(target: self, action: #selector(left(sender:)), direction: .left)
        addSwipGesture(target: self, action: #selector(right(sender:)), direction: .right)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func left(sender: UISwipeGestureRecognizer) {
        delegate?.leftSwipe(sender: sender)
    }
    
    @objc private func right(sender: UISwipeGestureRecognizer) {
        delegate?.rightSwipe(sender: sender)
    }
}

//MARK: - Action

/// Delegate for Music Player Action
@objc protocol MusicPlayerActionViewDelegate {
    
    /// Loved button clicked
    @objc func lovedClicked(sender: UIButton)
    
    /// Download button clicked
    @objc func downloadClicked(sender: UIButton)
}

/// Music Player Action View
private final class MusicPlayerActionView: UIView {
    
    weak var delegate: MusicPlayerActionViewDelegate?
    
    private let loveButton      = UIButton(type: .custom)
    private let downloadButton  = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loveButton.setImage(#imageLiteral(resourceName: "player_button_love"), for: .normal)
        loveButton.setImage(#imageLiteral(resourceName: "player_button_loved"), for: .selected)
        loveButton.addTarget(self, action: #selector(lovedClicked(sender:)), for: .touchUpInside)
        
        downloadButton.setImage(#imageLiteral(resourceName: "player_button_download"), for: .normal)
        downloadButton.setImage(#imageLiteral(resourceName: "player_button_downloaded"), for: .selected)
        downloadButton.addTarget(self, action: #selector(downloadClicked(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func lovedClicked(sender: UIButton) {
        
    }
    
    @objc private func downloadClicked(sender: UIButton) {
        delegate?.downloadClicked(sender: sender)
    }
}

//MARK: - Control

/// Delegate for Music Player Control
@objc protocol MusicPlayerControlViewDelegate {
    
    /// play last music
    @objc func lastButtonClicked(sender: UIButton)
    /// play or puse music
    @objc func playButtonClicked(sender: UIButton)
    ///  play next music
    @objc func nextButtonClicked(sender: UIButton)
}

/// Music Player Control View
private final class MusicPlayerControlView: UIView {
    
    weak var delegate: MusicPlayerControlViewDelegate?
    
    private let lastButton = UIButton(type: .custom)
    private let playButton = UIButton(type: .custom)
    private let nextButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lastButton.setImage(#imageLiteral(resourceName: "player_button_last"), for: .normal)
        lastButton.addTarget(self, action: #selector(lastButtonClicked(sender:)), for: .touchUpInside)
        
        playButton.setImage(#imageLiteral(resourceName: "player_button_play"), for: .normal)
        playButton.setImage(#imageLiteral(resourceName: "player_button_pause"), for: .selected)
        playButton.addTarget(self, action: #selector(playButtonClicked(sender:)), for: .touchUpInside)
        
        nextButton.setImage(#imageLiteral(resourceName: "player_button_next"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonClicked(sender:)), for: .touchUpInside)
        
        addSubview(lastButton)
        addSubview(playButton)
        addSubview(nextButton)
        
        lastButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.right.equalTo(playButton.snp.left).offset(-20)
        }
        playButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.height.equalTo(80)
            make.center.equalToSuperview()
        }
        nextButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.left.equalTo(playButton.snp.right).offset(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func lastButtonClicked(sender: UIButton) {
        delegate?.lastButtonClicked(sender: sender)
    }
    @objc private func playButtonClicked(sender: UIButton) {
        delegate?.playButtonClicked(sender: sender)
    }
    @objc private func nextButtonClicked(sender: UIButton) {
        delegate?.nextButtonClicked(sender: sender)
    }
}

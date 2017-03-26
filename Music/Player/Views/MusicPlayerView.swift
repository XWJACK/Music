//
//  MusicPlayerView.swift
//  Music
//
//  Created by Jack on 3/16/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

@objc protocol MusicPlayerViewDelegate: MusicPlayerDisplayViewDelegate, MusicPlayerActionViewDelegate, MusicPlayerControlViewDelegate {
    
}

/// Music Player View
final class MusicPlayerView: UIView, BlurEffect {
    
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
        
        addSubview(backgroundImage)
        effectView = addBlur(style: .light)
        addSubview(displayView)
        addSubview(actionView)
        addSubview(controlView)
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
    /// play last music
    @objc func last()
    ///  play next music
    @objc func next()
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
        delegate?.last()
    }
    
    @objc private func right(sender: UISwipeGestureRecognizer) {
        delegate?.next()
    }
}

//MARK: - Action

/// Delegate for Music Player Action
@objc protocol MusicPlayerActionViewDelegate {
    
    /// Loved button clicked
    @objc func loved()
    /// Download button clicked
    @objc func download()
}

/// Music Player Action View
private final class MusicPlayerActionView: UIView {
    
    weak var delegate: MusicPlayerActionViewDelegate?
    
    private let loveButton      = LovedButton()
    private let downloadButton  = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loveButton.normalSources    = LovedButton.Bit(normalImage: #imageLiteral(resourceName: "player_button_love"),
                                                      heightImage: #imageLiteral(resourceName: "player_button_love_press"))
        loveButton.lovedSources     = LovedButton.Bit(normalImage: #imageLiteral(resourceName: "player_button_loved"),
                                                      heightImage: #imageLiteral(resourceName: "player_button_loved_press"))
        loveButton.addTarget(self, action: #selector(loved), for: .touchUpInside)
        
        downloadButton.addTarget(self, action: #selector(download), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func loved() {
        
    }
    @objc private func download() {
        delegate?.download()
    }
}

//MARK: - Control

/// Delegate for Music Player Control
@objc protocol MusicPlayerControlViewDelegate {
    
    /// play last music
    @objc func last()
    /// play or puse music
    @objc func play()
    ///  play next music
    @objc func next()
}

/// Music Player Control View
private final class MusicPlayerControlView: UIView {
    
    weak var delegate: MusicPlayerControlViewDelegate?
    
    private let lastButton = UIButton(type: .custom)
    private let playButton = PlayButton()
    private let nextButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lastButton.setImage(#imageLiteral(resourceName: "player_button_last"), for: .normal)
        lastButton.setImage(#imageLiteral(resourceName: "player_button_last_press"), for: .highlighted)
        lastButton.addTarget(self, action: #selector(last), for: .touchUpInside)
        
        
        playButton.playSources  = MusicPlayerButton.Bit(normalImage: #imageLiteral(resourceName: "player_button_play"),
                                                        heightImage: #imageLiteral(resourceName: "player_button_play_press"))
        playButton.pauseSources = MusicPlayerButton.Bit(normalImage: #imageLiteral(resourceName: "player_button_pause"),
                                                        heightImage: #imageLiteral(resourceName: "player_button_pause_press"))
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        
        
        nextButton.setImage(#imageLiteral(resourceName: "player_button_next"), for: .normal)
        nextButton.setImage(#imageLiteral(resourceName: "player_button_next_press"), for: .highlighted)
        nextButton.addTarget(self, action: #selector(next(sender:)), for: .touchUpInside)
        
        addSubview(lastButton)
        addSubview(playButton)
        addSubview(nextButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth = frame.size.width / 3
        let buttonHeight = frame.size.height
        
        lastButton.frame = CGRect(x: 0,                 y: 0, width: buttonWidth, height: buttonHeight)
        playButton.frame = CGRect(x: buttonWidth,       y: 0, width: buttonWidth, height: buttonHeight)
        nextButton.frame = CGRect(x: buttonWidth * 2,   y: 0, width: buttonWidth, height: buttonHeight)
    }
    
    @objc private func last() {
        delegate?.last()
    }
    @objc private func play() {
        delegate?.play()
    }
    @objc private func next(sender: UIButton) {
        delegate?.next()
    }
}

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
        effectView = addBlur()
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
    @objc func download()
}

/// Music Player Action View
private final class MusicPlayerActionView: UIView {
    
    weak var delegate: MusicPlayerActionViewDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            downloadButton.addTarget(delegate, action: #selector(delegate.download), for: .touchUpInside)
        }
    }
    
    private let downloadButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    weak var delegate: MusicPlayerControlViewDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            lastButton.addTarget(delegate, action: #selector(delegate.last), for: .touchUpInside)
            playButton.addTarget(delegate, action: #selector(delegate.play), for: .touchUpInside)
            nextButton.addTarget(delegate, action: #selector(delegate.next), for: .touchUpInside)
        }
    }
    private let lastButton = UIButton(type: .custom)
    private let playButton = UIButton(type: .custom)
    private let nextButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(lastButton)
        addSubview(playButton)
        addSubview(nextButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

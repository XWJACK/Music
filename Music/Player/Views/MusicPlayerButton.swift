//
//  MusicPlayerButton.swift
//  Music
//
//  Created by Jack on 3/26/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicPlayerButton: UIButton {
    
    struct Bit {
        var normalImage: UIImage
        var heightImage: UIImage
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Loved Button for Music Player
final class LovedButton: MusicPlayerButton {
    
    var normalSources: Bit?
    var lovedSources: Bit?
    
    var status: LovedStatus = .normal {
        didSet {
            switch status {
            case .normal:
                setImage(normalSources?.normalImage, for: .normal)
                setImage(normalSources?.heightImage, for: .highlighted)
            case .loved:
                setImage(lovedSources?.normalImage, for: .normal)
                setImage(lovedSources?.heightImage, for: .highlighted)
            }
        }
    }
}

/// Play Button for Music Player
final class PlayButton: MusicPlayerButton {
    
    var playSources: Bit?
    var pauseSources: Bit?
    
    var status: PlayerStatus = .paused {
        didSet {
            switch status {
            case .playing:
                setImage(playSources?.normalImage, for: .normal)
                setImage(playSources?.heightImage, for: .highlighted)
            case .paused:
                setImage(pauseSources?.normalImage, for: .normal)
                setImage(pauseSources?.heightImage, for: .highlighted)
            }
        }
    }
}

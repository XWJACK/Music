//
//  MusicPlayerControlButton.swift
//  Music
//
//  Created by Jack on 4/30/17.
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

class MusicPlayerControlButton: UIButton {

    var mode: MusicPlayerStatus = .paused {
        didSet {
            changeMode()
        }
    }
    
    private func changeMode() {
        switch mode {
        case .playing:
            setImage(#imageLiteral(resourceName: "player_control_play"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_play_press"), for: .highlighted)
        case .paused:
            setImage(#imageLiteral(resourceName: "player_control_pause"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_pause_press"), for: .highlighted)
        }
    }
    
}

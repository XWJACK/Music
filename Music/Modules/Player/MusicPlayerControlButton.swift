//
//  MusicPlayerControlButton.swift
//  Music
//
//  Created by Jack on 4/30/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicPlayerControlButton: UIButton {

    var mode: MusicPlayerStatus = .paused {
        didSet {
            changeMode()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func changeMode() {
        switch mode {
        case .playing:
            setImage(#imageLiteral(resourceName: "player_control_pause"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_pause_press"), for: .highlighted)
        case .paused:
            setImage(#imageLiteral(resourceName: "player_control_play"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_play_press"), for: .highlighted)
            
        }
    }
    
}

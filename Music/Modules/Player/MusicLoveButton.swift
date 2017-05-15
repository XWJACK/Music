//
//  MusicLoveButton.swift
//  Music
//
//  Created by Jack on 5/3/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

/// Music Player Love Mode
enum MusicPlayerLoveMode {
    case love
    case loved
    case disable
    prefix public static func !(a: MusicPlayerLoveMode) -> MusicPlayerLoveMode {
        return a == .love ? .loved : .love
    }
}

class MusicLoveButton: UIButton {

    var mode: MusicPlayerLoveMode = .love {
        didSet {
            switch mode {
            case .love:
                setImage(#imageLiteral(resourceName: "player_control_love"), for: .normal)
                setImage(#imageLiteral(resourceName: "player_control_love_press"), for: .highlighted)
            case .loved:
                setImage(#imageLiteral(resourceName: "player_control_loved"), for: .normal)
                setImage(#imageLiteral(resourceName: "player_control_loved_press"), for: .highlighted)
            case .disable:
                setImage(#imageLiteral(resourceName: "player_control_love_dis"), for: .disabled)
                isEnabled = false
            }
        }
    }
}

//
//  MusicPlayerDownloadButton.swift
//  Music
//
//  Created by Jack on 4/30/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

/// Music Player Download Mode
enum MusicPlayerDownloadMode {
    case download
    case downloaded
    case disable
}

class MusicPlayerDownloadButton: UIButton {
    
    var mode: MusicPlayerDownloadMode = .disable {
        didSet {
            changeMode()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func changeMode() {
        switch mode {
        case .download:
            setImage(#imageLiteral(resourceName: "player_control_download"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_download_press"), for: .highlighted)
        case .downloaded:
            setImage(#imageLiteral(resourceName: "player_control_downloaded"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_downloaded_press"), for: .highlighted)
        case .disable:
            setImage(#imageLiteral(resourceName: "player_control_download_disable"), for: .disabled)
            isEnabled = false
        }
    }
}

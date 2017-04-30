//
//  MusicPlayerDownloadButton.swift
//  Music
//
//  Created by Jack on 4/30/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicPlayerDownloadButton: UIButton {
    
    var mode: MusicPlayerDownloadMode = .disable {
        didSet {
            changeModel()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func changeModel() {
        switch mode {
        case .normal:
            setImage(#imageLiteral(resourceName: "player_control_download"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_download_press"), for: .highlighted)
        case .downloaded:
            setImage(#imageLiteral(resourceName: "player_control_downloaded"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_downloaded_press"), for: .highlighted)
        case .disable:
            setImage(#imageLiteral(resourceName: "player_control_download_disable"), for: .normal)
            
        }
    }
}

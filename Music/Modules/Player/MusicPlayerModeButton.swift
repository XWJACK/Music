//
//  MusicPlayerModeButton.swift
//  Music
//
//  Created by Jack on 4/30/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicPlayerModeButton: UIButton {
    
    private(set) var mode: MusicPlayerPlayMode = .order
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// order -> single -> random -> order -> ....
    @discardableResult
    func changePlayMode() -> MusicPlayerPlayMode {
        switch mode {
        case .order:
            mode = .single
            setImage(#imageLiteral(resourceName: "player_control_model_single"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_model_single_highlighted"), for: .highlighted)
        case .single:
            mode = .random
            setImage(#imageLiteral(resourceName: "player_control_model_random"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_model_random_highlighted"), for: .highlighted)
        case .random:
            mode = .order
            setImage(#imageLiteral(resourceName: "player_control_model_order"), for: .normal)
            setImage(#imageLiteral(resourceName: "player_control_model_order_highlighted"), for: .highlighted)
        }
        return mode
    }
}

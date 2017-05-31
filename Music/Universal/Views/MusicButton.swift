//
//  MusicButton.swift
//  Music
//
//  Created by Jack on 5/1/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

/// Custom music button for topbar
class MusicButton: UIButton {
    
    var isAnimation: Bool = false {
        willSet {
            if newValue { startAnimation() }
            else { stopAnimation() }
        }
    }
    private var animationImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setImage(#imageLiteral(resourceName: "player_topbar_playing1"), for: .normal)
        
        animationImageView.animationImages = [#imageLiteral(resourceName: "player_topbar_playing1"),
                                              #imageLiteral(resourceName: "player_topbar_playing2"),
                                              #imageLiteral(resourceName: "player_topbar_playing3"),
                                              #imageLiteral(resourceName: "player_topbar_playing4"),
                                              #imageLiteral(resourceName: "player_topbar_playing5"),
                                              #imageLiteral(resourceName: "player_topbar_playing6"),
                                              #imageLiteral(resourceName: "player_topbar_playing5"),
                                              #imageLiteral(resourceName: "player_topbar_playing4"),
                                              #imageLiteral(resourceName: "player_topbar_playing3"),
                                              #imageLiteral(resourceName: "player_topbar_playing2")]
        animationImageView.animationDuration = 1.1
        animationImageView.animationRepeatCount = 0
        
        addSubview(animationImageView)
        
        animationImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startAnimation() {
        guard !isAnimation else { return }
        setImage(nil, for: .normal)
        animationImageView.isHidden = false
        animationImageView.startAnimating()
    }
    
    private func stopAnimation() {
        guard isAnimation else { return }
        setImage(#imageLiteral(resourceName: "player_topbar_playing1"), for: .normal)
        animationImageView.isHidden = true
        animationImageView.stopAnimating()
    }
}

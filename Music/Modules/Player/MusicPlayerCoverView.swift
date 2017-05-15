//
//  MusicPlayerCoverView.swift
//  Music
//
//  Created by Jack on 5/15/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicPlayerCoverView: UIView {
    
    private let coverImageView = UIImageView(image: #imageLiteral(resourceName: "player_display_cover_background"))
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        coverImageView.layer.masksToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 71
        
        addSubview(coverImageView)
        addSubview(imageView)
        
        coverImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(142)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverImageView.layer.cornerRadius = frame.width / 2
    }
    
    func setImage(url: URL?) {
        imageView.kf.setImage(with: url,
                              placeholder: #imageLiteral(resourceName: "background_default_light"),
                              options: [.forceTransition,
                                        .transition(.fade(0.5))])
    }
}

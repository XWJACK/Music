//
//  MusicPlayerCoverView.swift
//  Music
//
//  Created by Jack on 5/15/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicPlayerCoverView: CycleContainer {
    
//    private let discBackgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "player_disc_background"))
//    private let coverImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "player_cover"))
    private let albumImageView: UIImageView = UIImageView()
    private let discImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "player_disc"))
    private let maskImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "player_mask"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        addSubview(discBackgroundImageView)
//        addSubview(coverImageView)
        addSubview(albumImageView)
        addSubview(discImageView)
        addSubview(maskImageView)
        
//        discBackgroundImageView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
        
//        coverImageView.snp.makeConstraints { (make) in
//            make.size.equalTo(discImageView).offset(-80)
//            make.center.equalToSuperview()
//        }
        
        albumImageView.snp.makeConstraints { (make) in
            make.size.equalTo(discImageView).offset(-80)
            make.center.equalToSuperview()
        }
        
        discImageView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        maskImageView.snp.makeConstraints { (make) in
            make.width.equalTo(discImageView).offset(-12)
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(url: URL?) {
        albumImageView.kf.setImage(with: url,
                                   placeholder: albumImageView.image ?? #imageLiteral(resourceName: "player_cover_default"),
                                   options: [.forceTransition,
                                             .transition(.fade(1))])
    }
}

//
//  MusicListHeaderView.swift
//  Music
//
//  Created by Jack on 5/31/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicListHeaderView: UIView {
    
    private let backgroundImageView: UIImageView = UIImageView()
    private let effectView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private let coverImageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    
    private let creatorAvatarImageView: UIImageView = UIImageView()
    private let creatorNameLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        effectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        coverImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
//            make.width.height.equalTo(<#T##other: ConstraintRelatableTarget##ConstraintRelatableTarget#>)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  MusicSearchTableViewCell.swift
//  Music
//
//  Created by Jack on 5/5/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicSearchTableViewCell: MusicTableViewCell {
    let musicLabel = UILabel()
    let detailLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        leftPadding = 10
        
        musicLabel.font = .font18
        musicLabel.textColor = .white
        
        detailLabel.font = .font10
        detailLabel.textColor = .darkGray
        
        contentView.addSubview(musicLabel)
        contentView.addSubview(detailLabel)
        
        musicLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftPadding)
            make.top.equalToSuperview().offset(5)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftPadding)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

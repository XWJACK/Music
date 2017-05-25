//
//  MusicLyricTableViewCell.swift
//  Music
//
//  Created by Jack on 5/24/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicLyricTableViewCell: MusicTableViewCell {
    
    let lyricLabel: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        isHiddenSeparator = true
        
        lyricLabel.text = ""
        lyricLabel.font = .font12
        lyricLabel.textColor = .lightGray
        lyricLabel.numberOfLines = 0
        lyricLabel.textAlignment = .center
        
        contentView.addSubview(lyricLabel)
        
        lyricLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

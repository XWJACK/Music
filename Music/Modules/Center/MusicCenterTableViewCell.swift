//
//  MusicCenterTableViewCell.swift
//  Music
//
//  Created by Jack on 5/7/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicCenterClearCacheTableViewCell: MusicTableViewCell {
    
    var rightView = UIView()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let cacheLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        rightView.backgroundColor = .clear
        
        cacheLabel.textColor = .white
        cacheLabel.text = ""
        
        rightView.addSubview(cacheLabel)
        rightView.addSubview(indicator)
        contentView.addSubview(rightView)
        
        rightView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        indicator.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        cacheLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

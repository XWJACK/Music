//
//  MusicTableViewCell.swift
//  Music
//
//  Created by Jack on 5/1/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicTableViewCell: UITableViewCell {
    
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    var leftPadding: CGFloat = 0
    var rightPadding: CGFloat = 0
    var lineWidth: CGFloat = 0.5
    
    var lineColor: UIColor = .lightGray {
        didSet {
            separator.backgroundColor = lineColor
        }
    }
    
    var isSeparatorHidden: Bool = false {
        didSet {
            separator.isHidden = isSeparatorHidden
        }
    }
    
    private let separator = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        separator.backgroundColor = lineColor
        contentView.addSubview(separator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separator.frame = CGRect(x: leftPadding,
                                 y: contentView.frame.height - lineWidth,
                                 width: frame.width - leftPadding - rightPadding,
                                 height: lineWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

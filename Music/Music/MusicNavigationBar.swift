//
//  MusicNavigationBar.swift
//  Music
//
//  Created by Jack on 4/30/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit

class MusicnavigationBar: UIView {
    
    let backButton: UIButton
    let titleLabel: UILabel
    let actionButton: UIButton
    let separator: UIView
    
    override init(frame: CGRect) {
        backButton = UIButton(type: .custom)
        titleLabel = UILabel()
        actionButton = UIButton(type: .custom)
        separator = UIView()
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

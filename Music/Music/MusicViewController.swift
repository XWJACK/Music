//
//  MusicViewController.swift
//  Music
//
//  Created by Jack on 4/30/17.
//  Copyright © 2017 Jack. All rights reserved.
//

import UIKit
import SnapKit

class MusicViewController: UIViewController {

    let navigationBar = MusicnavigationBar()
    
    var isShowStatusBar = true {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool { return !isShowStatusBar }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    
    override var title: String? {
        get { return navigationBar.titleLabel.text }
        set { navigationBar.titleLabel.text = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(navigationBar)
        
        navigationBar.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(64)
        }
    }
}

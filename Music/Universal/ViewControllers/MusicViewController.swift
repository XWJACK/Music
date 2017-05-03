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

    let musicNavigationBar = MusicNavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
    var musicNavigationController: MusicNavigationController? { return navigationController as? MusicNavigationController }
    
    var isShowStatusBar = true {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool { return !isShowStatusBar }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    
    override var title: String? {
        get { return musicNavigationBar.titleLabel.text }
        set { musicNavigationBar.titleLabel.text = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(musicNavigationBar)
    }
}
